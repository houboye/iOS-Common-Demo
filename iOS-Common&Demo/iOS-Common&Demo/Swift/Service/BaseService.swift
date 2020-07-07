//
//  BaseService.swift
//  Common_iOS
//
//  Created by 侯博野 on 2018/9/4.
//  Copyright © 2018 houboye. All rights reserved.
//

import UIKit

@objc
protocol BaseServiceDelegate {
    @objc optional func onCleanData()
    @objc optional func onReceiveMemoryWarning()
    @objc optional func onEnterBackground()
    @objc optional func onEnterForeground()
    @objc optional func onAppWillTerminate()
}

@objcMembers
class BaseService:NSObject, BaseServiceDelegate {
    required override init() {
        super.init()
    }
    
    class func sharedInstance() -> AnyObject {
        return BaseServiceManager.shared.singletonByClass(singletonClass: classForCoder())!
    }
    
    //空方法，只是输出log而已
    //大部分的BaseService懒加载即可，但是有些因为业务需要在登录后就需要立马生成
    func start() {
        debugPrint("Service \(type(of: self)) Started")
    }
    
}

class BaseServiceManager: NSObject {
    static let shared = BaseServiceManager()
    
    private let lock = NSRecursiveLock()
    private var core: BaseServiceManagerImpl?
    
    private override init() {
        super.init()
        ListenNotify(UIApplication.didReceiveMemoryWarningNotification.rawValue, observer: self, selector: #selector(callReceiveMemoryWarning))
        ListenNotify(UIApplication.didEnterBackgroundNotification.rawValue, observer: self, selector: #selector(callEnterBackground))
        ListenNotify(UIApplication.willEnterForegroundNotification.rawValue, observer: self, selector: #selector(callEnterForeground))
        ListenNotify(UIApplication.willTerminateNotification.rawValue, observer: self, selector: #selector(callAppWillTerminate))
    }
    
    func start() {
        lock.lock()
        let key = "当前帐号"
        core = BaseServiceManagerImpl.coreImpl(key: key)
        lock.unlock()
    }
    
    func destory() {
        lock.lock()
        callSingletonClean()
        core = nil
        lock.unlock()
    }
    
    func singletonByClass(singletonClass: AnyClass) -> AnyObject? {
        var instance: AnyObject?
        lock.lock()
        instance = core?.singletonByClass(singletonClass: singletonClass)
        lock.unlock()
        return instance
    }
    
    private func callSingletonClean() {
        callSelector(selector: #selector(BaseServiceDelegate.onCleanData))
    }
    
    @objc private func callReceiveMemoryWarning() {
        callSelector(selector: #selector(BaseServiceDelegate.onReceiveMemoryWarning))
    }
    @objc private func callEnterBackground() {
        callSelector(selector: #selector(BaseServiceDelegate.onEnterBackground))
    }
    @objc private func callEnterForeground() {
        callSelector(selector: #selector(BaseServiceDelegate.onEnterForeground))
    }
    @objc private func callAppWillTerminate() {
        callSelector(selector: #selector(BaseServiceDelegate.onAppWillTerminate))
    }
    
    func callSelector(selector: Selector) {
        core?.callSingletonSelector(selector: selector)
    }
    
    deinit {
        RemoveNotify(self)
    }
}

private class BaseServiceManagerImpl {
    private var key: String?
    private var singletons = NSMutableDictionary()
    
    class func coreImpl(key: String) -> BaseServiceManagerImpl {
        let impl = BaseServiceManagerImpl()
        impl.key = key
        return impl
    }
    
    func singletonByClass(singletonClass: AnyClass) -> AnyObject {
        let singletonClassName = NSStringFromClass(singletonClass)
        var singleton = singletons.object(forKey: singletonClassName)
        if singleton == nil {
            let cls = singletonClass as! BaseService.Type
            singleton = cls.init()
            singletons.setObject(singleton!, forKey: singletonClassName as NSCopying)
        }
        return singleton as AnyObject
    }
    
    func callSingletonSelector(selector: Selector) {
        let array = singletons.allValues
        for obj in array {
            if (obj as AnyObject).responds(to: selector) {
                debugPrint("\(String(describing: (obj as AnyObject).perform(selector)))")
            }
        }
    }
}
