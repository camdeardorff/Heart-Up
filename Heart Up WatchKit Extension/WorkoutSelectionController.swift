//
//  WorkoutConfiguration.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/28/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit
import HealthKit

class WorkoutSelectionController: WKInterfaceController {
    
    @IBOutlet var workoutTable: WKInterfaceTable!
    
    var sendContext: WorkoutConfig?
    
    override func awake(withContext context: AnyObject?) {
        cam("awake in workout selection controller with context \(context)")
        sendContext = context as? WorkoutConfig
        loadTableData(data: ApplicationData.workouts)
    }
    
    func loadTableData(data: [(name: String, image: UIImage, type: HKWorkoutActivityType, location: HKWorkoutSessionLocationType, intensities: [(level: String, min: Int, max: Int)])]) {
        workoutTable.setNumberOfRows(data.count, withRowType: "WorkoutTableRowController")
        
        for (index, point) in data.enumerated() {
            let row = workoutTable.rowController(at: index) as! WorkoutTableRowController
            row.image.setImage(point.image)
            row.workoutName.setText(point.name)
        }
    }
    
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let workout = ApplicationData.workouts[rowIndex]
        if let context = sendContext {
            context.sentFromControllerNamed = "WorkoutSelectionController"
            context.workoutType = workout
            cam("pushing controller")
            pushController(withName: "IntesitySelectorController", context: context)
        }
    }
    
}
