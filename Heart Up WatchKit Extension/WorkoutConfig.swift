//
//  WorkoutConfig.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 8/3/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation
import HealthKit





struct ApplicationData {
    
//    let age: Int? = 30
//    
//    func getIntensities() -> [(level: String, min: Int, max: Int)] {
//        if let _ = age {
//            let
//        } else {
//            
//        }
//    }
//    
//    func getHeartRates(lowerPercent: Double, upperPercent: Double) -> (min: Int, max: Int) {
//        if let _ = age {
//            let min = Int(Double(220 - age!) * lowerPercent)
//            let max = Int(Double(220 - age!) * upperPercent)
//        } else {
//            let min =
//        }
//    }
    
    
    ///TODO: set to unknown location for some of these?
    static var workouts: [(name: String, image: UIImage, type: HKWorkoutActivityType, location: HKWorkoutSessionLocationType, intensities: [(level: String, min: Int, max: Int)])] = [
        (name: "Outdoor Run",
         image: UIImage(named: "OutdoorRunning.png")!,
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
                        max: 160),
                       (level: "Custom",
                        min: 0,
                        max: 0)
            ]
        ),
        (name: "Outdoor Cycling",
         image: UIImage(named: "OutdoorCycling.png")!,
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
                        max: 160),
                       (level: "Custom",
                        min: 0,
                        max: 0)
            ]
            
        ),
        (name: "Indoor Run",
         image: UIImage(named: "IndoorRunning.png")!,
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
                        max: 160),
                       (level: "Custom",
                        min: 0,
                        max: 0)
            ]
        ),
        (name: "Indoor Cycling",
         image: UIImage(named: "IndoorCycling.png")!,
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
                        max: 160),
                       (level: "Custom",
                        min: 0,
                        max: 0)
            ]
        ),
        (name: "Weight Lifting",
         image: UIImage(named: "Weightlifting.png")!,
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
                        max: 160),
                       (level: "Custom",
                        min: 0,
                        max: 0)
            ]
        ),
        (name: "Cross Training",
         image: UIImage(named: "CrossFit.png")!,
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
                        max: 160),
                       (level: "Custom",
                        min: 0,
                        max: 0)
            ]
        ),
        (name: "General Cardio",
         image: UIImage(named: "Pilates.png")!,
         type: HKWorkoutActivityType.mixedMetabolicCardioTraining,
         location: HKWorkoutSessionLocationType.unknown,
         intensities: [(level: "Low",
                        min: 80,
                        max: 100),
                       (level: "Med",
                        min: 100,
                        max: 130),
                       (level: "High",
                        min: 130,
                        max: 160),
                       (level: "Custom",
                        min: 0,
                        max: 0)
            ]
        ),
        (name: "Mind and Body",
         image: UIImage(named: "Meditating.png")!,
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
                        max: 160),
                       (level: "Custom",
                        min: 0,
                        max: 0)
            ]
        ),
        (name: "Other",
         image: UIImage(named: "JumpRope.png")!,
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
                        max: 160),
                       (level: "Custom",
                        min: 0,
                        max: 0)
            ]
        )
    ]
    
}
