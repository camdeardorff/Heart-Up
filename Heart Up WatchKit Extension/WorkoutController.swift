//
//  InterfaceController.swift
//  Heart Up WatchKit Extension
//
//  Created by Cameron Deardorff on 7/21/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit
import HealthKit

class WorkoutController: WKInterfaceController {
    
    //container... animate this background
    @IBOutlet var container: WKInterfaceGroup!
    
    //LABELS
    @IBOutlet var HRCurrent: WKInterfaceLabel!
    @IBOutlet var HRMax: WKInterfaceLabel!
    @IBOutlet var HRMin: WKInterfaceLabel!
    @IBOutlet var HRRate: WKInterfaceLabel!
    @IBOutlet var HRAvg: WKInterfaceLabel!
    
    
    
    //HealthKit info
    var workoutSession: HKWorkoutSession?
    let heartRateUnit = HKUnit(from:"count/min")
    var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var query: HKQuery?
    var startDate: Date?
    var healthStore = HKHealthStore()

    
    //tracking vars...
    var currentTrackedHeartRate: Double = -1 {
        didSet {
            if currentTrackedHeartRate > -1 {
                //set current label
                self.HRCurrent.setText("\(currentTrackedHeartRate) BPM")
                //check for outlier min / max
                if self.highestTrackedHeartRate < currentTrackedHeartRate || self.highestTrackedHeartRate == -1 {
                    self.highestTrackedHeartRate = currentTrackedHeartRate
                } else if currentTrackedHeartRate < self.lowestTrackedHeartRate || self.lowestTrackedHeartRate == -1 {
                    self.lowestTrackedHeartRate = currentTrackedHeartRate
                }
                self.checkThresholds(currentTrackedHeartRate)
            } else {
                self.HRCurrent.setText("- BPM")
            }
        }
    }
    var lowestTrackedHeartRate: Double = -1 {
        didSet {
            if lowestTrackedHeartRate > -1 {
                self.HRMin.setText("MIN: \(lowestTrackedHeartRate) \(minimumHeartRate)")
            } else {
                self.HRMin.setText("MIN: - \(minimumHeartRate)")
            }
        }
    }
    var highestTrackedHeartRate: Double = -1 {
        didSet {
            if highestTrackedHeartRate > -1 {
                self.HRMax.setText("MAX: \(highestTrackedHeartRate) \(maximumHeartRate)")
            } else {
                self.HRMax.setText("MAX: - \(maximumHeartRate)")

            }
        }
    }
    
    
    //limit constants
    var minimumHeartRate: Double = -1.0
    var maximumHeartRate: Double = -1.0
    
    //workout config
    var workoutLocation: HKWorkoutSessionLocationType? = .unknown
    var workoutType: HKWorkoutActivityType? = .other
    
    //testing / dummy data
    var isTest = true
    let sampleHR: [Double] = [69,69,49,49,49,49,49,49,74,74,76,77,81,82,77,69,67,61,61,61,60]
    var sampleHRIndex = 0
    
    //stats tracking
    let statsTrackingTimeFrame:Double = 15
    var statsTracker = HeartRateStats.sharedInstance
    
    //notification timer
    var timerOn = false
    
    //workout config
    var sendContext: WorkoutConfig?
    
    override func awake(withContext context: AnyObject?) {
        super.awake(withContext: context)
        //get context as workout config
        sendContext = context as? WorkoutConfig
        //set data
        if let _ = sendContext {
            minimumHeartRate = Double((sendContext!.workoutIntesity?.min)!)
            maximumHeartRate = Double((sendContext!.workoutIntesity?.max)!)
            workoutLocation = (sendContext!.workoutType?.location)!
            workoutType = (sendContext!.workoutType?.type)!
        }
        
        //create configuration
        let workoutConfig = HKWorkoutConfiguration()
        workoutConfig.activityType = workoutType!
        workoutConfig.locationType = workoutLocation!
        
        //try to create the workout or fail gracefully
        do {
            workoutSession = try HKWorkoutSession.init(configuration: workoutConfig)
            workoutSession?.delegate = self
            startDate = Date()
            sendContext?.startDate = startDate
            healthStore.start(workoutSession!)
        }
        catch {
            //MARK: catch errors here
            
        }
        
        
        updatChangeRate(newRate: -1)
        updateAvg(newAvg: -1)
        
        if isTest {
            startFakeWorkout()
        }
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("\n\nCD: WILL ACTIVATE\n\n")
        
//        container.setBackgroundImageNamed("Frame ")
//        container.startAnimatingWithImages(in: NSRange(location: 1, length: 15), duration: 6, repeatCount: 0)
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func startFakeWorkout() {
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(WorkoutController.fakeProcessing), userInfo: nil, repeats: true)
    }
    
