//
//  FastForwardView.swift
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/9.
//  Copyright © 2019 houboye. All rights reserved.
//

import UIKit

class FastForwardView: UIView {
    let stateImageView = UIImageView()
    let timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.0/256.0, green: 0.0/256.0, blue: 0.0/256.0, alpha: 0.8)
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
        stateImageView.image = UIImage(named: "progress_icon_r")
        addSubview(stateImageView)
        stateImageView.frame = CGRect(x: 0, y: 10, width: self.frame.size.width, height: self.frame.size.height - 20)
        
        timeLabel.font = UIFont.systemFont(ofSize: 15)
        timeLabel.textAlignment = .center
        timeLabel.textColor = UIColor.white
        addSubview(self.timeLabel)
        stateImageView.frame = CGRect(x: 0, y: 10, width: self.frame.size.width, height: self.frame.size.height - 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
