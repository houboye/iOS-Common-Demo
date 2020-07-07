//
//  RootTabBarController.swift
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/4.
//  Copyright © 2019 houboye. All rights reserved.
//

import UIKit

enum TabBarType: Int {
    case first = 0
    case second
    case third
    case fourth
}

fileprivate let TabbarVC = "vc"
fileprivate let TabbarTitle = "title"
fileprivate let TabbarImage = "image"
fileprivate let TabbarSelectedImage = "selectedImage"
fileprivate let TabbarItemBadgeValue = "badgeValue"
fileprivate let TabBarCount = 4

class RootTabBarController: UITabBarController {
    private(set) var navigationHandlers = [NavigationHandler]()

    func instance() -> RootTabBarController? {
        let delegate = UIApplication.shared.delegate
        if let vc = delegate?.window??.rootViewController {
            if vc.isKind(of: RootTabBarController.self) {
                return vc as? RootTabBarController
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubNavigationController()
    }
    
    private func setupSubNavigationController() {
        let handlerArray = tabbars().compactMap { (obj) -> NavigationHandler in
            let type = obj
            let item = self.vcInfo(for: type)
            let vcName = item[TabbarVC] as! String
            let title = item[TabbarTitle] as! String
            let imageName = item[TabbarImage] as! String
            let imageSelected = item[TabbarSelectedImage] as! String
            
            let clazz = NSClassFromString(vcName) as! UIViewController.Type
            let vc = clazz.init()
            
            let nc = setupChildViewController(vc, title: title, image: imageName, selectedImage: imageSelected)
            let handler = NavigationHandler(navigationController: nc)
            nc.delegate = handler
            
            return handler
        }
        navigationHandlers = handlerArray
    }
    
    private func tabbars() -> [TabBarType] {
        var items = [TabBarType]()
        for index in 0..<TabBarCount {
            items.append(TabBarType(rawValue: index)!)
        }
        return items
    }
    
    private func setupChildViewController(_ viewController: UIViewController, title: String, image: String, selectedImage: String) -> UINavigationController {
        viewController.title = title
        let nc = UINavigationController(rootViewController: viewController)
        
        var bgImage = UIImage(named: image)
        bgImage = bgImage?.withRenderingMode(.alwaysOriginal)
        var bgSelectedImage = UIImage(named: selectedImage)
        bgSelectedImage = bgSelectedImage?.withRenderingMode(.alwaysOriginal)
        
        nc.tabBarItem.image = bgImage
        nc.tabBarItem.selectedImage = bgSelectedImage
        nc.tabBarItem.title = title
        
        addChild(nc)
        
        return nc
    }
    
    private func vcInfo(for tabType: TabBarType) -> [String: Any] {
        
        let congfig = [TabBarType.first: [TabbarVC: NSStringFromClass(FirstViewController.self),
                                            TabbarTitle: "Swift-1",
                                            TabbarImage: "B1",
                                            TabbarSelectedImage: "A1"],
                       
                       TabBarType.second: [TabbarVC: NSStringFromClass(SecondViewController.self),
                                                TabbarTitle: "Swift-2",
                                                TabbarImage: "B2",
                                                TabbarSelectedImage: "A2"],
                       
                       TabBarType.third: [TabbarVC:  NSStringFromClass(ThirdViewController.self),
                                              TabbarTitle: "Swift-3",
                                              TabbarImage: "B3",
                                              TabbarSelectedImage: "A3"],
                       
                       TabBarType.fourth: [TabbarVC:  NSStringFromClass(FourthViewController.self),
                                          TabbarTitle: "Swift-4",
                                          TabbarImage: "B4",
                                          TabbarSelectedImage: "A4"]]
        
        return congfig[tabType]!
    }
}
