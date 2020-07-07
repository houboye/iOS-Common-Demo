//
//  SecondViewController.swift
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/4.
//  Copyright © 2019 houboye. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        beginObservingApplicationEvent()
    }

}


extension SecondViewController: ApplicationEventSubscriberProtocol {
    func respondToApplicationDidEnterBackground() {
        PrintLog("DidEnterBackground")
    }
    
    func respondToApplicationWillEnterForeground() {
        PrintLog("WillEnterForeground")
    }
    
    func respondToApplicationDidFinishLaunching() {
        PrintLog("DidFinishLaunching")
    }
    
    func respondToApplicationDidBecomeActive() {
        PrintLog("DidBecomeActive")
    }
    
    func respondToApplicationWillResignActive() {
        PrintLog("WillResignActive")
    }
    
    func respondToApplicationDidReceiveMemoryWarning() {
        PrintLog("DidReceiveMemoryWarning")
    }
    
    func respondToApplicationWillTerminate() {
        PrintLog("WillTerminate")
    }
    
    func respondToApplicationSignificantTimeChange() {
        PrintLog("SignificantTimeChange")
    }
    
    func applicationDidEnterBackgroundNotificationReceived(_ notification: Notification) {
        onApplicationDidEnterBackgroundNotificationReceived(notification)
    }
    
    func applicationWillEnterForegroundNotificationReceived(_ notification: Notification) {
        onApplicationWillEnterForegroundNotificationReceived(notification)
    }
    
    func applicationDidFinishLaunchingNotificationReceived(_ notification: Notification) {
        onApplicationDidFinishLaunchingNotificationReceived(notification)
    }
    
    func applicationDidBecomeActiveNotificationReceived(_ notification: Notification) {
        onApplicationDidBecomeActiveNotificationReceived(notification)
    }
    
    func applicationWillResignActiveNotificationReceived(_ notification: Notification) {
        onApplicationWillResignActiveNotificationReceived(notification)
    }
    
    func applicationDidReceiveMemoryWarningNotificationReceived(_ notification: Notification) {
        onApplicationDidReceiveMemoryWarningNotificationReceived(notification)
    }
    
    func applicationWillTerminateNotificationReceived(_ notification: Notification) {
        onApplicationWillTerminateNotificationReceived(notification)
    }
    
    func applicationSignificantTimeChangeNotificationReceived(_ notification: Notification) {
        onApplicationSignificantTimeChangeNotificationReceived(notification)
    }
}
