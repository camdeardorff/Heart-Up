//
//  PostWorkoutController.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 9/14/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import WatchKit
import RealmSwift
import Realm


class PostWorkoutController: WKInterfaceController {
    
    var sendContext: Workout?
    var heathStats: HealthDataStats = HealthDataStats.sharedInstance
    
    override func awake(withContext context: Any?) {
        
        print("awake in post with context: \(context)")

        sendContext = context as? Workout
        let hrExports = heathStats.exportData()
        print("hr exports: \(hrExports)")
        
        if let workout = sendContext {
            workout.avg = hrExports.avg
            workout.max = hrExports.max
            workout.min = hrExports.min
            workout.start = hrExports.start
            workout.end = hrExports.end
            workout.time = hrExports.time
//            workout.data = hrExports.data
            
            
            
            
            
            
            let realm = try! Realm()
            
            // Persist your data easily
            try! realm.write {
                print("try write: \(workout)")
                realm.add(workout)
            }

        }
        
        
    }
    
}
