//
//  ApplicationEventSubscriberProtocol.swift
//  Common_iOS
//
//  Created by boye on 2020/4/27.
//  Copyright © 2020 houboye. All rights reserved.
//

import UIKit

@objc protocol ApplicationEventSubscriberProtocolOBJC: class {
    func applicationDidEnterBackgroundNotificationReceived(_ notification: Notification)
    func applicationWillEnterForegroundNotificationReceived(_ notification: Notification)
    func applicationDidFinishLaunchingNotificationReceived(_ notification: Notification)
    func applicationDidBecomeActiveNotificationReceived(_ notification: Notification)
    func applicationWillResignActiveNotificationReceived(_ notification: Notification)
    func applicationDidReceiveMemoryWarningNotificationReceived(_ notification: Notification)
    func applicationWillTerminateNotificationReceived(_ notification: Notification)
    func applicationSignificantTimeChangeNotificationReceived(_ notification: Notification)
}

protocol ApplicationEventSubscriberProtocol: ApplicationEventSubscriberProtocolOBJC {
    func beginObservingApplicationEvent()
    
    func onApplicationDidEnterBackgroundNotificationReceived(_ notification: Notification)
    func onApplicationWillEnterForegroundNotificationReceived(_ notification: Notification)
    func onApplicationDidFinishLaunchingNotificationReceived(_ notification: Notification)
    func onApplicationDidBecomeActiveNotificationReceived(_ notification: Notification)
    func onApplicationWillResignActiveNotificationReceived(_ notification: Notification)
    func onApplicationDidReceiveMemoryWarningNotificationReceived(_ notification: Notification)
    func onApplicationWillTerminateNotificationReceived(_ notification: Notification)
    func onApplicationSignificantTimeChangeNotificationReceived(_ notification: Notification)
    
    func respondToApplicationDidEnterBackground()
    func respondToApplicationWillEnterForeground()
    func respondToApplicationDidFinishLaunching()
    func respondToApplicationDidBecomeActive()
    func respondToApplicationWillResignActive()
    func respondToApplicationDidReceiveMemoryWarning()
    func respondToApplicationWillTerminate()
    func respondToApplicationSignificantTimeChange()
}

extension ApplicationEventSubscriberProtocol {
    func beginObservingApplicationEvent() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackgroundNotificationReceived(_:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForegroundNotificationReceived(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidFinishLaunchingNotificationReceived(_:)),
                                               name: UIApplication.didFinishLaunchingNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActiveNotificationReceived(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActiveNotificationReceived(_:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidReceiveMemoryWarningNotificationReceived(_:)),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillTerminateNotificationReceived(_:)),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationSignificantTimeChangeNotificationReceived(_:)),
                                               name: UIApplication.significantTimeChangeNotification,
                                               object: nil)
    }
    
    func onApplicationDidEnterBackgroundNotificationReceived(_ notification: Notification) {
        respondToApplicationDidEnterBackground()
    }
    func onApplicationWillEnterForegroundNotificationReceived(_ notification: Notification) {
        respondToApplicationWillEnterForeground()
    }
    func onApplicationDidFinishLaunchingNotificationReceived(_ notification: Notification) {
        respondToApplicationDidFinishLaunching()
    }
    func onApplicationDidBecomeActiveNotificationReceived(_ notification: Notification) {
        respondToApplicationDidBecomeActive()
    }
    func onApplicationWillResignActiveNotificationReceived(_ notification: Notification) {
        respondToApplicationWillResignActive()
    }
    func onApplicationDidReceiveMemoryWarningNotificationReceived(_ notification: Notification) {
        respondToApplicationDidReceiveMemoryWarning()
    }
    func onApplicationWillTerminateNotificationReceived(_ notification: Notification) {
        respondToApplicationWillTerminate()
    }
    func onApplicationSignificantTimeChangeNotificationReceived(_ notification: Notification) {
        respondToApplicationSignificantTimeChange()
    }
}
