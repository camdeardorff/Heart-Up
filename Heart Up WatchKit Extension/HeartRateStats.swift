//
//  HRStats.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/26/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation

func cam(_ s: String) {
    print("\nCD: \(s)")
}


class HeartRateStats {
    
    static let sharedInstance = HeartRateStats()
    
    
    //collection of all data
    private var data = [(hr: Double, atTime: Date)]()
    
    private let segmentTimeLength: Int = 10
    private var segments = [(avgHR: Double, betweenTimes: (start: Date, end: Date))]()
    private var startDate: Date
    
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
        //try to push data for a new segment every ....
        
        
        // check if enough time has passed to create a new segment
        let currentDate = Date()
        cam("Current date: \(currentDate)")
        // if there is any segment right now
        if let lastSegmentRange = segments.last?.betweenTimes {
            // has enough time passed to create a new segment
            if currentDate >= lastSegmentRange.end.addingTimeInterval(TimeInterval(segmentTimeLength)) {
                //find out how many should be made
                let secondsSinceLast = currentDate.seconds(from: lastSegmentRange.end)
                let segmentsToCreate = secondsSinceLast / segmentTimeLength
//                cam("create \(segmentsToCreate) segments!")
                //create all of the segments necessary
                for i in 0..<segmentsToCreate {
                    //interval times Start = endOfLast + i * segmentTimeLength
                    //               end = start + segmentTimeLength
//                    cam("adding segment now!")
                    let start = lastSegmentRange.end.addingTimeInterval(TimeInterval(i * segmentTimeLength))
                    let end = start.addingTimeInterval(TimeInterval(segmentTimeLength))
                    let avg = getAvgHeartRateInTimeFrame(start: start, end: end)
                    cam("adding with avg: \(avg),\n\t start: \(start)\n\t end: \(end)")

                    segments.append((avgHR: avg, betweenTimes: (start: start, end: end)))
                    updateListener?.newSegmentAvailable(data: getRecentSegments())

                }
            }
        } else {
//            cam("should add first segment")
            //check if we have been online for at least one segment
            if currentDate.seconds(from: startDate) >= segmentTimeLength {
                cam("adding first segment now!")
                let start = currentDate.addingTimeInterval(-(Double)(segmentTimeLength))
                let end = currentDate
                let avg = getAvgHeartRateInTimeFrame(start: start, end: end)
                cam("adding with avg: \(avg),\n\t start: \(start)\n\t end: \(end)")
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
        
        let dataInTimeFrame = getDataInTimeFrame(fromSecondsAgo: start, toSecondsAgo: end)
        var totalSlope: Double = 0
        var slopes = 0
        for i in 0..<dataInTimeFrame.count-1 {
            let prev = dataInTimeFrame[i]
            let curr = dataInTimeFrame[i+1]
            totalSlope += (curr.hr - prev.hr)
            slopes += 1
        }
        return totalSlope / Double(slopes)
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
        //MARK: TODO: What if count is zero? nan?
        return hrSum / Double(dataInTimeFrame.count)
    }
    func getAvgHeartRateInTimeFrame(start: Date, end: Date) -> Double {
        
        let dataInTimeFrame = getDataInTimeFrame(start: start, end: end)
        var hrSum: Double = 0
        for point in dataInTimeFrame {
            hrSum += point.hr
        }
        //MARK: TODO: What if count is zero? nan?
        return hrSum / Double(dataInTimeFrame.count)
    }
    
    
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
            data.append(seg.avgHR)
        }
        
        
        
        
        cam("Grabbing \(data.count) data points")
        /////////
        return data
    }
    
}

protocol HeartRateUpdatesDelegate {
    func newSegmentAvailable(data: [NSNumber])
}


extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.components(.year, from: date, to: self, options: []).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.components(.month, from: date, to: self, options: []).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.components(.weekOfYear, from: date, to: self, options: []).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.components(.day, from: date, to: self, options: []).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.components(.hour, from: date, to: self, options: []).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.components(.minute, from: date, to: self, options: []).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.components(.second, from: date, to: self, options: []).second ?? 0
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

