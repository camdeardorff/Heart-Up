//
//  ActivityTypeTableRowController.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/28/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit
import HealthKit

class ReuseWorkoutTableRowController: NSObject {
    
    @IBOutlet var workoutImage: WKInterfaceImage!
    @IBOutlet var workoutLabel: WKInterfaceLabel!

    @IBOutlet var intensityLabel: WKInterfaceLabel!
    
    @IBOutlet var dateLabel: WKInterfaceLabel!
    
    
    @IBOutlet var minHRLabel: WKInterfaceLabel!
    @IBOutlet var maxHRLabel: WKInterfaceLabel!
    
    
    
    var configIndex: Int?

}
