//
//  testPageBased.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 8/9/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit

/*
 Do nothing unless there are at least 3 segments... maybe display that to the user
 */


class HeartRateChartController: WKInterfaceController, HeartRateUpdatesDelegate {
    
    @IBOutlet var imageView: WKInterfaceImage!
    
    let stats = HealthDataStats.sharedInstance
    
    var upperLimitHR = 100
    var lowerLimitHR = 80
    
    var sendContext: Workout?
    
    override func awake(withContext context: Any?) {
      
        stats.updateListener = self
        sendContext = context as? Workout

        
        if let max = sendContext?.levelHigh {
            upperLimitHR = max
        }
        if let min = sendContext?.levelLow {
            lowerLimitHR = min
        }
        
        
      
        
        let data: [NSNumber] = []
        self.imageView.setImage(newImage(data: data))
    }
    
    
    func newImage(data: [NSNumber]) -> UIImage {
        
        let image = YOLineChartImage()
        image.values = data
        image.lineStrokeColor = UIColor.red
        image.lineStrokeWidth = 3
        
        let boudries = determineMaxMinValue(data)
        image.maxValue = boudries.max
        image.minValue = boudries.min
        
        image.levels = [NSNumber(integerLiteral: lowerLimitHR), NSNumber(integerLiteral: upperLimitHR)]
        
        
        
        
        let frame = CGRect(x:0, y:0, width:contentFrame.width, height:contentFrame.height / 1.5)
        return image.draw(frame, scale: WKInterfaceDevice.current().screenScale)
    }
    
    
    func determineMaxMinValue(_ data: [NSNumber]) -> (max:NSNumber, min:NSNumber) {
        var max: NSNumber
        var min: NSNumber
        
        if let maxInArr = findMaxNumberIn(arr: data) {
            if maxInArr.compare(NSNumber(integerLiteral: upperLimitHR)) == ComparisonResult.orderedDescending {
                max = maxInArr
            } else {
                max = NSNumber(integerLiteral: upperLimitHR)
            }
        } else {
            max = NSNumber(integerLiteral: upperLimitHR)
        }
        
        if let minInArr = findMinValueIn(arr: data) {
            if minInArr.compare(NSNumber(integerLiteral: lowerLimitHR)) == ComparisonResult.orderedAscending {
                min = minInArr
            } else {
                min = NSNumber(integerLiteral: lowerLimitHR)
            }
        } else {
            min = NSNumber(integerLiteral: lowerLimitHR)
        }
        return (max, min)
    }
    
    
    
    func findMaxNumberIn(arr: [NSNumber]) -> NSNumber? {
        if arr.count > 0 {
            var currMax = arr[0]
            for num in arr {
                if num.compare(currMax) == ComparisonResult.orderedDescending {
                    currMax = num
                }
            }
            return currMax
        }
        return nil
    }
    
    func findMinValueIn(arr: [NSNumber]) -> NSNumber? {
        if arr.count > 0 {
            var currMin = arr[0]
            for num in arr {
                if num.compare(currMin) == ComparisonResult.orderedAscending {
                    currMin = num
                }
            }
            return currMin
        }
        return nil
    }
    
    
    
    @IBAction func endWorkoutButtonWasPressed() {
        let end = WKAlertAction(title: "End", style: WKAlertActionStyle.default, handler: {
            HealthDataInterface.sharedInstance.endQueries()
            let data = self.stats.exportData()
            print("exported data: ", data)
            self.sendContext?.avg = data.avg
            self.sendContext?.max = data.max
            self.sendContext?.min = data.min
            self.sendContext?.start = data.start
            self.sendContext?.end = data.end
            self.sendContext?.time = data.time
            
            print("loop segments")
            for seg in data.data {
                self.sendContext?.data.append(seg)
            }
            
            print("\n\ntransfer vc? with context: ")
            if let _ = self.sendContext {
                WKInterfaceController.reloadRootControllers(withNames: ["PostWorkoutController"], contexts: [self.sendContext!])
//                self.pushController(withName: "PostWorkoutController", context: self.sendContext!)
            }
        })
        presentAlert(withTitle: "Wait!", message: "Are you ready to end this workout?", preferredStyle: .actionSheet, actions: [end])
        
    }
    
    
    
    
    private func randomColor() -> UIColor {
        let hue = ( CGFloat(arc4random() % 256) / 256.0 )               //  0.0 to 1.0
        let saturation = ( CGFloat(arc4random() % 128) / 256.0 ) + 0.5  //  0.5 to 1.0, away from white
        let brightness = ( CGFloat(arc4random() % 128) / 256.0 ) + 0.5  //  0.5 to 1.0, away from black
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha:0.2)//1)
    }
}
extension HeartRateChartController {
    func newSegmentAvailable(data: [NSNumber]) {
        if data.count < 3 {
//            imageView.setImage(UIImage(named: "PreChart"))
        } else {
            self.imageView.setImage(newImage(data: data))
        }
    }
}
