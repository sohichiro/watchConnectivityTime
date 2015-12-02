//
//  InterfaceController.swift
//  watchConnectibityTimeWatch Extension
//
//  Created by 長尾聡一郎 on 2015/12/01.
//  Copyright © 2015年 長尾聡一郎. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        if WCSession.isSupported() {
            WCSession.defaultSession().delegate = self
            WCSession.defaultSession().activateSession()
            
            print("active Session in InterfaceController")
            dispatch_async(dispatch_get_main_queue(), {
            })
            
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
/*        
        if let watchInfo = message["sendMessageToWatch"] as? String {
            var show:String
            
            if watchInfo == "0" {
                show = "🐶"
            }
            else if watchInfo == "1" {
                show = "🐱"
            }
            else if watchInfo == "2" {
                show = "🐘"
            }
            else {
                show = "🐧"
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.statusLabel.setText(show)
            })
        }
*/
        
        replyHandler(["reply" : "OK"])
    }
    
    func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
        let replyStr:String = "OK"
        let replyData = replyStr.dataUsingEncoding(NSUTF8StringEncoding)
        replyHandler(replyData!)
    }
}
