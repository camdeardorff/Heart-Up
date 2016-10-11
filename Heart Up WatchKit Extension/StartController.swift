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
                
                
                let savedWorkouts = realm.objects(DBWorkout.self)
                print("there are \(savedWorkouts.count) saved workouts")
                
                savedWorkouts.forEach({ (dbw) in
                    print("loop saved workout: ", dbw)
                    workouts.append(Workout(dbWorkout: dbw))

                })
                
                if self.workouts.count < 1 {
                    nextController()
                } else {
                    loadTableData()
                }
            }
        }
    }
    
    func displayNoSharingMessage() {
        print("displaying no sharing message")
        let errorMessage = WKAlertAction(title: "Will do!", style: .default, handler: {})
        presentAlert(withTitle: "uhh-oh!", message: "It looks like there are no permissions for reading workout data, please enable permissions in the ___ app.", preferredStyle: .alert, actions: [errorMessage])
    }
    
    func displayNoHealthDataMessage() {
        print("displaying no health data message")
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
        WKInterfaceController.reloadRootControllers(withNames: ["WorkoutController", "HeartRateChartController"], contexts: [workout, workout])
    }
    
    
    func loadTableData() {
        reuseWorkoutTable.setNumberOfRows(workouts.count, withRowType: "ReuseWorkoutTableRowController")
        
        
        for (index, workout) in workouts.enumerated() {
            let row = reuseWorkoutTable.rowController(at: index) as! ReuseWorkoutTableRowController
            
            if workout.configIndex > -1 {
            
                let config = ApplicationData.workouts[workout.configIndex]
                
                let configIdx = workout.configIndex
                let date = workout.time.start
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                
                dateFormatter.locale = Locale(identifier: "en_US")
                
                row.workoutImage.setImage(config.image)
                row.workoutLabel.setText(config.name)
                row.intensityLabel.setText("Intensity: \(config.intensities[workout.intensity].level)")
                row.dateLabel.setText("\(dateFormatter.string(from: date))")
                row.minHRLabel.setText("Min: \(workout.heartRate.min)")
                row.maxHRLabel.setText("Max: \(workout.heartRate.max)")
                row.configIndex = configIdx
                
                
            }
        }
    }
}
