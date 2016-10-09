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
import WatchConnectivity
import HealthKit



class StartController: WKInterfaceController {
    
    
    @IBOutlet var reuseWorkoutTable: WKInterfaceTable!
    var workouts: [Workout] = []
    var readyForWorkout: Bool = false
    var healthDataAvailable: Bool = false
    
    override func awake(withContext context: Any?) {
        
        if !HKHealthStore.isHealthDataAvailable() {
            // tell the user that health data is not available
            healthDataAvailable = false
            displayNoHealthDataMessage()
        } else {
            let store = HKHealthStore()
            let authorization = store.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .heartRate)!)
            healthDataAvailable = true
            
            switch authorization {
            case .notDetermined:
                
                print("not determined")
                readyForWorkout = false
                displayNoSharingMessage()
                
            case .sharingDenied:
                
                print("sharing denied")
                readyForWorkout = false
                displayNoSharingMessage()
                
            case .sharingAuthorized:
                
                print("sharing authorized")
                readyForWorkout = true
                
                let realm = try! Realm()
                
                let savedWorkouts = realm.objects(Workout.self)
                print("1 there are \(savedWorkouts.count) saved workouts")
                self.workouts = Array(savedWorkouts)
                
                if self.workouts.count < 1 {
                    nextController()
                } else {
                    loadTableData(data: self.workouts)
                }
            }
        }
    }
    
    func displayNoSharingMessage() {
        let errorMessage = WKAlertAction(title: "Will do!", style: .default, handler: {})
        presentAlert(withTitle: "uhh-oh!", message: "It looks like there are no permissions for reading workout data, please enable permissions in the ___ app.", preferredStyle: .alert, actions: [errorMessage])
    }
    
    func displayNoHealthDataMessage() {
        let noDataMessage = WKAlertAction(title: "Understood", style: .default, handler: {})
        presentAlert(withTitle: "Ohh no!", message: "This device does not have access to Healthkit.", preferredStyle: .alert, actions: [noDataMessage])
    }
    
    
    @IBAction func startButtonWasPressed() {
        nextController()
    }
    
    func nextController() {
        if !healthDataAvailable {
            displayNoHealthDataMessage()
        } else if !readyForWorkout {
            displayNoSharingMessage()
        } else {
            let workoutConfig = Workout()
            pushController(withName: "WorkoutSelectionController", context: workoutConfig)
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let workout = workouts[rowIndex]
        
        //make a new workout object with the same data. this way we dont overrite this realm workout instance
        let newWorkout = Workout()
        //set type, location, levels...
        newWorkout.type = workout.type
        newWorkout.location = workout.location
        newWorkout.levelLow = workout.levelLow
        newWorkout.levelHigh = workout.levelHigh
        newWorkout.intensity = workout.intensity
        newWorkout.configIndex = workout.configIndex
        
        WKInterfaceController.reloadRootControllers(withNames: ["WorkoutController", "HeartRateChartController"], contexts: [newWorkout, newWorkout])
        
    }
    
    
    func loadTableData(data: [Workout]) {
        reuseWorkoutTable.setNumberOfRows(data.count, withRowType: "ReuseWorkoutTableRowController")
        
        
        for (index, workout) in data.enumerated() {
            let row = reuseWorkoutTable.rowController(at: index) as! ReuseWorkoutTableRowController
            
            if workout.configIndex != Workout.UNSET_VALUE {
                
                let config = ApplicationData.workouts[workout.configIndex]
                
                let configIdx = workout.configIndex
                let date = workout.start
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                
                dateFormatter.locale = Locale(identifier: "en_US")
                
                row.workoutImage.setImage(config.image)
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
