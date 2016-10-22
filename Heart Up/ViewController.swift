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


class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    
    
    var workouts: [Workout] = []
    var selectedWorkout: Workout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let nib = UINib(nibName: "WorkoutTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "workoutCell")
        
        print("view did load")
        
        //do block for creating realm object
        do {
            let realm = try Realm()
            
            let savedWorkouts = realm.objects(DBWorkout.self)
            print("there are \(savedWorkouts.count) workouts")
            savedWorkouts.forEach({ (dbw) in
                print("loop saved workouts")
                workouts.append(Workout(dbWorkout: dbw))
            })
            
            print(workouts)
            
        } catch _ {}
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let id = segue.identifier {
            switch id {
            case "showChartSegue":
                if let vc = segue.destination as? WorkoutSummaryViewController {
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

extension ViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("did select row at index path")
        print("workout selected: ", workouts[indexPath.row])
        selectedWorkout = workouts[indexPath.row]
        performSegue(withIdentifier: "showChartSegue", sender: nil)
        
    }
    
    private func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell for row at index path")
        
        let cell: WorkoutTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "workoutCell") as! WorkoutTableViewCell
        cell.selectionStyle = .none
        let workout = workouts[indexPath.row]
        
        cell.intensityLevel.text = ApplicationData.workouts[workout.configIndex].intensities[workout.intensity].level + " intensity"
        cell.title.text = ApplicationData.workouts[workout.configIndex].name
        cell.timeInterval.text = "\(workout.time.length)"
        cell.workoutImage.image = ApplicationData.workouts[workout.configIndex].image
//        cell.containerView.layer.cornerRadius = 7
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of rows in section with: ", workouts.count)
        return workouts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.2
    }
}























