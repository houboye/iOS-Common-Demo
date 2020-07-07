//
//  BYPlayerModel.swift
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/9.
//  Copyright © 2019 houboye. All rights reserved.
//

import UIKit
import AVFoundation

class BYPlayerModel: NSObject {
    var title: String! // 视频标题
    var videoUrl: URL? // 视频的URL，本地路径or网络路径http
    var playerItem: AVPlayerItem? // videoURL和playerItem二选一
    var seekTime: Double = 0.0 // 跳到seekTime处播放
    var indexPath: IndexPath!
    var presentationSize: CGSize! {
        didSet {
            if presentationSize.width / presentationSize.height < 1 {
                self.verticalVideo = true
            }
        }
    } // 视频尺寸
    var verticalVideo: Bool = false // 是否是适合竖屏播放的资源，w：h<1的资源，一般是手机竖屏（人像模式）拍摄的视频资源
}
