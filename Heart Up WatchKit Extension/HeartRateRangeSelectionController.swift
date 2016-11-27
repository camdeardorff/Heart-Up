//
//  HeartRateRangeSelection.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/28/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit

class HeartRateRangeSelectionController: WKInterfaceController {

    // interface objects
    @IBOutlet var lowerLimitSelector: WKInterfacePicker!
    @IBOutlet var upperLimitSelector: WKInterfacePicker!
    
    // workout data
    var workout: Workout?
    
    // stateful data and constants
    var selectedLowerLimit: Int = -1
    var selectedUpperLimit: Int = -1
    
    let HR_OFFSET: Int = 2
    let LOWER = 10
    let UPPER = 40

    override func awake(withContext context: Any?) {
        
        workout = context as? Workout
        
        print("workout selection controller awake with workout: ", workout!)
        
        
        var lowerLimitPickerItems = [WKPickerItem]()
        var upperLimitPickerItems = [WKPickerItem]()
        
        for i in LOWER - HR_OFFSET...UPPER - HR_OFFSET {
            let numericalLimit = WKPickerItem()
            numericalLimit.title = "\(i * 5)"
            lowerLimitPickerItems.append(numericalLimit)
        }
        lowerLimitSelector.setItems(lowerLimitPickerItems)
        lowerLimitSelector.setSelectedItemIndex(lowerLimitPickerItems.count/2)

        
        for i in LOWER...UPPER {
            let numericalLimit = WKPickerItem()
            numericalLimit.title = "\(i * 5)"
            upperLimitPickerItems.append(numericalLimit)
        }
        upperLimitSelector.setItems(upperLimitPickerItems)
        upperLimitSelector.setSelectedItemIndex(upperLimitPickerItems.count/2)
    }
    
    
    @IBAction func lowerLimitSelectorChanged(_ value: Int) {
        selectedLowerLimit = (value + LOWER - HR_OFFSET) * 5
    }
    
    @IBAction func upperLimitSelectorChanged(_ value: Int) {
        selectedUpperLimit = (value + LOWER) * 5
    }
    
    
    @IBAction func nextButtonWasPressed() {
        
        if selectedUpperLimit >= LOWER * 5 && selectedLowerLimit >= (LOWER - HR_OFFSET) * 5 {
            if selectedUpperLimit > selectedLowerLimit {

                workout?.levels.low = selectedLowerLimit
                workout?.levels.high = selectedUpperLimit
                workout?.intensity = Intensity.levels.custom.hashValue
                
                WKInterfaceController.reloadRootControllers(withNames: ["WorkoutController", "HeartRateChartController"], contexts: [workout!,workout!])

            } else {
                let moveToIndex = ((selectedUpperLimit) / 5) - LOWER
                lowerLimitSelector.setSelectedItemIndex(moveToIndex)
            }
        }
    }
}
