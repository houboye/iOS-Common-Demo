//
//  BYLightView.swift
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/9.
//  Copyright © 2019 houboye. All rights reserved.
//

import UIKit

fileprivate let kLight_View_Count = 16

class BYLightView: UIView {

    let lightBackView = UIView()
    let centerLightIV = UIImageView()
    var lightViewArr = Array<UIView>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        self.frame = CGRect(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.5, width: 155, height: 155)
        layer.cornerRadius = 10
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 5, width: self.bounds.size.width, height: 30))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor(red: 0.25, green: 0.22, blue: 0.21, alpha: 1.00)
        titleLabel.textAlignment = .center
        titleLabel.text = "亮度"
        addSubview(titleLabel)
        
        centerLightIV.frame = CGRect(x: 0, y: 0, width: 79, height: 76)
        centerLightIV.image = UIImage(named: "BYPlayer.bundle/play_new_brightness_day")
        centerLightIV.center = CGPoint(x: 155 * 0.5, y: 155 * 0.5)
        addSubview(centerLightIV)
        
        lightBackView.frame = CGRect(x: 13, y: 132, width: self.bounds.size.width - 26, height: 7)
        lightBackView.backgroundColor = UIColor(red: 65/255, green: 67/255, blue: 70/255, alpha: 1)
        addSubview(lightBackView)
        
        let view_width: CGFloat = (lightBackView.bounds.size.width - 17) / 16
        let view_height: CGFloat = 5
        let view_y: CGFloat = 1
        for i in 0..<kLight_View_Count {
            let view_x: CGFloat = CGFloat(i) * (view_width + 1) + 1
            let view = UIView(frame: CGRect(x: view_x, y: view_y, width: view_width, height: view_height))
            view.backgroundColor = UIColor.white
            lightViewArr.append(view)
            lightBackView.addSubview(view)
        }
        updateLongView(UIScreen.main.brightness)
        // 通知
        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        UIScreen.main.addObserver(self, forKeyPath: "brightness", options: NSKeyValueObservingOptions.new, context: nil)
        alpha = 0.0
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let sound = change?[NSKeyValueChangeKey.newKey] as! Float
        
        if alpha == 0.0 {
            alpha = 1.0
            let deadline = DispatchTime.now() + 1.0
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.hideLightView()
            }
        }
        updateLongView(CGFloat(sound))
    }
    
    private func hideLightView() {
        if alpha == 1.0 {
            UIView.animate(withDuration: 0.8, animations: {
                self.alpha = 0.0
            }) { (isFinished) in
                
            }
        }
    }
    
    @objc func onOrientationDidChange(_ notify: Notification) {
        alpha = 0.0
    }
    
    // MARK: - update view
    private func updateLongView(_ sound: CGFloat) {
        let stage: CGFloat = 1.0 / 15.0
        let level: Int = Int(sound/stage)
        
        for i in 0..<lightViewArr.count {
            let aView = lightViewArr[i]
            if i <= level {
                aView.isHidden = false
            } else {
                aView.isHidden = true
            }
        }
        setNeedsLayout()
        superview?.bringSubviewToFront(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    deinit {
        UIScreen.main.removeObserver(self, forKeyPath: "brightness")
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
