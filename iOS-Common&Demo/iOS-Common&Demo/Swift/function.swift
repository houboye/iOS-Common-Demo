//
//  function.swift
//  Common_iOS
//
//  Created by CardiorayT1 on 2018/7/11.
//  Copyright © 2018年 houboye. All rights reserved.
//

import UIKit

/// 打印
public func PrintLog(_ items: Any...) {
    debugPrint(items)
}

///当前日期字符串，格式为：YYYY-MM-dd hh:mm:ss
public func Date_String() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
    return formatter.string(from: Date())
}

///------ RGB颜色 ------
public func RGBA(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
}

public func UIColorFromRGB(rgbValue: Int) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16)/255.0), green: ((CGFloat)((rgbValue & 0xFF00) >> 8)/255.0), blue: ((CGFloat)(rgbValue & 0xFF)/255.0), alpha: 1.0)
}

public func RandomColor() -> UIColor {
    return UIColor(red: CGFloat(arc4random_uniform(256)/255), green: CGFloat(arc4random_uniform(256)/255), blue: CGFloat(arc4random_uniform(256)/255), alpha: 1)
}

///------ 有效性验证<字符串、数组、字典等> ------
public func ValidString(_ string: String?) -> Bool {
    return (string != nil) && (string!.count > 0)
}

public func ValidNSString(_ string: NSString?) -> Bool {
    return (string != nil) && string!.isKind(of: NSString.classForCoder()) && (string!.length > 0)
}

public func ValidNSArray(_ array: NSArray?) -> Bool {
    return (array != nil) && array!.isKind(of: NSArray.classForCoder()) && (array!.count > 0)
}

public func ValidNSDictionary(_ dictionary: NSDictionary?) -> Bool {
    return (dictionary != nil) && dictionary!.isKind(of: NSDictionary.classForCoder())  && (dictionary!.count > 0)
}

public func ValidNSNumber(_ number: NSNumber?) -> Bool {
    return (number != nil) && (number?.isKind(of: NSNumber.classForCoder()))!
}

///------ 抛出异常(断言) ------
public func Assert(_ condition:Bool, _ reason: String) {
    assert(condition, reason)
}

///------ 通知 ------
public func PostNotify(_ name: String, object: Any?, info: [AnyHashable : Any]?) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: object, userInfo: info)
}

public func ListenNotify(_ name: String, observer: Any, selector: Selector) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
}

public func ListenNotify(_ name: String, observer: Any, selector: Selector, object: Any?) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: name), object: object)
}

public func RemoveNotify(_ observer: Any) {
    NotificationCenter.default.removeObserver(observer)
}
///------ 其他 ------
// MARK: Dictory Array Strig Object 闭包方式
///过滤null对象
public let filterNullOfObj:((Any)->Any?) = {(obj: Any) -> Any? in
    if obj is NSNull {
        return nil
    }
    return obj
}

///过滤null的字符串，当nil时返回一个初始化的空字符串
public let filterNullOfString:((Any)->String) = {(obj: Any) -> String in
    if obj is String {
        return obj as! String
    }
    return ""
}

/// 过滤null的数组，当nil时返回一个初始化的空数组
public let filterNullOfArray:((Any)->Array<Any>) = {(obj: Any) -> Array<Any> in
    if obj is Array<Any> {
        return obj as! Array<Any>
    }
    return Array()
}

/// 过滤null的字典，当为nil时返回一个初始化的字典
public let filterNullOfDictionary:((Any) -> Dictionary<AnyHashable, Any>) = {( obj: Any) -> Dictionary<AnyHashable, Any> in
    if obj is Dictionary<AnyHashable, Any> {
        return obj as! Dictionary<AnyHashable, Any>
    }
    return Dictionary()
}

//根据传入的值算出乘以比例之后的值
func adaptedWidth(width:CGFloat) ->CGFloat {
    return CGFloat(ceil(Float(width))) * 1.0
}

func adaptedHeight(height:CGFloat) ->CGFloat {
    return CGFloat(ceil(Float(height))) * 1.0
}

/// 角度转弧度
///
/// - Parameter __ANGLE__: 角度
/// - Returns: 弧度值
func AngleToRadian(__ANGLE__:CGFloat) ->CGFloat {
    return (CGFloat(Double.pi) * __ANGLE__ / 180.0)
}

/// 弧度转角度
///
/// - Parameter __RADIAN__: 弧度
/// - Returns: 角度
func RadianToAngle(__RADIAN__:CGFloat) ->CGFloat {
    return (CGFloat(__RADIAN__ * 180 / CGFloat(Double.pi)))
}
