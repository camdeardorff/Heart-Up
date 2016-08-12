//
//  WorkoutInterface.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/27/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation
import HealthKit


struct HeartRateInterface {
    
    //HealthKit info
    var workoutSession: HKWorkoutSession?
    let heartRateUnit = HKUnit(from:"count/min")
    var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var query: HKQuery?
    var startDate: Date?
    var healthStore = HKHealthStore()
    
    
    
    func startAccumulatingData(startDate: Date) {
        startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier.heartRate)
    }
    
    func stopAccumulatingData() {
        healthStore.stop(query!)
    }

    
    
    func startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        
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
        healthStore.execute(query)
        
    }
    
    
    
    func process(samples: [HKSample]?, quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        DispatchQueue.main.async { //[weak self] in
            //guard let strongSelf = self where !strongSelf.isPaused else { return }
            
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    
                    if (quantityTypeIdentifier == HKQuantityTypeIdentifier.heartRate) {
                        
                        let hr = sample.quantity.doubleValue(for: self.heartRateUnit)
                        
                                                
                    }
                }
            }
        }
    }
    
    
}
