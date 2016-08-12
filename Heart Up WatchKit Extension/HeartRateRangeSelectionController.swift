//
//  HeartRateRangeSelection.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/28/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit

class HeartRateRangeSelectionController: WKInterfaceController {

    @IBOutlet var lowerLimitSelector: WKInterfacePicker!
    @IBOutlet var upperLimitSelector: WKInterfacePicker!
    
    var sendContext: WorkoutConfig?
    
    var selectedLowerLimit: Int = -1
    var selectedUpperLimit: Int = -1
    
    
    
    let HR_OFFSET: Int = 2
    let lower = 10
    let upper = 40

    override func awake(withContext context: AnyObject?) {
        
        sendContext = context as? WorkoutConfig
        
        
        var lowerLimitPickerItems = [WKPickerItem]()
        var upperLimitPickerItems = [WKPickerItem]()
        
        for i in lower - HR_OFFSET...upper - HR_OFFSET {
            let numericalLimit = WKPickerItem()
            numericalLimit.title = "\(i * 5)"
            lowerLimitPickerItems.append(numericalLimit)
        }
        lowerLimitSelector.setItems(lowerLimitPickerItems)
        lowerLimitSelector.setSelectedItemIndex(lowerLimitPickerItems.count/2)

        
        for i in lower...upper {
            let numericalLimit = WKPickerItem()
            numericalLimit.title = "\(i * 5)"
            upperLimitPickerItems.append(numericalLimit)
        }
        upperLimitSelector.setItems(upperLimitPickerItems)
        upperLimitSelector.setSelectedItemIndex(upperLimitPickerItems.count/2)
    }
    
    
    @IBAction func lowerLimitSelectorChanged(_ value: Int) {
        selectedLowerLimit = (value + lower - HR_OFFSET) * 5
        print("CD: lower update:", selectedLowerLimit)
    }
    
    @IBAction func upperLimitSelectorChanged(_ value: Int) {
        selectedUpperLimit = (value + lower) * 5
        print("CD: upper update:", selectedUpperLimit)

    }
    
    
    @IBAction func nextButtonWasPressed() {
        
        
        
        
        
        
        if selectedUpperLimit >= lower * 5 && selectedLowerLimit >= (lower - HR_OFFSET) * 5 {
            if selectedUpperLimit > selectedLowerLimit {
//                sendContext?.hrLowerLimit = selectedLowerLimit
//                sendContext?.hrUpperLimit = selectedUpperLimit
                sendContext?.sentFromControllerNamed = "HeartRateRangeSelectionController"
                sendContext?.startDate = Date()
//                presentController(withName: "WorkoutController", context: sendContext!)
//                presentController(withNames: ["WorkoutController", "testPageBased"], contexts: nil)
                WKInterfaceController.reloadRootControllers(withNames: ["WorkoutController", "testPageBased", "aaaa"], contexts: ["NewInterfaceController"])

            } else {
                let moveToIndex = ((selectedUpperLimit) / 5) - lower
                lowerLimitSelector.setSelectedItemIndex(moveToIndex)
            }
        }
        
    }
    
    
    
}
