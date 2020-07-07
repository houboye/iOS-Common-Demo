//
//  FirstViewController.swift
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/4.
//  Copyright © 2019 houboye. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        let player = BYAVPlayer()
        
        player.backgroundColor = UIColor.yellow
        view.addSubview(player)
        player.frame = view.bounds
    }

}
