//
//  IntesitySelectorController.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 8/5/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit
import HealthKit

class IntesitySelectorController: WKInterfaceController {
    
    // interface objects
    @IBOutlet var intensityTable: WKInterfaceTable!
    
    // workout config data
    var workout: Workout?
    var intensities = [Intensity]()
    
    override func awake(withContext context: Any?) {
        workout = context as? Workout
        do {
            // get a person's age by their date of birth
            let dob = try HKHealthStore().dateOfBirthComponents()
            let age = NSCalendar.current.component(.year, from: dob.date!)
            // get all of the intensites that map to this age
            intensities = getAllIntensities(atAge: age)
            
        } catch _ {
            // the age was not retreived. only include the custom option
            intensities.append(Intensity(level: .custom, age: 0))
        }
        // load the table with the intensities added. (all or only custom)
        loadTableData(data: intensities)
        
        // if there is only 1 (custom option) let the user know why
        if intensities.count == 1 {
            let errorMessage = WKAlertAction(title: "Understood", style: .default, handler: {})
            presentAlert(withTitle: "Hold Up", message: "Your age is either unspecified or unaccessable. Only the custom intensity is available without access to your age.", preferredStyle: .alert, actions: [errorMessage])
        }
    }
    
    /**
     # Get All Intensities
     Calculates the intensities for the age provided
     - Parameter atAge: years of life.
     - Returns: [Intensity]
     */
    func getAllIntensities(atAge age: Int) -> [Intensity] {
        var allIntensities = [Intensity]()
        for level in Intensity.ALL_LEVELS {
            allIntensities.append(Intensity(level: level, age: age))
        }
        return allIntensities
    }
    
    // loads the table with a list of intensities
    func loadTableData(data: [Intensity]) {
        let intesityTableRowController = "IntesityTableRowController"
        
        // collect and set all of the row types
        var rowTypes: [String] = []
        for _ in 0..<data.count {
            rowTypes.append(intesityTableRowController)
        }
        intensityTable.setRowTypes(rowTypes)
        
        // set data on the rows
        for (index, intensity) in data.enumerated() {
            let row = intensityTable.rowController(at: index) as! IntesityTableRowController
            row.labelIntensity.setText(intensity.level.rawValue)
        }
    }
    
    // method to handle table selections
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        // move on to the workout if the row selected is not custom (it has all necessary data)
        if (intensities[rowIndex].level != .custom) {
            // the row item is an intensity table row controller
            let selectedIntesity = intensities[rowIndex]
            workout?.levels.low = selectedIntesity.hrRange.min
            workout?.levels.high = selectedIntesity.hrRange.max
            workout?.intensity = rowIndex
            
            WKInterfaceController.reloadRootControllers(withNames: ["WorkoutController", "HeartRateChartController"], contexts: [workout!, workout!])
        } else {
            // this table row is the custom selector
            pushController(withName: "HeartRateRangeSelectionController", context: workout!)
        }
    }
}
