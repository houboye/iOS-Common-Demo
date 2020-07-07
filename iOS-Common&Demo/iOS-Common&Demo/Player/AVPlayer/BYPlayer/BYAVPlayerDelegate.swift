//
//  BYAVPlayerDelegate.swift
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/9.
//  Copyright © 2019 houboye. All rights reserved.
//

import UIKit

@objc
protocol BYAVPlayerDelegate {
    
    /// 点击播放暂停按钮代理方法
    ///
    /// - Parameters:
    ///   - player: BYAVPlayer
    ///   - playOrPauseButton: playOrPauseButton
    func player(_ player: BYAVPlayer, clickedPlayOrPauseButton button: UIButton)
    
    /// 点击关闭按钮代理方法
    ///
    /// - Parameters:
    ///   - player: BYAVPlayer
    ///   - button: clickedCloseButton
    func player(_ player: BYAVPlayer, clickedCloseButton button: UIButton)
    
    /// 点击全屏按钮代理方法
    ///
    /// - Parameters:
    ///   - player: BYAVPlayer
    ///   - button: clickedFullScreenButton
    func player(_ player: BYAVPlayer, clickedFullScreenButton button: UIButton)
    
    /// 点击锁定🔒按钮的方法
    ///
    /// - Parameters:
    ///   - player: BYAVPlayer
    ///   - button: clickedLockButton
    func player(_ player: BYAVPlayer, clickedLockButton button: UIButton)
    
    /// 单击BYAVPlayer的代理方法
    ///
    /// - Parameters:
    ///   - player: BYAVPlayer
    ///   - tap: singleTaped
    func player(_ player: BYAVPlayer, singleTaped tap: UITapGestureRecognizer)
    
    /// 双击BYAVPlayer的代理方法
    ///
    /// - Parameters:
    ///   - player: BYAVPlayer
    ///   - tap: doubleTaped
    func player(_ player: BYAVPlayer, doubleTaped tap: UITapGestureRecognizer)
    
    /// BYAVPlayer的的操作栏隐藏和显示
    ///
    /// - Parameters:
    ///   - player: player
    ///   - isHidden: isHiddenTopAndBottomView
    func player(_ player: BYAVPlayer, isHiddenTopAndBottomView isHidden: Bool)
    
    /// 播放失败的代理方法
    ///
    /// - Parameters:
    ///   - player: BYAVPlayer
    ///   - status: playerStatus
    func playerFailedPlay(_ player: BYAVPlayer, playerStatus status: BYPlayerState)
    
    /// 准备播放的代理方法
    ///
    /// - Parameters:
    ///   - player: BYAVPlayer
    ///   - status: playerStatus
    func playerReadyToPlay(_ player: BYAVPlayer, playerStatus status: BYPlayerState)
    
    /// 播放器已经拿到视频的尺寸大小
    ///
    /// - Parameters:
    ///   - player: BYAVPlayer
    ///   - presentationSize: videoSize
    func playerGotVideoSize(_ player: BYAVPlayer, videoSize presentationSize: CGSize)
    
    /// 播放完毕的代理方法
    ///
    /// - Parameter player: BYAVPlayer
    func playerFinishedPlay(_ player: BYAVPlayer)
}
