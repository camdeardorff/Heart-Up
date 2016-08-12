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
    let stats = HeartRateStats.sharedInstance
    
    let upperLimitHR = 100
    let lowerLimitHR = 80

    override func awake(withContext context: AnyObject?) {
        stats.updateListener = self
        

    }

    override func didAppear() {
              
    }
    
    
    func newImage(data: [NSNumber]) -> UIImage {
        
        let image = YOLineChartImage()
        image.values = data
        image.lineFillColor = randomColor()
        image.lineStrokeColor = UIColor.red()
        image.lineStrokeWidth = 3
        
        image.maxValue = determineMaxValue(data)
        image.levels = [upperLimitHR, lowerLimitHR]
        
        let frame = CGRect(x:0, y:0, width:contentFrame.width, height:contentFrame.height / 1.5)
        return image.draw(frame, scale: WKInterfaceDevice.current().screenScale)
    }
    
    
    func determineMaxValue(_ data: [NSNumber]) -> NSNumber {
        if let maxInArr = findMaxNumberIn(arr: data) {
            if maxInArr.compare(NSNumber(integerLiteral: upperLimitHR)) == ComparisonResult.orderedDescending {
                return maxInArr
            }
        }
        return upperLimitHR
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
    
    
    private func randomColor() -> UIColor {
        let hue = ( CGFloat(arc4random() % 256) / 256.0 )               //  0.0 to 1.0
        let saturation = ( CGFloat(arc4random() % 128) / 256.0 ) + 0.5  //  0.5 to 1.0, away from white
        let brightness = ( CGFloat(arc4random() % 128) / 256.0 ) + 0.5  //  0.5 to 1.0, away from black
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha:0.2)//1)
    }
}
extension HeartRateChartController {
    func newSegmentAvailable(data: [NSNumber]) {
        if data.count < 3 { return }
        cam("new segment avaliable in chart controller")
        self.imageView.setImage(newImage(data: data))
    }
}
