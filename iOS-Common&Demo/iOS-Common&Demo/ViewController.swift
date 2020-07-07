//
//  ViewController.swift
//  iOS-Common&Demo
//
//  Created by boye on 2020/7/7.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var createOCButton: UIButton!
    
    @IBOutlet weak var createSwiftButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func createOCAction(_ sender: Any) {
        let rootVC = BYRootTabBarController()
        
        Device.appWindow?.rootViewController = rootVC
    }
    
    @IBAction func createSwiftAction(_ sender: Any) {
        let rootVC = RootTabBarController()
        
        Device.appWindow?.rootViewController = rootVC
    }
}

