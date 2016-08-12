//
//  WorkoutConfig.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 8/3/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation
import HealthKit


class WorkoutConfig: AnyObject {
    var workoutType: (name: String, emoji: String, type: HKWorkoutActivityType, location: HKWorkoutSessionLocationType, intensities: [(level: String, min: Int, max: Int)])?
    var workoutIntesity: (level: String, min: Int, max: Int)?
    
    
//    var hrLowerLimit: Int?
//    var hrUpperLimit: Int?
    
    var sentFromControllerNamed: String = ""
    
    var startDate: Date?
    //var intensity: (level: String, min: Int, max: Int)?
}



class ApplicationData {
    ///TODO: set to unknown location for some of these?
    static var workouts: [(name: String, emoji: String, type: HKWorkoutActivityType, location: HKWorkoutSessionLocationType, intensities: [(level: String, min: Int, max: Int)])] = [
        (name: "Outdoor Run",
         emoji: "🏃🏼",
         type: HKWorkoutActivityType.running,
         location: HKWorkoutSessionLocationType.outdoor,
         intensities: [(level: "Low",
                        min: 80,
                        max: 100),
                       (level: "Med",
                        min: 100,
                        max: 130),
                       (level: "High",
                        min: 130,
                        max: 160)
            ]
        ),
        (name: "Outdoor Cycling",
         emoji: "🚴",
         type: HKWorkoutActivityType.cycling,
         location: HKWorkoutSessionLocationType.outdoor,
         intensities: [(level: "Low",
                        min: 80,
                        max: 100),
                       (level: "Med",
                        min: 100,
                        max: 130),
                       (level: "High",
                        min: 130,
                        max: 160)
            ]
            
        ),
        (name: "Indoor Run",
         emoji: "🏃🏼",
         type: HKWorkoutActivityType.running,
         location: HKWorkoutSessionLocationType.indoor,
         intensities: [(level: "Low",
                        min: 80,
                        max: 100),
                       (level: "Med",
                        min: 100,
                        max: 130),
                       (level: "High",
                        min: 130,
                        max: 160)
            ]
        ),
        (name: "Indoor Cycling",
         emoji: "🚴",
         type: HKWorkoutActivityType.cycling,
         location: HKWorkoutSessionLocationType.indoor,
         intensities: [(level: "Low",
                        min: 80,
                        max: 100),
                       (level: "Med",
                        min: 100,
                        max: 130),
                       (level: "High",
                        min: 130,
                        max: 160)
            ]
        ),
        (name: "Lifting",
         emoji: "💪🏼",
         type: HKWorkoutActivityType.functionalStrengthTraining,
         location: HKWorkoutSessionLocationType.unknown,
         intensities: [(level: "Low",
                        min: 80,
                        max: 100),
                       (level: "Med",
                        min: 100,
                        max: 130),
                       (level: "High",
                        min: 130,
                        max: 160)
            ]
        ),
        (name: "Cross Training",
         emoji: "🏋🏼",
         HKWorkoutActivityType.crossTraining,
         location: HKWorkoutSessionLocationType.unknown,
         intensities: [(level: "Low",
                        min: 80,
                        max: 100),
                       (level: "Med",
                        min: 100,
                        max: 130),
                       (level: "High",
                        min: 130,
                        max: 160)
            ]
        ),
        (name: "General Cardio",
         emoji: "🏅", type: HKWorkoutActivityType.mixedMetabolicCardioTraining,
         location: HKWorkoutSessionLocationType.unknown,
         intensities: [(level: "Low",
                        min: 80,
                        max: 100),
                       (level: "Med",
                        min: 100,
                        max: 130),
                       (level: "High",
                        min: 130,
                        max: 160)
            ]
        ),
        (name: "Mind and Body",
         emoji: "🌸",
         type: HKWorkoutActivityType.mindAndBody,
         location: HKWorkoutSessionLocationType.unknown,
         intensities: [(level: "Low",
                        min: 80,
                        max: 100),
                       (level: "Med",
                        min: 100,
                        max: 130),
                       (level: "High",
                        min: 130,
                        max: 160)
            ]
        ),
        (name: "Other",
         emoji: "",
         type: HKWorkoutActivityType.other,
         location: HKWorkoutSessionLocationType.unknown,
         intensities: [(level: "Low",
                        min: 80,
                        max: 100),
                       (level: "Med",
                        min: 100,
                        max: 130),
                       (level: "High",
                        min: 130,
                        max: 160)
            ]
        )
    ]
    
}
