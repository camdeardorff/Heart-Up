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
    
    //segment infomation
    private let segmentTimeLength: Int = 10
    private var segments = [(avgHR: Double, betweenTimes: (start: Date, end: Date))]()
    
    private var startDate: Date
    
    //minimum and maximum heart rate sample
    private var min: Double = -1
    private var max: Double = -1
    
    // heart rate target zone inidcators
    var levelHigh: Int?
    var levelLow: Int?
    
    //update delegate
    var updateListener: HeartRateUpdatesDelegate?
    
    private init() {
        startDate = Date()
    }
    
    /**
     # Reset
     Reset statistics for another round
     - Returns: void
     */
    func reset() {
        data.removeAll()
        segments.removeAll()
        startDate = Date()
        min = -1
        max = -1
        levelHigh = nil
        levelLow = nil
        updateListener = nil
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
                    
                    /* sometimes there are no data oints found. This is unsettling for the linegraph and such. The soluction is to not allow avg that dont seem to fit the others, but when a user takes off the watch the same condition occurs. We cannot differentiate between the sampleing rate beeing to low or theuser taking off the watch. the resolution is to throw out the ssegment if the average is 0. This way we can handle only good data
                    */
                    
                    if avg > 0.0 {
                        segments.append((avgHR: avg, betweenTimes: (start: start, end: end)))
                        updateListener?.newSegmentAvailable(data: getLastNAverages(n: 10))
                    }
                    
                    
                }
            }
        } else {
            //check if we have been online for at least one segment
            if currentDate.seconds(from: startDate) >= segmentTimeLength {
                let start = currentDate.addingTimeInterval(-(Double)(segmentTimeLength))
                let end = currentDate
                let avg = getAvgHeartRateInTimeFrame(start: start, end: end)
                segments.append((avgHR: avg, betweenTimes: (start: start, end: end)))
                updateListener?.newSegmentAvailable(data: getLastNAverages(n: 10))
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
        let dataInTimeFrame = getDataInTimeFrame(secondsFrom: start, secondsTo: end)
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
     # (OVERLOADED) Get Average Heart Rate In Time Frame
     returns the numerical average heart rate between two times
     - Parameter secondsFrom: predated most limit of the data set in seconds.
     - Parameter end: postdated most limit of the data set in seconds
     - Returns: Double
     */
    func getAvgHeartRateInTimeFrame(secondsFrom: Double, secondsTo: Double) -> Double {
        
        return getAvgHeartRateInTimeFrame(start: Date(timeIntervalSinceNow: -secondsFrom),
                                          end: Date(timeIntervalSinceNow: -secondsTo))
    }
    
    /**
     # (OVERLOADED) Get Average Heart Rate In Time Frame
     returns the numerical average heart rate between two times
     - Parameter start: predated most limit of the data set.
     - Parameter end: postdated most limit of the data set
     - Returns: Double
     */
    func getAvgHeartRateInTimeFrame(start: Date, end: Date) -> Double {
        
        let dataInTimeFrame = getDataInTimeFrame(start: start, end: end)
        var hrSum: Double = 0
        for point in dataInTimeFrame {
            hrSum += point.hr
        }
        
        if dataInTimeFrame.count > 0 && hrSum / Double(dataInTimeFrame.count) != Double.nan {
            return hrSum / Double(dataInTimeFrame.count)
        } else {
            print("BLOB: average heart rate is being called 0. the real issue: ")
            if dataInTimeFrame.count < 1 {
                print("there were no samples")
            } else if hrSum / Double(dataInTimeFrame.count) == Double.nan {
                print("average was nan")
            }
            return 0
        }
    }
    
    func getDataInTimeFrame(secondsFrom: Double, secondsTo: Double) -> [(hr: Double, atTime: Date)] {
        return getDataInTimeFrame(start: Date(timeIntervalSinceNow: -secondsFrom),
                                          end: Date(timeIntervalSinceNow: -secondsTo))
    }
    
    /**
     # Get Data In Time Frame
     loops over each data point and grabs anything that has a date that falls between the start and end points
     - Parameter start: how far into the past to grab data.
     - Parameter end: how recent into the past to grab data.
     - Returns: [(hr: Double, atTime: Date)
     */
    
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
    
    /**
     # Get Last N Averages
     returns the list of recent averages of n length or however many there are if n is larger than the length of the collection of averages
     - Parameter n: (Int) how many averages to return.
     - Returns: [NSNumber]
     */
    func getLastNAverages(n: Int) -> [NSNumber] {
        let spots = abs(n)
        let recentSegments = segments.suffix(spots)
        var averages = [NSNumber]()
        for seg in recentSegments {
            averages.append(NSNumber(integerLiteral: Int(seg.avgHR)))
        }
        
        return averages
    }
    
    
    /**
     # Get Target Percentages
     calculate the percent of the time the user was above, on, or below target
     - Returns: (below: Double, on: Double, above: Double)
     */
    func getTargetPercentages() -> (below: Double, on: Double, above: Double)? {
        guard let lowerBound = levelLow else { return nil }
        guard let upperBound = levelHigh else { return nil }
        
        // if there are no segments the there should be no target percentages
        if segments.count < 1 {
            return nil
        } else {
            // vars to count target hits
            var below: Double = 0
            var on: Double = 0
            var above: Double = 0
            
            //loop over segments and count hits
            for segment in segments {
                if segment.avgHR < Double(lowerBound) {         //lower than the lower level
                    below += 1
                } else if segment.avgHR > Double(upperBound) {  // higher than the higher level
                    above += 1
                } else {                                        // in the middle
                    on += 1
                }
            }
            //number of segments
            let total = Double(segments.count)
            return (zeroOrPercent(num: below, total: total),
                    zeroOrPercent(num: on, total: total),
                    zeroOrPercent(num: above, total: total))
        }
    }
    
    /**
     # Zero or Percent
     helper to calculate target percentages. returns the percent or zero... never nan
     - Parameter num: (Double) hits on a target.
     - Parameter total: (Double) total hits.
     - Returns: Double
     */
    private func zeroOrPercent(num: Double, total: Double) -> Double {
        if num > 0 && (num / total) != Double.nan {
            return num / total
        } else {
            return 0.0
        }
    }
    
    
    /**
     # Export Data
     gathers all statistical data necessary for storage and transfer and sends it out
     - Returns: (min: Int, max: Int, avg: Int, data: [Segment], percentages: (below: Double, on: Double, above: Double)?, time: TimeInterval, start: Date, end: Date)
     */
    func exportData() -> (min: Int, max: Int, avg: Int, data: [Segment], percentages: (below: Double, on: Double, above: Double)?, time: TimeInterval, start: Date, end: Date) {
        let start = self.startDate
        let end = Date()
        let min = Int(self.min)
        let max = Int(self.max)
        let avg = Int(getAvgHeartRateInTimeFrame(start: start, end: end))
        let time = end.timeIntervalSince(start)
        let data = segments
        
        var segmentData: [Segment] = []
        
        //turn data into Segment objects
        for point in data {
            let s = Segment()
            s.averageHR = point.avgHR
            s.date = point.betweenTimes.end
            segmentData.append(s)
        }
        
        let percents = self.getTargetPercentages()
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
