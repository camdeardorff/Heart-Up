//
//  ViewController.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/21/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import WatchConnectivity
import HealthKit


class ViewController: UIViewController {

    @IBOutlet var outputLabel: UILabel!
    
    var session : WCSession?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       /*
        
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
            
            if !(session?.isPaired)! {
                print("Apple Watch is not paired")
            }
            
            if !(session?.isWatchAppInstalled)! {
                print("WatchKit app is not installed")
            }
        } else {
            print("WatchConnectivity is not supported on this device")
        }
        
        
        if HKHealthStore.isHealthDataAvailable() {
            let store = HKHealthStore()
            let authorization = store.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .heartRate)!)
            
            
            switch authorization {
            case .notDetermined:
                print("not determined")
                
                let healthStore = HKHealthStore()
                
                let allTypes = Set([HKObjectType.workoutType(),
                                    HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                                    HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,
                                    HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                                    HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
                
                healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                    if !success {
                        print("error occured requesting access to health kit")
                    }
                }

            case .sharingAuthorized:
                print("sharing authorized")
            case .sharingDenied:
                print("sharing denied")
            }
        }
        
        let realm = try! Realm()
        let savedWorkouts = realm.objects(Workout.self)
        print("1 there are \(savedWorkouts.count) saved workouts")
        
        
                
*/
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

/*
extension ViewController: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("session did become inactive")
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session activation did complete with state: ", activationState)
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("session did deactivate")
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("received message!: ", message)
        outputLabel.text = "\(message)"
        
    }
}

*/


