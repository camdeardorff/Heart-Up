//
//  WatchCommunication.swift
//  WatchConnectivityTest
//
//  Created by Cameron Deardorff on 10/10/16.
//  Copyright © 2016 Cameron Deardorff. All rights reserved.
//

import Foundation
import WatchConnectivity


class WatchCommunicator: NSObject {
    
    static let shared = WatchCommunicator()
    
    private let session = WCSession.default()
    internal var waitingInfo: [String : Any]?
    
    private override init() {
        super.init()
    }
    
    func start() {
        session.delegate = self
        session.activate()
    }
    
    func sendDictionary(_ dict: [String : Any]) {
        if session.activationState == .activated {
            session.transferUserInfo(dict)
        } else {
            switch session.activationState {
            case .activated: break
            case .inactive, .notActivated:
                waitingInfo = dict
            }
            
        }
    }
}

extension WatchCommunicator: WCSessionDelegate {
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        switch session.activationState {
        case .activated:
            
            if let wi = waitingInfo {
                sendDictionary(wi)
                waitingInfo = nil
            }
        case .inactive: break
//            print("session inactive")
        case .notActivated: break
//            print("session not activated")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            
            if let wi = waitingInfo {
                sendDictionary(wi)
                waitingInfo = nil
            }
            
        case .inactive: break
//            print("inactive")
        case .notActivated: break
//            print("not activated")
        }
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("did receive user info: ", userInfo)
    }
}
