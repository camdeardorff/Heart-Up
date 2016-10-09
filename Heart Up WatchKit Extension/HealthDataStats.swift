//
//  HRStats.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/26/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation


class HealthDataStats {
    
    static let sharedInstance = HealthDataStats()
    
    
    //collection of all data
    private var data = [(hr: Double, atTime: Date)]()
    
    private let segmentTimeLength: Int = 10
    private var segments = [(avgHR: Double, betweenTimes: (start: Date, end: Date))]()
    private var startDate: Date
    
    
    private var min: Double = -1
    private var max: Double = -1
    
    var levelHigh: Int?
    var levelLow: Int?
    
    var updateListener: HeartRateUpdatesDelegate?
    private init() {
        startDate = Date()
    }
    
    /**
     # New Data Point
     creates a new entry for keeping a heart rate at a current time
     - Parameter hr: heart rate to keep track of.
     - Returns: void
     */
    func newDataPoint(hr: Double) {
        data.append((hr: hr, atTime: Date()))
        
        if hr > max || max == -1 { max = hr }
        if hr < min || min == -1 { min = hr }
        
        
        // check if enough time has passed to create a new segment
        let currentDate = Date()
        // if there is any segment right now
        if let lastSegmentRange = segments.last?.betweenTimes {
            // has enough time passed to create a new segment
            if currentDate >= lastSegmentRange.end.addingTimeInterval(TimeInterval(segmentTimeLength)) {
                //find out how many should be made
                let secondsSinceLast = currentDate.seconds(from: lastSegmentRange.end)
                let segmentsToCreate = secondsSinceLast / segmentTimeLength
                //create all of the segments necessary
                for i in 0..<segmentsToCreate {
                    
                    let start = lastSegmentRange.end.addingTimeInterval(TimeInterval(i * segmentTimeLength))
                    let end = start.addingTimeInterval(TimeInterval(segmentTimeLength))
                    let avg = getAvgHeartRateInTimeFrame(start: start, end: end)
                    
                    segments.append((avgHR: avg, betweenTimes: (start: start, end: end)))
                    updateListener?.newSegmentAvailable(data: getRecentSegments())
                    
                }
            }
        } else {
            //check if we have been online for at least one segment
            if currentDate.seconds(from: startDate) >= segmentTimeLength {
                let start = currentDate.addingTimeInterval(-(Double)(segmentTimeLength))
                let end = currentDate
                let avg = getAvgHeartRateInTimeFrame(start: start, end: end)
                segments.append((avgHR: avg, betweenTimes: (start: start, end: end)))
                updateListener?.newSegmentAvailable(data: getRecentSegments())
            }
            //otherwise do nothing
        }
        
    }
    
    
    /**
     # Get Average Rate Of Change In Time Frame
     returns the numerical average heart rate of change between two times
     - Parameter start: predated most limit of the data set.
     - Parameter end: postdated most limit of the data set
     - Returns: Double
     */
    func getAvgRateOfChangeInTimeFrame(start: Double, end: Double) -> Double {
        
        //get all of the data points in the time frame given... could be none
        let dataInTimeFrame = getDataInTimeFrame(fromSecondsAgo: start, toSecondsAgo: end)
        var totalSlope: Double = 0
        var slopes = 0
        for i in 0..<dataInTimeFrame.count-1 {
            let prev = dataInTimeFrame[i]
            let curr = dataInTimeFrame[i+1]
            totalSlope += (curr.hr - prev.hr)
            slopes += 1
        }
        
        if slopes > 0 && totalSlope / Double(slopes) != Double.nan {
            return totalSlope / Double(slopes)
        } else {
            return 0
        }
    }
    
    
    /**
     # Get Average Heart Rate In Time Frame
     returns the numerical average heart rate between two times
     - Parameter start: predated most limit of the data set.
     - Parameter end: postdated most limit of the data set
     - Returns: Double
     */
    func getAvgHeartRateInTimeFrame(start: Double, end: Double) -> Double {
        
        let dataInTimeFrame = getDataInTimeFrame(fromSecondsAgo: start, toSecondsAgo: end)
        var hrSum: Double = 0
        for point in dataInTimeFrame {
            hrSum += point.hr
        }
        
        if dataInTimeFrame.count > 0 && hrSum / Double(dataInTimeFrame.count) != Double.nan {
            return hrSum / Double(dataInTimeFrame.count)
        } else {
            return 0
        }
        
    }
    func getAvgHeartRateInTimeFrame(start: Date, end: Date) -> Double {
        
        let dataInTimeFrame = getDataInTimeFrame(start: start, end: end)
        var hrSum: Double = 0
        for point in dataInTimeFrame {
            hrSum += point.hr
        }
        
        if dataInTimeFrame.count > 0 && hrSum / Double(dataInTimeFrame.count) != Double.nan {
            return hrSum / Double(dataInTimeFrame.count)
        } else {
            return 0
        }    }
    
    
    /**
     # Get Data In Time Frame
     loops over each data point and grabs anything that has a date that falls between the start and end points
     - Parameter fromSecondsAgo: how far into the past to grab data.
     - Parameter toSecondsAgo: how recent into the past to grab data.
     - Returns: [(hr: Double, atTime: Date)
     */
    func getDataInTimeFrame(fromSecondsAgo: Double, toSecondsAgo: Double) -> [(hr: Double, atTime: Date)] {
        let startTime = Date(timeIntervalSinceNow: -fromSecondsAgo)
        let endTime = Date(timeIntervalSinceNow: -toSecondsAgo)
        
        return getDataInTimeFrame(start: startTime, end: endTime)
    }
    func getDataInTimeFrame(start: Date, end: Date) -> [(hr: Double, atTime: Date)] {
        var matchingData = [(hr: Double, atTime: Date)]()
        
        //check to if the limits are out of order -- they dont make sense
        if start > end { return matchingData }
        
        //loop over all of the data
        for point in data {
            // start | data point | end
            if start <= point.atTime && point.atTime < end {
                matchingData.append(point)
            }
        }
        return matchingData
    }
    
