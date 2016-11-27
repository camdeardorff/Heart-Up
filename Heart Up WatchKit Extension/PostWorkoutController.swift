//
//  PostWorkoutController.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 9/14/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit
import RealmSwift
import Realm

class PostWorkoutController: WKInterfaceController  {
    
    
    // interface objects
    // charts
    @IBOutlet var chartImage: WKInterfaceImage!
    @IBOutlet var chartButton: WKInterfaceButton!
    // workout data
    @IBOutlet var workoutImage: WKInterfaceImage!
    @IBOutlet var workoutTypeLabel: WKInterfaceLabel!
    @IBOutlet var intensityLabel: WKInterfaceLabel!
    @IBOutlet var maxHRLabel: WKInterfaceLabel!
    @IBOutlet var minHRLabel: WKInterfaceLabel!
    @IBOutlet var avgHRLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    // save
    @IBOutlet var saveSwitch: WKInterfaceSwitch!
    
    // workout data
    var workout: Workout?
    var healthStats = HealthDataStats.sharedInstance.exportData()
    var saveWorkout = true
    
    // images
    var donutImage: UIImage?
    var lineImage: UIImage?
    var currentImage: UIImage?
    
    override func awake(withContext context: Any?) {
        workout = context as? Workout
        
        if let wkt = workout {
            workoutImage.setImage(ApplicationData.workouts[wkt.configIndex].image)
            workoutTypeLabel.setText(ApplicationData.workouts[wkt.configIndex].name)
            intensityLabel.setText("Intensity: \(Intensity.ALL_LEVELS[wkt.intensity].rawValue)")

            maxHRLabel.setText("\((wkt.heartRate.max)) BPM")
            minHRLabel.setText("\((wkt.heartRate.min)) BPM")
            avgHRLabel.setText("\((wkt.heartRate.avg)) BPM")
            timeLabel.setText("\((wkt.time.length.formatHourSecond()))")
            
            // create chart images
            if let percents = healthStats.percentages {
                donutImage = generateDonutChart(percents: percents)
            }
            if healthStats.data.count > 0 {
                lineImage = generateLineChart(levels: (wkt.levels.low, wkt.levels.high), data: healthStats.data)
            }
            // set the charts
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
    
    
    /**
     # Generate Donut Chart
     creates the donut chart image based on the values provided
     - Parameter percents: Tuple
        above: Double: percent of the time that the heart rate was above the range
        on:    Double: percent of the time that the heart rate was in the range
        below  Double: percent of the time that the heart rate was below the range
     - Returns: UIImage
     */
    func generateDonutChart(percents: (above: Double, on: Double, below: Double)) -> UIImage {
        let a = UIColor(rgb: 0xFF754C, alphaVal: 1.0)
        let b = UIColor(rgb: 0x00ACC1, alphaVal: 1.0)
        let c = UIColor(rgb: 0xBA68C8, alphaVal: 1.0)
        
        let donut = YODonutChartImage()
        donut.colors = [a,b,c]
        donut.donutWidth = 7
        donut.labelColor = .white
        donut.labelText = "Over Target: \(Int(percents.above * 100))%\nOn Target: \(Int(percents.on * 100))%\nBelow Target: \(Int(percents.below * 100))%"
        
        donut.values = [NSNumber(floatLiteral: percents.below),
                        NSNumber(floatLiteral: percents.on),
                        NSNumber(floatLiteral: percents.above)]
        let frame = CGRect(x:0, y:0, width:contentFrame.width, height:contentFrame.height)
        return donut.draw(frame, scale: WKInterfaceDevice.current().screenScale)
    }
    
    
    /**
     # Generate Line Chart
     creates the line chart image based on the values provided
     - Parameter levels: Tuple
        low:  Int: lower level
        high: Int: higher level
     - Parameter data: Tuple
        averageHR: Double: average heart rate
        atTime:    Double: when the sample was compiled
     - Returns: UIImage
     */
    func generateLineChart(levels: (low: Int, high: Int), data: [(averageHR: Double, atTime: Date)]) -> UIImage {
        
        var lowerBoundry = levels.low
        var upperBoundry = levels.high
        var values = [NSNumber]()
        // determine the upper and lower boundry
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
            let dbWorkout = DBWorkout()
            dbWorkout.importSettings(workout: workout!)
            
            try! realm.write {
                print("try write: \(dbWorkout)")
                realm.add(dbWorkout)
            }
            
            if let settings = workout?.export() {
                print("sending settings: ", settings)  
                WatchCommunicator.shared.sendDictionary(settings)
            }
        }
        WKInterfaceController.reloadRootControllers(withNames: ["StartController"], contexts: nil)
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
