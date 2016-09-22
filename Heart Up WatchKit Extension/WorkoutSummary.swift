//
//  WorkoutSummary.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 9/14/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation
import RealmSwift


class Workout: Object {
    static let UNSET_VALUE = -1
    static let UNSET_DATE = Date(timeIntervalSince1970: 0)
    dynamic var type: Int = UNSET_VALUE
    dynamic var location: Int = UNSET_VALUE
    
    
    
    dynamic var intensity: Int = UNSET_VALUE
    
    dynamic  var levelLow = UNSET_VALUE
    dynamic  var levelHigh = UNSET_VALUE
    
    dynamic var max: Int = UNSET_VALUE
    dynamic var min: Int = UNSET_VALUE
    
    dynamic var avg: Int = UNSET_VALUE
    dynamic var time: TimeInterval = TimeInterval(UNSET_VALUE)
    dynamic var start: Date = UNSET_DATE
    dynamic var end: Date = UNSET_DATE
//    dynamic var data = [(avgHR: Double, betweenTimes: (start: Date, end: Date))]()
    
    dynamic var configIndex: Int = UNSET_VALUE
    
}

