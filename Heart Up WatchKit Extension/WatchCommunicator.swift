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
        print("watch communicator init")
        super.init()
    }
    
    func start() {
        print("watch communicator start")
        session.delegate = self
        session.activate()
    }
    
    func sendDictionary(_ dict: [String : Any]) {
        print("watch communicator send dictionary")
        if session.activationState == .activated {
            print("activated, now send dictionary: ", dict)
            session.transferUserInfo(dict)
        } else {
            print("failed! state:")
            switch session.activationState {
            case .activated:
                print("session activated")
            case .inactive, .notActivated:
                waitingInfo = dict
            }
            
        }
    }
}

extension WatchCommunicator: WCSessionDelegate {
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("session reachability did change")
        switch session.activationState {
        case .activated:
            print("session activated")
            
            if let wi = waitingInfo {
                sendDictionary(wi)
                waitingInfo = nil
            }
        case .inactive:
            print("session inactive")
        case .notActivated:
            print("session not activated")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activate did complete with state")
        switch activationState {
        case .activated:
            print("activated")
            print("is there content waiting: ", session.hasContentPending)
            print(session.outstandingUserInfoTransfers)
            
            if let wi = waitingInfo {
                print("there is waiting info to be sent.. send it")
                sendDictionary(wi)
                waitingInfo = nil
            }
            
        case .inactive:
            print("inactive")
        case .notActivated:
            print("not activated")
        }
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("did receive user info: ", userInfo)
    }
}
