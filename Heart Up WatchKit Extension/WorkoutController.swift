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
    
    //LABELS
    @IBOutlet var currentHRLabel: WKInterfaceLabel!
    @IBOutlet var rateOfChangeLabel: WKInterfaceLabel!
    @IBOutlet var timerLabel: WKInterfaceTimer!
    @IBOutlet var caloriesLabel: WKInterfaceLabel!
    @IBOutlet var heartImageContainer: WKInterfaceGroup!
    
    var startDate: Date?
    
    //tracking vars...
    var currentTrackedHeartRate: Double = -1 {
        didSet {
            if currentTrackedHeartRate > -1 { //the normal set
                self.currentHRLabel.setText("\(Int(currentTrackedHeartRate))")
                self.checkThresholds(currentTrackedHeartRate)
            } else { //this label has never been set
                self.currentHRLabel.setText("--")
            }
        }
    }
    var currentRateOfChange: Double = 0 {
        didSet {
            if currentRateOfChange > 0 { // Positive Rate of change
                self.rateOfChangeLabel.setTextColor(UIColor.green)
                self.rateOfChangeLabel.setText("⬆︎")
            } else if currentRateOfChange < 0 { //negative rate of change
                self.rateOfChangeLabel.setTextColor(UIColor.red)
                self.rateOfChangeLabel.setText("⬇︎")
            } else { //break even
                self.rateOfChangeLabel.setTextColor(UIColor.white)
                self.rateOfChangeLabel.setText("-")
            }
        }
    }
    var currentTrackedCalories: Double = -1 {
        didSet {
            self.caloriesLabel.setText("\(Int(currentTrackedCalories / 1000)) cal")
        }
    }
    
    
    //limit constants
    var minimumHeartRate: Double = -1.0
    var maximumHeartRate: Double = -1.0
    
    //workout config
    var workoutLocation: HKWorkoutSessionLocationType? = .unknown
    var workoutType: HKWorkoutActivityType? = .other
    
    //stats tracking
    let statsTrackingTimeFrame:Double = 15
    var statsTracker = HealthDataStats.sharedInstance
    
    //notification timer
    var timerOn = false
    var notificationInterval: TimeInterval = 20
    
    //workout config
    var workout: Workout?
    
    // heart rate streaming obj
    var healthData = HealthDataInterface.shared
    
    
    override func awake(withContext context: Any?) {
        
        super.awake(withContext: context)
        workout = context as? Workout

        print("workout selection controller awake with workout: ", workout!)

        //get context as workout config
        
        //set data
        if let _ = workout {
            minimumHeartRate = Double((workout!.levels.low))
            maximumHeartRate = Double((workout!.levels.high))
            
            //set workout and location type for workout configuration
            workoutType = HKWorkoutActivityType(rawValue: UInt((workout!.type))) ?? .other
            workoutLocation = HKWorkoutSessionLocationType(rawValue: (workout!.location)) ?? .unknown
        }
        
        //start the workout
        startWorkout()
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        setAnimationToHeartRate(hr: currentTrackedHeartRate)
    }
    
    
    /**
     # Start Workout
     starts the workout by configuring the workout session and starting the healthData queries
     - Returns: void
     */
    func startWorkout() {
        
        //create configuration
        let workoutConfig = HKWorkoutConfiguration()
        workoutConfig.activityType = workoutType!
        workoutConfig.locationType = workoutLocation!
        
        //prepare the health stream and start queries with configuration
        healthData.reset()
        //set the health data delegate here and start queries
        healthData.delegate = self
        healthData.startQueries(workoutConfig: workoutConfig, isTest: false)
        
        //reset the stats tracker
        statsTracker.reset()
        //give the target range to stats tracker to determine performance
        statsTracker.levelHigh = Int(maximumHeartRate)
        statsTracker.levelLow = Int(minimumHeartRate)
        
        //start the timer label
        timerLabel.start()
        
    }
    
    
    func setAnimationToHeartRate(hr: Double) {
        //bla bla bla do stuff here
        //container.setBackgroundImageNamed("Frame ")
        //container.startAnimatingWithImages(in: NSRange(location: 1, length: 15), duration: 6, repeatCount: 0)
    }
    
    
    func checkThresholds(_ hr: Double) {
        // if the timer is still going then dont bother
        if timerOn { return }
        //check if we should notify the user that they are out of thier range
        if minimumHeartRate > hr || hr > maximumHeartRate {
            timerOn = true
            //need to differentiate the over and under range notificaitons
            WKInterfaceDevice.current().play(.failure)
            //create timer to timeout in 20 sec. then we will check again. Only notify every 20 seconds
            Timer.scheduledTimer(timeInterval: notificationInterval, target: self, selector: #selector(WorkoutController.turnNotificationTimerOff), userInfo: nil, repeats: false)
        }
    }
    
    
    //turns off the timer boolean. allows the user to be notified again
    func turnNotificationTimerOff() {
        self.timerOn = false
    }
}


extension WorkoutController: HeartRateInterfaceUpdateDelegate {
    func newHeartRateSample(hr: Double) {
        
        currentTrackedHeartRate = hr
        statsTracker.newDataPoint(hr: hr)
        currentRateOfChange = statsTracker.getAvgRateOfChangeInTimeFrame(start: statsTrackingTimeFrame, end: 0)
    }
    
    func newCalorieSum(cals: Double) {
        print("new calorue sum!")
        currentTrackedCalories = cals
    }
}
