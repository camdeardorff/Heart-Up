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
    
    var sendContext: WorkoutConfig?
    var intensities: [(level: String, min: Int, max: Int)]?
    
    override func awake(withContext context: AnyObject?) {
        cam("awake with context in intensity selection controller")
        sendContext = context as? WorkoutConfig
        if let _ = sendContext {
            intensities = sendContext!.workoutType?.intensities
            loadTableData(data: intensities!)
        }
    }

    
    func loadTableData(data: [(level: String, min: Int, max: Int)]) {
        let intesityTableRowController = "IntesityTableRowController"
        let customIntensityRowController = "CustomIntensityRowController"

        var rowTypes: [String] = []
        for _ in 0..<data.count {
            rowTypes.append(intesityTableRowController)
        }
        rowTypes.append(customIntensityRowController)
        intensityTable.setRowTypes(rowTypes)

    
        
        for (index, point) in data.enumerated() {
            let row = intensityTable.rowController(at: index) as! IntesityTableRowController
            row.labelIntensity.setText(point.level)
        }
        let customRangeRow = intensityTable.rowController(at: data.count) as! CustomIntensityRowController
        customRangeRow.label.setText("Create Custom")
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        
        if rowIndex < intensities?.count {
            // the row item is an intensity table row controller
            if let intensityList = intensities {
                let selectedIntesity: (level: String, min: Int, max: Int) = intensityList[rowIndex]
                sendContext?.sentFromControllerNamed = "IntensitySelectorController"
                sendContext?.workoutIntesity = selectedIntesity
//                pushController(withName: "WorkoutController", context: sendContext)
                WKInterfaceController.reloadRootControllers(withNames: ["WorkoutController", "HeartRateChartController", "EndWorkoutController"], contexts: [sendContext!,sendContext!,sendContext!])
            }
        } else {
            // this table row is the custom selector
            sendContext?.sentFromControllerNamed = "IntensitySelectorController"
            pushController(withName: "HeartRateRangeSelectionController", context: sendContext)

        }
        
        
        
        
    }
}
