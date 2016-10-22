//
//  AppDelegate.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 7/21/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var session: WCSession?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        print("did finish launching with options 2")
        self.requestAccessToHealthKit()
        
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
        
        UINavigationBar.appearance().tintColor = UIColor.white
        
        return true
    }
    
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        print("application should request healht authorization")
        self.requestAccessToHealthKit()

    
    }
    
    
    private func requestAccessToHealthKit() {
        let healthStore = HKHealthStore()
        
        let allTypes = Set([HKObjectType.workoutType(),
                            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,
                            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
        
        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
            if !success {
                print("error occured requesting access to health kit")
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("application will resign active")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("application did enter background")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("appication will enter foreground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("appliation did become active")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("application will terminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        switch activationState {
        case .activated:
            
            print("session activated")
            
            print("is watch app installed: \(session.isWatchAppInstalled)")
            
            print("is watch paired: \(session.isPaired)")
            
            print("is watch reachable: \(session.isReachable)")
            
            
            if session.isPaired && session.isWatchAppInstalled {
                print("sessionion: paired and installed")
                var message = [String : Any]()
                message["testing send"] = true
                message["please work"] = "ok"
                message["maybe"] = 1
                session.transferUserInfo(message)
                
                
            }
            
            
            
        case .inactive:
            print("session inactive")
        case .notActivated:
            print("session not activated")
        }
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
        let workout = Workout(data: userInfo)
        print("workout over the wire: ", workout)
        
        let saveWorkout = DBWorkout()
        saveWorkout.importSettings(workout: workout)
        
        //do block for creating realm object
        do {
            let realm = try Realm()
            
            do {
                try realm.write {
                    realm.add(saveWorkout)
                }
            } catch _ {}
            
        } catch _ {}
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("1")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("2")
    }
}
