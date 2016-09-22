//
//  StartController.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/28/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit
import RealmSwift
import Realm





class StartController: WKInterfaceController {
    
    
    @IBOutlet var reuseWorkoutTable: WKInterfaceTable!
    var workouts: [Workout] = []
    
    override func awake(withContext context: Any?) {
        
//        let defaultPath = Realm.Configuration.defaultConfiguration.fileURL?.absoluteString
        //        try! FileManager.default.removeItem(atPath: defaultPath!)
        
        
        let realm = try! Realm()
        
        
        let savedWorkouts = realm.allObjects(ofType: Workout.self)
        print("1 there are \(savedWorkouts.count) saved workouts")
        workouts = Array(savedWorkouts)
        
        loadTableData(data: workouts)
        
        print(workouts)
        
    }
    
    
    @IBAction func startButtonWasPressed() {
        let workoutConfig = Workout()
        cam("pushing controllers" as AnyObject?)
        pushController(withName: "WorkoutSelectionController", context: workoutConfig)
        
    }
    
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let workout = workouts[rowIndex]
        
        let newWorkout = Workout()
        //set type, location, levels...
        newWorkout.type = workout.type
        newWorkout.location = workout.location
        newWorkout.levelLow = workout.levelLow
        newWorkout.levelHigh = workout.levelHigh
        
        newWorkout.intensity = workout.intensity
        newWorkout.configIndex = workout.configIndex
        //make a new workout object with the same data. this way we dont overrite this realm workout instance
        WKInterfaceController.reloadRootControllers(withNames: ["WorkoutController", "HeartRateChartController"], contexts: [newWorkout, newWorkout])

    }
    
    
    func loadTableData(data: [Workout]) {
        reuseWorkoutTable.setNumberOfRows(data.count, withRowType: "ReuseWorkoutTableRowController")
        
        print("load table data")
        
        for (index, workout) in data.enumerated() {
            let row = reuseWorkoutTable.rowController(at: index) as! ReuseWorkoutTableRowController
            print("idx: \(index), workout: \(workout)")
            
            if workout.configIndex != Workout.UNSET_VALUE {
                
                let config = ApplicationData.workouts[workout.configIndex]
                
                let configIdx = workout.configIndex
                let date = workout.start
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                
                dateFormatter.locale = Locale(identifier: "en_US")
                print(dateFormatter.string(from: date)) // Jan 2, 2001

                
                row.workoutLabel.setText(config.name)
                row.intensityLabel.setText("Intensity: \(config.intensities[workout.intensity].level)")
                row.dateLabel.setText("\(dateFormatter.string(from: date))")
                row.minHRLabel.setText("Min: \(workout.min)")
                row.maxHRLabel.setText("Max: \(workout.max)")
                row.configIndex = configIdx
                
                
            }
        }
    }
    
}
