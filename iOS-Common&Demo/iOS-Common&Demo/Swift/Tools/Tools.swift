//
//  Tools.swift
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/28.
//  Copyright © 2019 houboye. All rights reserved.
//

import Foundation

class Tools {
    
    /// 得到某个文件夹大小
    ///
    /// - Parameter path: 文件夹路径
    /// - Returns: 文件大小，单位为MB
    class func getFileSize(_ path: String) -> Double {
        let manager = FileManager.default
        
        if manager.fileExists(atPath: path) {
            let subFilePath = manager.subpaths(atPath: path)
            
            if subFilePath == nil || (subFilePath?.count)! <= 0 { return 0 }
            
            var fileTotalSize = 0.0
            
            for fileName in subFilePath! {
                let filePath = path + "/" + fileName
                let fileAttributes = try! manager.attributesOfItem(atPath: filePath)
                if (fileAttributes[FileAttributeKey.type] as! FileAttributeType) == FileAttributeType.typeDirectory { continue }
                fileTotalSize += fileAttributes[FileAttributeKey.size] as! Double
            }
            //将字节大小转为MB，然后传出去
            return fileTotalSize/1000.0/1000
        }
        return 0.0
    }
    
    /// 清除某文件夹
    ///
    /// - Parameter path: 文件路径
    class func cleanCaches(_ path: String) {
        let manager = FileManager.default
        try? manager.removeItem(atPath: path)
    }
    
    /// 得到一个类直至rootClass的属性列表
    ///
    /// - Parameters:
    ///   - clazz: 当前类
    ///   - rootClazz: 目标类
    /// - Returns: 属性列表
    class func properties(_ clazz: AnyClass, rootClazz: AnyClass) -> [String] {
        var array = [String]()
        var tmpClass: AnyClass = clazz
        var count: UInt32 = 0
        while tmpClass != rootClazz {
            let properties = class_copyPropertyList(tmpClass, &count)
            for i in 0..<count {
                let property = properties![Int(i)]
                let propertyName = String(utf8String: property_getName(property))
                array.append(propertyName!)
            }
            if properties.isSome {
                free(properties)
            }
            tmpClass = class_getSuperclass(tmpClass)!
        }
        return array
    }
    
    class func createDirectory(_ path: String) {
        let fm = FileManager.default
        if !fm.fileExists(atPath: path) {
            try! fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
