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
    var authorizedForHeathData: Bool = false
    var healthDataAvailable: Bool = false
    
    override func awake(withContext context: Any?) {
        
        print("awake")
        if let store = getAvailableHealthStore() {
            healthDataAvailable = true
            
            if isAuthorizedForHealthData(store: store) {
                authorizedForHeathData = true

                do {
                    let realm = try Realm()

                    //grab all of the saved workouts and put them into the workout list
                    let savedWorkouts = realm.objects(DBWorkout.self)
                    savedWorkouts.forEach({ (dbw) in
                        workouts.append(Workout(dbWorkout: dbw))
                    })

                } catch _ { print("exceptions accessing realm") }
                
                // if there are no workouts then move on
                if self.workouts.count < 1 {
                    nextController()
                } else {
                    loadTableData(workouts)
                }
            } else {
                authorizedForHeathData = false
            }
        } else {
            //health store is unavailabe
            healthDataAvailable = false
        }
        
        
    }

    /**
     # Get Available Health Store
     if health data is available return the health store
     - Returns: HKHealthStore? (if data is available)
     */
    func getAvailableHealthStore() -> HKHealthStore? {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }
    
    
    /**
     # Is Authorized For Heatlh Data
     checks each data point that we want to use for this application. If we are authorized to use everything then authorization is true
     - Parameter store: the heatlh store to check authorization from.
     - Returns: Bool
     */
    func isAuthorizedForHealthData(store: HKHealthStore) -> Bool {
        let types: [HKQuantityTypeIdentifier] = [.heartRate, .activeEnergyBurned]
        
        for type in types {
            let auth = store.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: type)!)
            switch auth {
            case .notDetermined, .sharingDenied:
                return false
            case .sharingAuthorized:
                break;
            }
        }
        return true
    }
    
    //start button action
    @IBAction func startButtonWasPressed() {
        nextController()
    }
    
    // go to the next controller if all of the dependancies are met. let the user know if something is not met
    func nextController() {
        
        if !healthDataAvailable { // check if there is health data available
            let noDataMessage = WKAlertAction(title: "Understood", style: .default, handler: {})
            presentAlert(withTitle: "Ohh no!", message: "This app does not have access to Healthkit. Please allow access to Healthkit for futher usage.", preferredStyle: .alert, actions: [noDataMessage])
        }
        else if !authorizedForHeathData { // check if we are authorized for the data points necessary
            let errorMessage = WKAlertAction(title: "Will do!", style: .default, handler: {})
            presentAlert(withTitle: "uhh-oh!", message: "This app does not have permissions for reading workout data, please enable permissions in the Heart Up iOS App.", preferredStyle: .alert, actions: [errorMessage])
        } else { // all is good
            let workoutConfig = Workout()
            pushController(withName: "WorkoutSelectionController", context: workoutConfig)
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let workout = workouts[rowIndex]
        WKInterfaceController.reloadRootControllers(withNames: ["WorkoutController", "HeartRateChartController"], contexts: [workout, workout])
    }
    
    
    func loadTableData(_ wrkts: [Workout]) {
        reuseWorkoutTable.setNumberOfRows(workouts.count, withRowType: "ReuseWorkoutTableRowController")
        
        
        for (index, workout) in wrkts.enumerated() {
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
