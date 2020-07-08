//
//  UIDevice+Extension.swift
//  iOS-Common&Demo
//
//  Created by boye on 2020/7/8.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit

extension UIDevice {
    class func iOSSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    class func deviceCurrentLanguage() -> String {
        return Locale.preferredLanguages[0]
    }
    
    
//    ///------ iOS Device Type ------
//    static let is_iPhone5: Bool = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 640, height: 1136), (UIScreen.main.currentMode?.size)!) : false
//    static let is_iPhone6: Bool = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 750, height: 1334), (UIScreen.main.currentMode?.size)!) : false
//    static let is_iPhone6P: Bool = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 1242, height: 2208), (UIScreen.main.currentMode?.size)!) : false
//    static let is_iPhoneX: Bool = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 1125, height: 2436), (UIScreen.main.currentMode?.size)!) : false
//
//    ///------ 尺寸 ------ 注意iphoneX的适配用到了kDevice_Is_iPhoneX
//    static let screenWidth: CGFloat            = UIScreen.main.bounds.width
//    static let screenHeight: CGFloat           = UIScreen.main.bounds.height
//    static let screenRect: CGRect              = UIScreen.main.bounds
//    static let navigationBarHeight: CGFloat    = 47
//    static let statusBarHeight: CGFloat        = Device.is_iPhoneX ? 44 : 20
//    static let tabbarSafeBottomMargin: CGFloat = Device.is_iPhoneX ? 34 : 0
//    static let tabbarHeight: CGFloat           = Device.is_iPhoneX ? (49 + 34) : 49
//    static let statusBarAndNavigationBarHeight = Device.is_iPhoneX ? 88 : 64
    
    
}
