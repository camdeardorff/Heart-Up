//
//  IntensityLevel.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 11/26/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation


class Intensity {
    enum levels: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case custom = "Custom"
    }
    
    static let ALL_LEVELS: [levels] = [.low, .medium, .high, .custom]
    var level: levels
    var hrRange: (min: Int, max: Int)
    
    init(level: levels, age: Int) {
        self.level = level
        self.hrRange = (0,0)
        let range = getHeartRate(withLevel: level, atAge: age)
        self.hrRange = (range.min, range.max)
    }
    
    /**
     # Get Heart Rate
     calculates the heart rate range at a level, with an age
     - Parameter level: intensity level.
     - Parameter atAge: age of person to calculate target heart rates with.
     - Returns: Tuple: (min, max) heart rates
     */
    func getHeartRate(withLevel level: levels, atAge age: Int) -> (min: Int, max: Int) {
        switch level {
        case .low:
            return (Int(Double(220 - age) * 0.3), Int(Double(220 - age) * 0.5))
        case .medium:
            return (Int(Double(220 - age) * 0.5), Int(Double(220 - age) * 0.7))
        case .high:
            return (Int(Double(220 - age) * 0.7), Int(Double(220 - age) * 0.9))
        case .custom:
            return (0,0)
        }
    }
}
