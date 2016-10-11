//
//  WatchConnectivityHelper.swift
//  Heart Up
//
//  Created by Cameron Deardorff on 10/1/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation
import WatchConnectivity


class WorkoutSender: NSObject {
    
    private var session : WCSession?
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
    }
    
    func isReady() -> Bool {
        if let _ = session {
            return session!.isReachable && session!.activationState == .activated
        } else {
            return false
        }
    }
    
    func send(workout: Workout) {
        print("send message now!")
        let ws = workout.export()
        
        if isReady() {
            print("session is ready and we are sending message: ", ws)
            
            
            
            self.session?.sendMessage(ws,
                                      replyHandler: { (message) in
                print("reply with message: ", message)
                
                },
                                      errorHandler: { (error) in
                    print("error sending message: ", error)
                    
            })
        }
    }
    
}

extension WorkoutSender: WCSessionDelegate {
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("session reachability has changed!")
        
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activation did complete with state: ", activationState)
        
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("did receive message data: ", messageData)
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("did receive message: ", message)
        
    }
}
