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
    
    static var workouts: [(name: String, image: UIImage, type: HKWorkoutActivityType, location: HKWorkoutSessionLocationType)] = [
        (name: "Outdoor Run",
         image: UIImage(named: "OutdoorRunning.png")!,
         type: HKWorkoutActivityType.running,
         location: HKWorkoutSessionLocationType.outdoor),
        (name: "Outdoor Cycling",
         image: UIImage(named: "OutdoorCycling.png")!,
         type: HKWorkoutActivityType.cycling,
         location: HKWorkoutSessionLocationType.outdoor),
        (name: "Indoor Run",
         image: UIImage(named: "IndoorRunning.png")!,
         type: HKWorkoutActivityType.running,
         location: HKWorkoutSessionLocationType.indoor),
        (name: "Indoor Cycling",
         image: UIImage(named: "IndoorCycling.png")!,
         type: HKWorkoutActivityType.cycling,
         location: HKWorkoutSessionLocationType.indoor),
        (name: "Weight Lifting",
         image: UIImage(named: "Weightlifting.png")!,
         type: HKWorkoutActivityType.functionalStrengthTraining,
         location: HKWorkoutSessionLocationType.unknown),
        (name: "Cross Training",
         image: UIImage(named: "CrossFit.png")!,
         HKWorkoutActivityType.crossTraining,
         location: HKWorkoutSessionLocationType.unknown),
        (name: "General Cardio",
         image: UIImage(named: "Pilates.png")!,
         type: HKWorkoutActivityType.mixedMetabolicCardioTraining,
         location: HKWorkoutSessionLocationType.unknown),
        (name: "Mind and Body",
         image: UIImage(named: "Meditating.png")!,
         type: HKWorkoutActivityType.mindAndBody,
         location: HKWorkoutSessionLocationType.unknown),
        (name: "Other",
         image: UIImage(named: "JumpRope.png")!,
         type: HKWorkoutActivityType.other,
         location: HKWorkoutSessionLocationType.unknown)
    ]
    
 }
