//
//  WorkoutInterface.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/27/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation
import HealthKit


class HealthDataInterface: NSObject {
    
    //singleton instance. allows for ending from another controller
    static let shared = HealthDataInterface()
    
    //HealthKit info
    private var startDate: Date?
    private var workoutSession: HKWorkoutSession?
    var healthStore = HKHealthStore()
    private var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    
    //heart rate info
    private let heartRateUnit = HKUnit(from:"count/min")
    private let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    private let heartRateTypeIdentifier: HKQuantityTypeIdentifier = HKQuantityTypeIdentifier.heartRate
    private var hrQuery: HKQuery?
    
    //calorie info
    let energyUnit = HKUnit.calorie()
    let activeEnergyType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
    let activeEndergyTypeIdentifier: HKQuantityTypeIdentifier = HKQuantityTypeIdentifier.activeEnergyBurned
    var calQuery: HKQuery?
    var totalActiveCalories: Double = 0.0
    
    
    //delegate for providing heart rate updates
    var delegate: HeartRateInterfaceUpdateDelegate?
    
    //testing / dummy data
    private var isTest = false
    private let sampleHR: [Double] = [69,69,49,49,49,49,49,49,74,74,76,77,81,82,77,69,67,61,61,61,60]
    private var sampleHRIndex = 0
    private var timerForTest: Timer? = nil
    
    
    ///MARK: Private Initializer
    private override init() { }
    
    /**
     # Reset
     resets the interface for the next run
     - Returns: void
     */
    func reset() {
        startDate = Date()
        workoutSession = nil
        hrQuery = nil
        calQuery = nil
        totalActiveCalories = 0.0
        delegate = nil
        isTest = false
    }
    
    ///MARK: Start/End/Create Queries
    //entry way from outside, provided with the workout session this function sets up the queries and starts them
    func startQueries(workoutConfig: HKWorkoutConfiguration, isTest: Bool) {
        
        if isTest {
            //this is a test, start test processing
            startTestProcessing()
        } else {
            // this is not a test
            startDate = Date() //right now
            
            //initializing workout session from configuration could throw
            do {
                workoutSession = try HKWorkoutSession(configuration: workoutConfig)
                workoutSession?.delegate = self
                healthStore.start(workoutSession!)
                
                //create and execute heart rate query
                hrQuery = createQuery(quantityTypeIdentifier: heartRateTypeIdentifier)
                healthStore.execute(hrQuery!)
                
                //create and execute calorie query
                calQuery = createQuery(quantityTypeIdentifier: activeEndergyTypeIdentifier)
                healthStore.execute(calQuery!)
                
            } catch let error as NSError {
                // Perform proper error handling here...
                fatalError("*** Unable to create the workout session: \(error.localizedDescription) ***")
            }
        }
    }
    
    //ends queries
    func endQueries() {
        
        if isTest {
            if let _ = timerForTest {
                timerForTest?.invalidate()
            }
        } else {
            if let _ = self.hrQuery {
                healthStore.stop(self.hrQuery!)
            }
            if let _ = self.calQuery {
                healthStore.stop(self.calQuery!)
            }
            if let _ = self.workoutSession {
                healthStore.end(self.workoutSession!)
            }
        }
    }
    
    
    //private function for creating and configuring queries
    private func createQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) -> HKAnchoredObjectQuery {
        
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate, devicePredicate])
        
        
        let updateHandler: ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void) = { query, samples, deletedObjects, queryAnchor, error in
            self.process(samples: samples, quantityTypeIdentifier: quantityTypeIdentifier)
        }
        
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!,
                                          predicate: queryPredicate,
                                          anchor: nil,
                                          limit: HKObjectQueryNoLimit,
                                          resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        return query
    }
    
    
    //private processor of healthkit samples
    private func process(samples: [HKSample]?, quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    
                    if (quantityTypeIdentifier == HKQuantityTypeIdentifier.heartRate) {
                        
                        let hr = sample.quantity.doubleValue(for: strongSelf.heartRateUnit)
                        strongSelf.delegate?.newHeartRateSample(hr: hr)
                        
                    } else if quantityTypeIdentifier == HKQuantityTypeIdentifier.activeEnergyBurned {
                        let cal = sample.quantity.doubleValue(for: strongSelf.energyUnit)
                        strongSelf.totalActiveCalories += cal
                        strongSelf.delegate?.newCalorieSum(cals: strongSelf.totalActiveCalories)
                        
                    }
                }
            }
        }
    }
    
    
    ///MARK: Simulation testing methods
    private func startTestProcessing() {
        timerForTest = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(HealthDataInterface.testProcess), userInfo: nil, repeats: true)
        
    }
    
    @objc private func testProcess() {
        if sampleHRIndex >= sampleHR.count { sampleHRIndex = 0 }
        
        let hr = sampleHR[sampleHRIndex]
        sampleHRIndex += 1
        
        delegate?.newHeartRateSample(hr: hr)
    }
}

extension HealthDataInterface: HKWorkoutSessionDelegate {
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
        print("workout state did change to :", toState)
        
        switch toState {
        case .running:
            print("changed to running")
        case.ended:
            print("changed to ended")
        case .notStarted:
            print("changed to not started")
        case .paused:
            print("changed to paused")
        }
    }
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        print("did generate workout session, event: ", event)
    }
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("did fail with error: ", error)
    }
    
}

//protocol for outside classes to adhear to so that they can get updates of health kit query info.
protocol HeartRateInterfaceUpdateDelegate {
    func newHeartRateSample(hr: Double)
    func newCalorieSum(cals: Double)
}
