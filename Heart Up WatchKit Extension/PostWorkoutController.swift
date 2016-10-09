//
//  PostWorkoutController.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 9/14/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit
import WatchConnectivity
import RealmSwift
import Realm

class PostWorkoutController: WKInterfaceController  {
    
    
    
    @IBOutlet var chartImage: WKInterfaceImage!
    
    @IBOutlet var chartButton: WKInterfaceButton!
 
    
    @IBOutlet var workoutImage: WKInterfaceImage!
    @IBOutlet var workoutTypeLabel: WKInterfaceLabel!
    
    @IBOutlet var intensityLabel: WKInterfaceLabel!
    @IBOutlet var maxHRLabel: WKInterfaceLabel!
    @IBOutlet var minHRLabel: WKInterfaceLabel!
    
    @IBOutlet var avgHRLabel: WKInterfaceLabel!
    
    @IBOutlet var timeLabel: WKInterfaceLabel!
    
    
    @IBOutlet var saveSwitch: WKInterfaceSwitch!
    
    
    var sendContext: Workout?
    var message: [String : Any]?
    var healthStats = HealthDataStats.sharedInstance.exportData()
    var saveWorkout = true
    
    var donutImage: UIImage?
    var lineImage: UIImage?
    var currentImage: UIImage?
    
    override func awake(withContext context: Any?) {
        
        print("awake in post with context: \(context)")
        
        sendContext = context as? Workout
        
        
        if let _ = sendContext {
            workoutImage.setImage(ApplicationData.workouts[sendContext!.configIndex].image)
            workoutTypeLabel.setText(ApplicationData.workouts[sendContext!.configIndex].name)
            intensityLabel.setText(ApplicationData.workouts[sendContext!.configIndex].intensities[(sendContext?.intensity)!].level)
            maxHRLabel.setText("\((sendContext?.max)!) BPM")
            minHRLabel.setText("\((sendContext?.min)!) BPM")
            avgHRLabel.setText("\((sendContext?.avg)!) BPM")
            timeLabel.setText("\((sendContext?.time.formatHourSecond())!)")
            
            
            
            
            if let percents = healthStats.percentages {
                print("Percents: ")
                print(percents)
                donutImage = generateDonutChart(percents: percents)
                
            }
            if healthStats.data.count > 0 {
                lineImage = generateLineChart(levels: ((sendContext?.levelLow)!, (sendContext?.levelHigh)!), data: healthStats.data)
            }
            if let li = lineImage {
                chartImage.setImage(li)
                currentImage = li
            } else if let di = donutImage {
                chartImage.setImage(di)
                currentImage = di
            }
        }
    }
    
    
    @IBAction func saveSwitchWasChanged(_ value: Bool) {
        saveWorkout = value
    }
    
    
    @IBAction func chartButtonWasPressed() {
        print("chart button was pressed")
        if let _ = currentImage {
            if currentImage == lineImage {
                currentImage = donutImage
            } else if currentImage == donutImage {
                currentImage = lineImage
            }
            chartImage.setImage(currentImage)
        }
        
    }
    
    func generateDonutChart(percents: (above: Double, on: Double,below: Double)) -> UIImage {
//        FF754C
        let a = UIColor(rgb: 0xFF754C, alphaVal: 1.0)
        let b = UIColor(rgb: 0x00ACC1, alphaVal: 1.0)
        let c = UIColor(rgb: 0xBA68C8, alphaVal: 1.0)

        let donut = YODonutChartImage()
        donut.colors = [a,b,c]
        donut.donutWidth = 7
        donut.labelColor = .white
        donut.labelText = "Above: \(Int(percents.above * 100))\nOn: \(Int(percents.on * 100))\nBelow: \(Int(percents.below * 100))"
        
        donut.values = [NSNumber(floatLiteral: percents.below),
                        NSNumber(floatLiteral: percents.on),
                        NSNumber(floatLiteral: percents.above)]
        let frame = CGRect(x:0, y:0, width:contentFrame.width, height:contentFrame.height)
        return donut.draw(frame, scale: WKInterfaceDevice.current().screenScale)
    }
    
    func generateLineChart(levels: (low: Int, high: Int), data: [Segment]) -> UIImage {
       
        var lowerBoundry = levels.low
        var upperBoundry = levels.high
        var values = [NSNumber]()
        for segment in data {
            values.append(NSNumber(floatLiteral:segment.averageHR))
            if Int(segment.averageHR) > upperBoundry {
                upperBoundry = Int(segment.averageHR)
            }
            if Int(segment.averageHR) < lowerBoundry {
                lowerBoundry = Int(segment.averageHR)
            }
        }
        
        
        
        let line = YOLineChartImage()
        line.levels = [NSNumber(integerLiteral: levels.low), NSNumber(integerLiteral: levels.high)]
        line.levelStrokeColor = .white
        line.levelStrokeWidth = 2
        
        line.maxValue = NSNumber(integerLiteral: upperBoundry)
        line.minValue = NSNumber(integerLiteral: lowerBoundry)
        
        line.smooth = true
        
       
        line.values = values
        line.lineStrokeColor = .red
        line.lineStrokeWidth = 2
        let frame = CGRect(x:0, y:0, width:contentFrame.width, height:contentFrame.height / 1.5)
        return line.draw(frame, scale: WKInterfaceDevice.current().screenScale)
    }
    
    
    @IBAction func doneButtonWasPressed() {
        
        if saveWorkout {
            
            let realm = try! Realm()
            
            try! realm.write {
                print("try write: \(sendContext)")
                realm.add(sendContext!)
            }
            
//            let workoutSender = WorkoutSender()
//            if workoutSender.isReady() {
//                workoutSender.send(workout: sendContext!)
//            }
            if WCSession.isSupported() {
                
                let session = WCSession.default()
                session.delegate = self
                session.activate()
                message = sendContext?.exportSettings()
                
            }
            
        }
        WKInterfaceController.reloadRootControllers(withNames: ["StartController"], contexts: nil)
    }
}

extension PostWorkoutController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session activation did complete with state: ", activationState)
        
        if activationState == .activated {
            if let m = message {
                session.sendMessage(m, replyHandler: { (message) -> Void in print(message) }, errorHandler: { (error) -> Void in print(error)})
            }
        }
        
    }
    
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("received message!: ", message)
    }
}


extension TimeInterval {
    func formatHourSecond() -> String {
        let min = Int(self.truncatingRemainder(dividingBy: 3600)) / 60
        let hr = Int(self / 3600)
        
        
        var time = ""
        if hr > 0 {
            time += "\(hr) hour"
            if hr > 1 {
                time += "s"
            }
        }
        if min > 0 {
            if hr > 0 {
                time += ", "
            }
            time += "\(min) minute"
            if min > 1 {
                time += "s"
            }
        }
        return time
    }
}

extension UIColor{
    convenience init(rgb: UInt, alphaVal: CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alphaVal
        )
    }
}