    //export data to graph
    
    func getRecentSegments() -> [NSNumber] {
        let recentSegments = segments.suffix(10)
        var data = [NSNumber]()
        for seg in recentSegments {
            data.append(NSNumber(integerLiteral: Int(seg.avgHR)))
        }
        
        return data
    }
    
    func getTargetPercentages() -> (below: Double, on: Double, above: Double)? {
        if let lli = levelLow {
            if let lhi = levelHigh {
                let lld = Double(lli)
                let lhd = Double(lhi)
                
                var below: Double = 0
                var on: Double = 0
                var above: Double = 0

                
                for segment in segments {
                    //lower than the lower level
                    if segment.avgHR < lld {
                        below += 1
                    }
                    // higher than the higher level
                    else if segment.avgHR > lhd {
                        above += 1
                    }
                    // in the middle
                    else {
                        on += 1
                    }
                }
                
                let total = Double(segments.count)
                
                return (below/total, on/total, above/total)
                
            }
        }
        return nil
    }
    
    func exportData() -> (min: Int, max: Int, avg: Int, data: [Segment], percentages: (below: Double, on: Double, above: Double)?, time: TimeInterval, start: Date, end: Date) {
        print("start export data")
        let start = self.startDate
        let end = Date()
        let min = Int(self.min)
        let max = Int(self.max)
        let avg = Int(getAvgHeartRateInTimeFrame(start: start, end: end))
        let time = end.timeIntervalSince(start)
        let data = segments
        
        var segmentData: [Segment] = []
        
        print("loop over data")
        //turn data into Segment objects
        for point in data {
            
            let s = Segment()
            s.averageHR = point.avgHR
            s.date = point.betweenTimes.end
            segmentData.append(s)
        }
        
        print("get segments")
        let percents = self.getTargetPercentages()
        print("return" )
        return (min, max, avg, segmentData, percents, time, start, end)
        
    }
    
}

protocol HeartRateUpdatesDelegate {
    func newSegmentAvailable(data: [NSNumber])
}


extension Date {
    
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
        
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
