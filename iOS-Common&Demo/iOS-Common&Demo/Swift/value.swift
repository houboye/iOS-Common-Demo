//
//  value.swift
//  Common_iOS
//
//  Created by CardiorayT1 on 2018/7/11.
//  Copyright © 2018年 houboye. All rights reserved.
//

import UIKit

struct Device {
    ///------ 应用程序版本号version ------
    static let appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    
    ///------ iOS系统版本号 ------
    static let iOS_Version: String = UIDevice.current.systemVersion
    // MARK: 系统相关
    static let iOSBase = 8.0
    static let isOSLaterOrEqualToiOS8 = ( (Double(UIDevice.current.systemVersion) ?? Device.iOSBase) > 8.0 ) ? true : false
    static let isOSLaterOrEqualToiOS9 = ((Double(UIDevice.current.systemVersion) ?? Device.iOSBase) >= 9.0 ) ? true : false
    static let isOSLaterOrEqualToiOS10 = ((Double(UIDevice.current.systemVersion) ?? Device.iOSBase) >= 10.0 ) ? true : false
    static let isOSLaterOrEqualToiOS11 = ((Double(UIDevice.current.systemVersion) ?? Device.iOSBase) >= 11.0 ) ? true : false
    
    ///------ other ------
    static let appDelegate = UIApplication.shared.delegate
    static var appWindow: UIWindow? {
        guard let window = UIApplication.shared.windows.first else {
            return nil
        }
        return window
    }
    static let appRootViewController = Device.appWindow?.rootViewController
    static let userDefaults = UserDefaults.standard
    
    ///------ 获取当前语言 ------
    static let currentLanguage: String = Locale.preferredLanguages[0]
    
    ///------ 沙盒路径 ------
    static let path_of_home: String     = NSHomeDirectory()
    static let path_of_temp: String     = NSTemporaryDirectory()
    static let path_of_document: String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    
    ///------ iOS Device Type ------
    static let is_iPhone5: Bool = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 640, height: 1136), (UIScreen.main.currentMode?.size)!) : false
    static let is_iPhone6: Bool = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 750, height: 1334), (UIScreen.main.currentMode?.size)!) : false
    static let is_iPhone6P: Bool = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 1242, height: 2208), (UIScreen.main.currentMode?.size)!) : false
    static let is_iPhoneX: Bool = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 1125, height: 2436), (UIScreen.main.currentMode?.size)!) : false
    
    ///------ 尺寸 ------ 注意iphoneX的适配用到了kDevice_Is_iPhoneX
    static let screenWidth: CGFloat            = UIScreen.main.bounds.width
    static let screenHeight: CGFloat           = UIScreen.main.bounds.height
    static let screenRect: CGRect              = UIScreen.main.bounds
    static let navigationBarHeight: CGFloat    = 47
    static let statusBarHeight: CGFloat        = Device.is_iPhoneX ? 44 : 20
    static let tabbarSafeBottomMargin: CGFloat = Device.is_iPhoneX ? 34 : 0
    static let tabbarHeight: CGFloat           = Device.is_iPhoneX ? (49 + 34) : 49
    static let statusBarAndNavigationBarHeight = Device.is_iPhoneX ? 88 : 64
}








