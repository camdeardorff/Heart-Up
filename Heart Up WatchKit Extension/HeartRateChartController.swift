//
//  testPageBased.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 8/9/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit


class HeartRateChartController: WKInterfaceController, HeartRateUpdatesDelegate {
    
    @IBOutlet var imageView: WKInterfaceImage!
    let stats = HeartRateStats.sharedInstance

    override func awake(withContext context: AnyObject?) {
        stats.updateListener = self
        

    }

    override func didAppear() {
              
    }
    
    
    func newImage(data: [NSNumber]) -> UIImage {
        

        let image = YOLineChartImage()
        image.fillColor = randomColor()
        image.values = data
        
        let frame = CGRect(x:0, y:0, width:contentFrame.width, height:contentFrame.height / 1.5)
        return image.draw(frame, scale: WKInterfaceDevice.current().screenScale)
    }
    
    
    private func randomColor() -> UIColor {
        let hue = ( CGFloat(arc4random() % 256) / 256.0 )               //  0.0 to 1.0
        let saturation = ( CGFloat(arc4random() % 128) / 256.0 ) + 0.5  //  0.5 to 1.0, away from white
        let brightness = ( CGFloat(arc4random() % 128) / 256.0 ) + 0.5  //  0.5 to 1.0, away from black
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha:0)//1)
    }
}
extension HeartRateChartController {
    func newSegmentAvailable(data: [NSNumber]) {
        cam("new segment avaliable in chart controller")
        self.imageView.setImage(newImage(data: data))
    }
}
