//
//  WorkoutInterface.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/27/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation
import HealthKit


class HealthDataInterface {
    
    //singleton instance. allows for ending from another controller
    static let sharedInstance = HealthDataInterface()
    
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
    
    
    
    //delegate for providing heart rate updates
    var delegate: HeartRateInterfaceUpdateDelegate?
    
    //testing / dummy data
    var isTest = true
    private let sampleHR: [Double] = [69,69,49,49,49,49,49,49,74,74,76,77,81,82,77,69,67,61,61,61,60]
    private var sampleHRIndex = 0
    private var timerForTest: Timer? = nil
    
    //private initializer
    private init() { }
    
    //entry way from outside, provided with the workout session this function sets up the queries and starts them
    func startQueries(workoutSession: HKWorkoutSession) {
        cam("HealthDataInterface: ", "start queries")
        
        if !isTest {
            startDate = Date()
            self.workoutSession = workoutSession
            healthStore.start(workoutSession)
            hrQuery = createQuery(quantityTypeIdentifier: heartRateTypeIdentifier)
            calQuery = createQuery(quantityTypeIdentifier: activeEndergyTypeIdentifier)
            healthStore.execute(hrQuery!)
            healthStore.execute(calQuery!)
        } else {
            startTestProcessing()
        }
    }
    
    //ends queries
    func endQueries() {
        cam("HealthDataInterface: ", "end queries")
        
        if !isTest {
            cam("HealthDataInterface: end queries: ", "no test!")
            guard let _ = self.hrQuery else { return }
            guard let _ = self.workoutSession else { return }
            healthStore.stop(self.hrQuery!)
            healthStore.end(self.workoutSession!)
        } else {
            cam("HealthDataInterface: end queries: ", "test..?")
            if let _ = timerForTest {
                cam("HealthDataInterface: end queries: ", "DO IT")
                timerForTest?.invalidate()
            }
        }
    }
    
    //private function for creating and configuring queries
    private func createQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) -> HKAnchoredObjectQuery {
        cam("HeartRateInterface: ", "create queries")
        
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let queryPredicate = CompoundPredicate(andPredicateWithSubpredicates:[datePredicate, devicePredicate])
        
        let updateHandler: ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, NSError?) -> Void) = { query, samples, deletedObjects, queryAnchor, error in
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
        cam("HeartRateInterface: ", "process")
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    
                    if (quantityTypeIdentifier == HKQuantityTypeIdentifier.heartRate) {
                        
                        let hr = sample.quantity.doubleValue(for: strongSelf.heartRateUnit)
                        strongSelf.delegate?.newHeartRateSample(hr: hr)
                        
                    } else if quantityTypeIdentifier == HKQuantityTypeIdentifier.activeEnergyBurned {
                        
                        let cal = sample.quantity.doubleValue(for: strongSelf.energyUnit)
                        cam("energy was found! with calories: ", cal)
                    }
                }
            }
        }
    }
    
    private func startTestProcessing() {
        cam("HeartRateInterface: Start test processing")
        timerForTest = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(HealthDataInterface.testProcess), userInfo: nil, repeats: true)
        
    }
    
    @objc private func testProcess() {
        cam("HeartRateInterface: Test Processing")
        if sampleHRIndex >= sampleHR.count { sampleHRIndex = 0 }
        
        let hr = sampleHR[sampleHRIndex]
        sampleHRIndex += 1
        
        delegate?.newHeartRateSample(hr: hr)
    }
}

//protocol for outside classes to adhear to so that they can get updates of health kit query info.
protocol HeartRateInterfaceUpdateDelegate {
    func newHeartRateSample(hr: Double)
}
