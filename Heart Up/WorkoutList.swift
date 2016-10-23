//
//  ViewController.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/21/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import WatchConnectivity
import HealthKit


class WorkoutList: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    var workouts: [Workout] = []
    var selectedWorkout: Workout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //configure the tableview with the view controller
        tableView.delegate = self
        tableView.dataSource = self
        
        //get the cell nib and give it to the tableview
        let nib = UINib(nibName: "WorkoutTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "workoutCell")
        
        //do block for creating realm object
        do {
            let realm = try Realm()
            
            let savedWorkouts = realm.objects(DBWorkout.self)
            savedWorkouts.forEach({ (dbw) in
                workouts.append(Workout(dbWorkout: dbw))
            })
            
        } catch let error as NSError {
            // handle the exception
            print("Error with creating realm object: ", error)
        }
        
        
        if workouts.count < 1 {
            // there are no workouts, let the user know
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //there is only one segue...
        if let id = segue.identifier {
            switch id {
            case "showChartSegue":
                //set the destination's 'workout' to the selectedWorkout
                if let vc = segue.destination as? WorkoutSummary {
                    if let wkt = selectedWorkout {
                        vc.workout = wkt
                    }
                }
            default:
                print("default")
            }
            
        }
    }
}

extension WorkoutList: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWorkout = workouts[indexPath.row]
        performSegue(withIdentifier: "showChartSegue", sender: nil)
    }
}

extension WorkoutList: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // the workout for the row
        let workout = workouts[indexPath.row]
        
        // create the cell and set it's properties
        let cell: WorkoutTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "workoutCell") as! WorkoutTableViewCell
        cell.selectionStyle = .none
        cell.intensityLevel.text = ApplicationData.workouts[workout.configIndex].intensities[workout.intensity].level + " Intensity"
        cell.title.text = ApplicationData.workouts[workout.configIndex].name
        
        cell.timeInterval.text = workout.time.length.formatHourSecond()
        cell.workoutImage.image = ApplicationData.workouts[workout.configIndex].image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.2
    }
}

extension TimeInterval {
    func formatHourSecond() -> String {
        let min = Int(self.truncatingRemainder(dividingBy: 3600)) / 60
        let hr = Int(self / 3600)
        
        
        var time = ""
        if hr > 0 {
            time += "\(hr) hour"
            if hr > 1 {
                time += "s"
            }
        }
        if min > 0 {
            if hr > 0 {
                time += ", "
            }
            time += "\(min) minute"
            if min > 1 {
                time += "s"
            }
        }
        return time
    }
}
