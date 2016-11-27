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




struct Workout {
    
    var type: Int
    var location: Int
    var intensity: Int
    
    var levels: (low: Int, high: Int)
    var time: (start: Date, end: Date, length: TimeInterval)
    var heartRate: (min: Int, max: Int, avg: Int)
    var data: [(averageHR: Double, atTime: Date)]
    
    var configIndex: Int
    
    init() {
        type = -1
        location = -1
        intensity = -1
        levels.low = -1
        levels.high = -1
        heartRate.max = -1
        heartRate.min = -1
        heartRate.avg = -1
        time.length = -1
        time.start = Date(timeIntervalSince1970: 0)
        time.end =  Date(timeIntervalSince1970: 0)
        configIndex = -1
        data = []
    }
    
   
    
    init(dbWorkout: DBWorkout) {
        print("init with db workout: ", dbWorkout)
        
        type = dbWorkout.type
        location = dbWorkout.location
        intensity = dbWorkout.intensity
        levels.low = dbWorkout.levelLow
        levels.high = dbWorkout.levelHigh
        heartRate.max = dbWorkout.max
        heartRate.min = dbWorkout.min
        heartRate.avg = dbWorkout.avg
        time.length = dbWorkout.time
        time.start = dbWorkout.start
        time.end =  dbWorkout.end
        configIndex = dbWorkout.configIndex
        data = []
        dbWorkout.data.forEach { (segment) in
            data.append((segment.averageHR, segment.date))
        }

        print("data produced: ", self.data)
        
    }
    
    
    init(data: [String : Any]) {
        type = data["type"] as! Int
        location = data["location"] as! Int
        intensity = data["intensity"] as! Int
        levels.low = data["levelLow"] as! Int
        levels.high = data["levelHigh"] as! Int
        heartRate.max = data["max"] as! Int
        heartRate.min = data["min"] as! Int
        heartRate.avg = data["avg"] as! Int
        time.length = data["time"] as! TimeInterval
        time.start = data["start"] as! Date
        time.end = data["end"] as! Date
        configIndex = data["configIndex"] as! Int
        self.data = []
        
        print("importing data: ", data)
        
        let dataDict = data["data"] as! [Any]
        for dataPoint in dataDict {
            print("looping data point: ", dataPoint)
            let dp = dataPoint as! [String : Any]
            let avgHR = dp["avg"] as! Double
            let time = dp["atTime"] as! Date
            self.data.append((avgHR, time))
        }
        
    }
    
    func export() -> [String : Any] {
        var export = [String : Any]()
        export["type"] = type
        export["location"] = location
        export["intensity"] = intensity
        export["levelLow"] = levels.low
        export["levelHigh"] = levels.high
        export["max"] = heartRate.max
        export["min"] = heartRate.min
        export["avg"] = heartRate.avg
        export["time"] = time.length
        export["start"] = time.start
        export["end"] = time.end
        export["configIndex"] = configIndex
        
        var dataDict = [Any]()
        for point in data {
            var pointDict = [String: Any]()
            pointDict["avg"] = point.averageHR
            pointDict["atTime"] = point.atTime
            dataDict.append(pointDict)
        }
        export["data"] = dataDict
        
        return export
    }
}



class DBSegment: Object {
    dynamic var averageHR: Double = -1
    dynamic var date: Date = Date(timeIntervalSince1970: 0)
}

class DBWorkout: Object {
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
    let data = List<DBSegment>()
    
    dynamic var configIndex: Int = UNSET_VALUE
    
    
    func importSettings(workout: Workout) {
        print("dbw 1")
        
        type = workout.type
        location = workout.location
        intensity = workout.intensity
        levelLow = workout.levels.low
        levelHigh = workout.levels.high
        max = workout.heartRate.max
        min = workout.heartRate.min
        avg = workout.heartRate.avg
        time = workout.time.length
        start = workout.time.start
        end = workout.time.end
        configIndex = workout.configIndex
        
        for point in workout.data {
            let seg = DBSegment()
            seg.averageHR = point.averageHR
            seg.date = point.atTime
            data.append(seg)
        }
    }
}
