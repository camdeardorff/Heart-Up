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
    
    var sendContext: Workout?
    
    override func awake(withContext context: Any?) {
        sendContext = context as? Workout
        print("workout selection controller awake")

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
        let workoutType = ApplicationData.workouts[rowIndex]
        if let workout = sendContext {
            workout.type = Int(workoutType.type.rawValue)
            workout.location = workoutType.location.rawValue
            workout.configIndex = rowIndex
            print("pushing to controller : IntensitySelectorController")
            pushController(withName: "IntesitySelectorController", context: workout)
        }
    }
    
}
