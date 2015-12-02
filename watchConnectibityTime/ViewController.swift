//
//  ViewController.swift
//  watchConnectibityTime
//
//  Created by 長尾聡一郎 on 2015/12/01.
//  Copyright © 2015年 長尾聡一郎. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {

    @IBOutlet weak var characterLength: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var debugTextView: UITextView!
    
    @IBOutlet weak var interbalSlider: UISlider!
    @IBOutlet weak var lengthSlider: UISlider!
    @IBOutlet weak var interbalStepper: UIStepper!
    @IBOutlet weak var characterStepper: UIStepper!
    
    
    var messegeLength:Int = 10
    var messegeInterbal:Double = 1.0
    
    var timer:NSTimer = NSTimer()
    var msgFlg: Bool = false
    
    var retryFlg:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
            print("activate session")
            
            if session.paired != true {
                print("Apple Watch is not paired")
            }
            
            if session.watchAppInstalled != true {
                print("WatchKit app is not installed")
            }
            
        }else {
            print("WatchConnectivity is not supported on this device")
        }
        
        self.changeIntervalValue(3.0)
        self.changeLengthValue(10)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:: changeInterbal
    
    func changeIntervalValue(value:Float) {
        var temp = value
        if value < 0.1 {
            temp = 0.1
        }
        self.interbalSlider.value = temp
        self.interbalStepper.value = Double(temp)
        self.messegeInterbal = Double(temp)
    }
    
    func changeLengthValue(value:Int) {
        var temp = value
        if value < 1 {
            temp = 1
        }
        self.lengthSlider.value = Float(temp)
        self.characterStepper.value = Double(temp)
        self.messegeLength = temp
    }
    
    func reloadInterbalView() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let display = NSString(format: "%03.2f", (self.messegeInterbal))
            self.intervalLabel.text = display as String
        }
    }
    
    func reloadCharLengthView() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let display = NSString(format: "%d", Int(self.messegeLength))
            self.characterLength.text = display as String
        }
        
    }

    @IBAction func changeInterbalSlider(sender: AnyObject) {
        let data = sender as! UISlider
        self.changeIntervalValue(data.value)
        self.exeTimer()
        self.reloadInterbalView()
    }
    
    
    @IBAction func stepInterbal(sender: AnyObject) {
        let data = sender as! UIStepper
        
        self.changeIntervalValue(Float(data.value))
        self.exeTimer()
        self.reloadInterbalView()
        
    }
    
    // MARK:: changeIntarbal
    
    @IBAction func stepCharacter(sender: AnyObject) {
        let data = sender as! UIStepper
        self.changeLengthValue(Int(data.value))
        self.exeTimer()
        self.reloadCharLengthView()
    }
    
    @IBAction func changeCharacterSlider(sender: AnyObject) {
        let data = sender as! UISlider
        self.changeLengthValue(Int(data.value))
        self.exeTimer()
        self.reloadCharLengthView()
    }
    
    func exeTimer() {
        if timer.valid {
            timer.invalidate()
        }
        
        if msgFlg {
            timer = NSTimer.scheduledTimerWithTimeInterval((messegeInterbal as NSTimeInterval), target: self, selector: "sendMsg", userInfo: nil, repeats: true)
        }
        else {
            timer = NSTimer.scheduledTimerWithTimeInterval((messegeInterbal as NSTimeInterval), target: self, selector: "sendMsgData", userInfo: nil, repeats: true)
        }
        
    }
    
    @IBAction func pushSendMessage(sender: AnyObject) {
        self.msgFlg = true
        self.exeTimer()
    }
    
    @IBAction func pushSendMessageData(sender: AnyObject) {
        self.msgFlg = false
        self.exeTimer()
    }
    
    var lengthGlobal = 65500
    

    
    func sendMsg(){
        let sendMsg = self.randomCharMaker(messegeLength)
        let message:[String : AnyObject] = ["s" : "\(sendMsg)"]
        let sendTime:NSDate = NSDate()
        var diff = NSTimeInterval()
        
        WCSession.defaultSession().sendMessage(message, replyHandler: { (reply) -> Void in
            let diffTime = NSDate()
            diff = diffTime.timeIntervalSinceDate(sendTime)
            
            if reply["reply"] as! String == "OK" {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let displayInterbal = NSString(format: "%02.1f", (self.messegeInterbal))
                    let displayTime = NSString(format: "%04.3f", diff)
                    
                    print("msg::itbl = \(displayInterbal) char = \(self.messegeLength) time = \(displayTime)s")
                    let displayStr = "msg::itbl = \(displayInterbal) char = \(self.messegeLength) time = \(displayTime)s\n"
                    self.appendDisplay(displayStr)
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("sendMsg Something Error::char = \(self.lengthGlobal)")
                    let displayStr = "sendMsgData Something Error:: char = \(self.messegeLength) \n"
                    self.appendDisplay(displayStr)
                    self.errorRetrySetting()
                })
            }
            }, errorHandler: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("sendMsg Error reply:: char = \(self.messegeLength)")
                    let displayStr = "Error reply \(self.messegeLength) \n"
                    self.appendDisplay(displayStr)
                    self.errorRetrySetting()
                })
        })
    }
    
    func sendMsgData(){
        let sendMsg = self.randomCharMaker(messegeLength)
        let sendMsgData = sendMsg.dataUsingEncoding(NSUTF8StringEncoding)
        let sendTime:NSDate = NSDate()
        var diff = NSTimeInterval()
        
        WCSession.defaultSession().sendMessageData(sendMsgData!, replyHandler: { (replyData) -> Void in
            let diffTime = NSDate()
            diff = diffTime.timeIntervalSinceDate(sendTime)
            
            let replyStr = NSString(data: replyData, encoding: NSUTF8StringEncoding)
            if replyStr == "OK" {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let displayInterbal = NSString(format: "%02.1f", (self.messegeInterbal))
                    let displayTime = NSString(format: "%04.3f", diff)
                    
                    print("data::itbl = \(displayInterbal) char = \(self.messegeLength)s time = \(displayTime)s")
                    let displayStr = "data::itbl = \(displayInterbal) char = \(self.messegeLength)s time = \(displayTime)s\n"
                    self.appendDisplay(displayStr)
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("sendMsgData Something Error::char = \(self.messegeLength)")
                    let displayStr = "sendMsgData Something Error:: char = \(self.messegeLength) \n"
                    self.appendDisplay(displayStr)
                    self.errorRetrySetting()
                })
            }
            }, errorHandler: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("send messageData Error reply:: char = \(self.messegeLength)")
                    let displayStr = "send messageData Error reply:: char = \(self.messegeLength) \n"
                    self.appendDisplay(displayStr)
                    self.errorRetrySetting()
                })
        })
    }
    
    func appendDisplay(viewStr:String) {
        var temp = self.debugTextView.text
        temp.appendContentsOf(viewStr)
        self.debugTextView.text = temp
    }
    
    func errorRetrySetting() {
        if retryFlg {
            let decrimentLength = self.messegeLength - 1
            self.changeLengthValue(decrimentLength)
            retryFlg = false
            self.reloadCharLengthView()
        }
        else {
            let decrimentInterval = Float(self.messegeInterbal + 0.1)
            self.changeIntervalValue(decrimentInterval)
            retryFlg = true
            self.reloadInterbalView()
        }
        
        self.exeTimer()
    }
    
    func retrySetting() {
        if retryFlg {
            let decrimentLength = self.messegeLength + 1
            self.changeLengthValue(decrimentLength)
            retryFlg = false
            self.reloadCharLengthView()
        }
        else {
            var decrimentInterval = Float(self.messegeInterbal - 0.1)
            if decrimentInterval < 0 {
                decrimentInterval = 0.1
            }
            self.changeIntervalValue(decrimentInterval)
            retryFlg = true
            self.reloadInterbalView()
        }
        
        self.exeTimer()
    }
    
    func randomCharMaker(length:Int = 1) -> String{
        var str:String = ""
        var i = 0
        while i < length {
            let random = self.getRandomNumber(Min: 65.0, Max:90.0)
            str.append(Character(UnicodeScalar(Int(random))))
            i++
        }
        return str
    }
    
    func getRandomNumber(Min _Min : Float, Max _Max : Float) -> Float {
        return ( Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX) ) * (_Max - _Min) + _Min
    }

}

