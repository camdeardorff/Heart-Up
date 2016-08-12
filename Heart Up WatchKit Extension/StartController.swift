//
//  StartController.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/28/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit

class StartController: WKInterfaceController {
    
    
    @IBOutlet var reuseWorkoutTable: WKInterfaceTable!
    
    override func awake(withContext context: AnyObject?) {
        
    }
    
    @IBAction func startButtonWasPressed() {
        let workoutConfig = WorkoutConfig()
        workoutConfig.sentFromControllerNamed = "StartController"
        
        pushController(withName: "WorkoutSelectionController", context: workoutConfig)
        
    }
    
        func loadTableData(data: [WorkoutConfig]) {
            reuseWorkoutTable.setNumberOfRows(data.count, withRowType: "ReuseWorkoutTableRowController")
    
//            for (index, point) in data.enumerated() {
//                let row = reuseWorkoutTable.rowController(at: index) as! ReuseWorkoutTableRowController
//                guard let type = point.workoutType else { return }
//                guard let location = point.workoutLocation else { return }
//                guard let min = point.hrLowerLimit else { return }
//                guard let max = point.hrUpperLimit else { return }
//                guard let date = point.startDate else { return }
//
//                row.labelDate.setText(date.description)
//                row.labelWorkout.setText("Workout: \(type)")
//                row.labelLocation.setText("Location: \(location)")
//                row.labelMaxHeartRate.setText("Max: \(max)")
//                row.labelMinHeartRate.setText("Min: \(min)")
//            }
        }
    

}
