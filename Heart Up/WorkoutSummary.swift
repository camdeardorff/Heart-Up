//
//  WorkoutSummaryViewController.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 10/11/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import UIKit
import Charts

class WorkoutSummary: UIViewController {
    
    var workout: Workout?
    
    @IBOutlet var workoutLabel: UILabel!
    @IBOutlet var workoutImage: UIImageView!
    
    @IBOutlet var lineChartView: LineChartView!
    
    
    override func viewDidLoad() {
        
        if let wkt = workout {
            workoutImage.image = ApplicationData.workouts[wkt.configIndex].image
            workoutLabel.text = ApplicationData.workouts[wkt.configIndex].name
            
            lineChartView.noDataText = "There was not enough data to display."
            let description = Description()
            description.text = ""
            lineChartView.chartDescription = description
            
            lineChartView.gridBackgroundColor = .white
            lineChartView.backgroundColor = .black
            
            lineChartView.xAxis.labelPosition = .bottom
            lineChartView.xAxis.labelTextColor = .clear
            lineChartView.leftAxis.enabled = false
            lineChartView.rightAxis.labelTextColor = .white
            

            

            var points = [ChartDataEntry]()
            for i in 0..<wkt.data.count {
                let point = ChartDataEntry(x: Double(i), y: wkt.data[i].averageHR)
                points.append(point)
            }
            
            let heartRateData = LineChartDataSet(values: points, label: "Heart Rate")
            heartRateData.circleColors = [.red]
            heartRateData.mode = .cubicBezier
            heartRateData.circleHoleColor = .white
            heartRateData.label = "Heart Rate"
            heartRateData.circleRadius = 6
            heartRateData.circleHoleRadius = 4
            heartRateData.setColor(.red)
            heartRateData.lineWidth = 3
            
            let lineChartData = LineChartData(dataSet: heartRateData)
            lineChartData.setValueTextColor(.white)
            lineChartView.data = lineChartData
            
            
            print("upper level: ", wkt.levels.high)
            let upperLevel = ChartLimitLine(limit: Double(wkt.levels.high), label: "Max Target")
            upperLevel.lineColor = .white
            upperLevel.valueTextColor = .white
            upperLevel.lineWidth = 2
            lineChartView.rightAxis.addLimitLine(upperLevel)
            
            print("lower level: ", wkt.levels.low)
            let lowerLevel = ChartLimitLine(limit: Double(wkt.levels.low), label: "Min Target")
            lowerLevel.lineColor = .white
            lowerLevel.valueTextColor = .white
            lowerLevel.lineWidth = 2
            lineChartView.rightAxis.addLimitLine(lowerLevel)
            

        }
    }
}
