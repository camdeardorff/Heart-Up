//
//  IntesitySelectorController.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 8/5/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit

class IntesitySelectorController: WKInterfaceController {
    
    
    @IBOutlet var intensityTable: WKInterfaceTable!
    
    var workout: Workout?
    var intensities: [(level: String, min: Int, max: Int)]?
    
    override func awake(withContext context: Any?) {
        workout = context as? Workout
        if workout != nil {
            print("workout selection controller awake with workout: ", workout!)
            intensities = ApplicationData.workouts[workout!.configIndex].intensities
            loadTableData(data: intensities!)
        }
    }

    
    func loadTableData(data: [(level: String, min: Int, max: Int)]) {
        let intesityTableRowController = "IntesityTableRowController"

        var rowTypes: [String] = []
        for _ in 0..<data.count {
            rowTypes.append(intesityTableRowController)
        }
        intensityTable.setRowTypes(rowTypes)

    
        
        for (index, point) in data.enumerated() {
            let row = intensityTable.rowController(at: index) as! IntesityTableRowController
            row.labelIntensity.setText(point.level)
        }
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        if (intensities?[rowIndex].level != "Custom") {
            
       
            // the row item is an intensity table row controller
            if let intensityList = intensities {
                let selectedIntesity: (level: String, min: Int, max: Int) = intensityList[rowIndex]
                workout?.levels.low = selectedIntesity.min
                workout?.levels.high = selectedIntesity.max
                workout?.intensity = rowIndex

                WKInterfaceController.reloadRootControllers(withNames: ["WorkoutController", "HeartRateChartController", "EndWorkoutController"], contexts: [workout!, workout!, workout!])
            }
        } else {
            // this table row is the custom selector
            pushController(withName: "HeartRateRangeSelectionController", context: workout!)

        }
    }
}
