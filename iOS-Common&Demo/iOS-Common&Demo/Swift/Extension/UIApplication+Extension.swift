//
//  UIApplication+Extension.swift
//  iOS-Common&Demo
//
//  Created by boye on 2020/7/8.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit

extension UIApplication {
    class func firstWindow() -> UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    class func firstRootViewController() -> UIViewController? {
        return UIApplication.firstWindow()?.rootViewController
    }
    
    class func firstStatusBarManager() -> UIStatusBarManager? {
        return UIApplication.firstWindow()?.windowScene?.statusBarManager
    }
    
    class func statusBarHeight() -> CGFloat {
        return firstStatusBarManager()?.statusBarFrame.height ?? 0
    }
    
    class func appVersion() -> String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
}