    func fakeProcessing() {
        if sampleHRIndex >= sampleHR.count { sampleHRIndex = 0 }
        
        let hr = sampleHR[sampleHRIndex]
        sampleHRIndex += 1
        
        
        currentTrackedHeartRate = hr
        statsTracker.newDataPoint(hr: hr)
        let avgROC = statsTracker.getAvgRateOfChangeInTimeFrame(start: statsTrackingTimeFrame, end: 0)
        self.updatChangeRate(newRate: avgROC)
        
        let avgHR = statsTracker.getAvgHeartRateInTimeFrame(start: statsTrackingTimeFrame, end: 0)
        self.updateAvg(newAvg: avgHR)
        
        
    }
    
    
    
    @IBAction func endWorkout() {
        healthStore.end(workoutSession!)
    }
    
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
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    
                    if (quantityTypeIdentifier == HKQuantityTypeIdentifier.heartRate) {
                        
                        let hr = sample.quantity.doubleValue(for: strongSelf.heartRateUnit)
                        
                        //set current hr
                        strongSelf.currentTrackedHeartRate = hr
                        
                        //input new data point and get rate of change and average over last 20 seconds
                        strongSelf.statsTracker.newDataPoint(hr: hr)
                        let avgROC = strongSelf.statsTracker.getAvgRateOfChangeInTimeFrame(start: 20, end: 0)
                        strongSelf.updatChangeRate(newRate: avgROC)
                        
                        let avgHR = strongSelf.statsTracker.getAvgHeartRateInTimeFrame(start: 20, end: 0)
                        strongSelf.updateAvg(newAvg: avgHR)
                        
                        

                    }
                }
            }
        }
    }
    
    func checkThresholds(_ hr: Double) {
        // if the timer is still going then dont bother
        if timerOn { return }
        
        if lowestTrackedHeartRate > hr || hr > highestTrackedHeartRate {
            WKInterfaceDevice.current().play(.failure)
            //create timer to timeout in 20 sec. then we will check again. Only notify every 20 seconds
            Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(WorkoutController.turnTimerOff), userInfo: nil, repeats: false)
        }
    }
    
    func turnTimerOff() {
        self.timerOn = false
    }
    
    
    func updateAvg(newAvg: Double) {
        var avgString = "\(newAvg)"
        if avgString.characters.count > 5 {
            let idx = avgString.index(avgString.startIndex, offsetBy: 4)..<avgString.endIndex
            avgString.removeSubrange(idx)
        }
        self.HRAvg.setText("AVG: " + avgString)
    }
    func updatChangeRate(newRate: Double) {
        if newRate < 0 {
            self.HRRate.setTextColor(UIColor.red())
        } else if newRate > 0 {
            self.HRRate.setTextColor(UIColor.green())
        } else {
            self.HRRate.setTextColor(UIColor.white())
        }
        
        
        var rateString = "\(newRate)"
        if rateString.characters.count > 5 {
            let idx = rateString.index(rateString.startIndex, offsetBy: 4)..<rateString.endIndex
            rateString.removeSubrange(idx)
        }
        self.HRRate.setText("ROC: " + rateString)
    }
    
    override func contextsForSegue(withIdentifier segueIdentifier: String) -> [AnyObject]? {
        print("CD: 1\n\n\n")
        return nil

    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> AnyObject? {
        print("CD: 2\n\n\n")

        return nil

    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        print("CD: 3\n\n\n")

        return nil

    }
    
    override func contextsForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> [AnyObject]? {
        print("CD: 4\n\n\n")

        return nil
    }
    
    
}
extension WorkoutController: HKWorkoutSessionDelegate {
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("Workout session state changed from \(fromState) to \(toState)!")
        if !isTest {
            switch toState {
            case .running:
                startAccumulatingData(startDate: startDate!)
                
            default:
                startAccumulatingData(startDate: startDate!)
                
            }
        }
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        
    }
}
extension String {
}
