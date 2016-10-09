//
//  WorkoutSummary.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 9/14/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Segment: Object {
    dynamic var averageHR: Double = -1
    dynamic var date: Date = Date(timeIntervalSince1970: 0)
}

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
    let data = List<Segment>()
    
    dynamic var configIndex: Int = UNSET_VALUE
    


    
    func importSettings(settings : [String : Any]) {
        
        self.type = settings["type"] as! Int
        self.location = settings["location"] as! Int
        self.intensity = settings["intensity"] as! Int
        self.levelLow = settings["levelLow"] as! Int
        self.levelHigh = settings["levelHigh"] as! Int
        self.max = settings["max"] as! Int
        self.min = settings["min"] as! Int
        self.avg = settings["avg"] as! Int
        self.time = settings["time"] as! TimeInterval
        self.start = settings["start"] as! Date
        self.end = settings["end"] as! Date
        self.configIndex = settings["configIndex"] as! Int
//        for segment in tw.data {
//            data.append(segment)
//        }
    }
    
    
    func exportSettings() -> [String : Any] {
        var export = [String : Any]()
        export["type"] = self.type
//        export["location"] = self.location
//        export["intensity"] = self.intensity
//        export["levelLow"] = self.levelLow
//        export["levelHigh"] = self.levelHigh
//        export["max"] = self.max
//        export["min"] = self.min
//        export["avg"] = self.avg
//        export["time"] = self.time
//        export["start"] = self.start
//        export["end"] = self.end
//        export["configIndex"] = self.configIndex
        return export
    }
}

//struct TransferableWorkout {
//
//    var type: Int
//    var location: Int
//    var intensity: Int
//    var level: (low: Int, high: Int)
//    var hr: (min: Int, max: Int, avg: Int)
//    var time: TimeInterval
//    var dates: (start: Date, end: Date)
//    var data: [Segment]
//    var configIdx: Int
//    
//}

//
// This worked but in the end it was unnecessary
//extension Array {
//    func toList<T: Object>() -> List<T> {
//        let list = List<T>()
//        for e in self {
//            list.append((e as! Object) as! T)
//        }
//        return list
//    }
//}
//
//
