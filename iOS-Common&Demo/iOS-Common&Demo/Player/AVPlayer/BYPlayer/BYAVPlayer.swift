//
//  BYAVPlayer.swift
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/9.
//  Copyright © 2019 houboye. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

@objc
enum BYPlayerState: Int {
    case failed // 播放失败
    case buffering // 缓冲中
    case playing // 播放中
    case stopped // 打断播放
    case finished // 播放完成
    case pause // 播放暂停
}

// playerLayer的填充模式（默认：等比例填充，直到一个维度到达区域边界）
enum BYPlayerLayerGravity {
    case resize // 非均匀模式。两个维度完全填充至整个视图区域
    case resizeAspect // 等比例填充，直到一个维度到达区域边界
    case resizeAspectFill // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
}

enum BackBtnStyle {
    case none // 什么都没有
    case close // 关闭
    case pop // pop剪头<-
}

enum BYControlType {
    case defaultType // 无任何操作
    case progress // 视频进度调节操作
    case voice // 声音调节
    case light // 屏幕亮度调节
}

//整个屏幕代表的时间
fileprivate let TotalScreenTime = 90.0
fileprivate let LeastDistance = 15.0

fileprivate var PlayViewCMTimeValue: UnsafeMutableRawPointer?
fileprivate var PlayViewStatusObservationContext: UnsafeMutableRawPointer?


@objcMembers
class BYAVPlayer: UIView, UIGestureRecognizerDelegate {
    var playerModel: BYPlayerModel! {
        didSet {
            self.isPauseBySystem = false
            self.seekTime = playerModel.seekTime
            self.titleLabel.text = playerModel.title
            if let tmp = playerModel.playerItem {
                self.currentItem = tmp
            } else {
                self.videoURL = playerModel.videoUrl
            }
            if self.isInitPlayer {
                self.state = .buffering
            } else {
                self.state = .stopped
                self.loadingView.stopAnimating()
            }
        }
    }
    var backBtnStyle = BackBtnStyle.none {
        didSet {
            if backBtnStyle == .pop {
                backBtn.setImage(playerImage("player_icon_nav_back.png"), for: .normal)
                backBtn.setImage(playerImage("player_icon_nav_back.png"), for: .selected)
            } else if backBtnStyle == .close {
                backBtn.setImage(playerImage("close.png"), for: .normal)
                backBtn.setImage(playerImage("close.png"), for: .selected)
            } else {
                backBtn.setImage(nil, for: .normal)
                backBtn.setImage(nil, for: .selected)
            }
        }
    }
    
    /// 是否全屏，需自己维护
    var isFullscreen: Bool = false {
        didSet {
            rateBtn.isHidden = !isFullscreen
            lockBtn.isHidden = !isFullscreen
            
            if isFullscreen {
                lockBtn.isHidden = playerModel.verticalVideo
            }
            
            fullScreenBtn.isSelected = isFullscreen
            if isFullscreen {
                bottomProgress.alpha = 0.0
            }
            
            if BYAVPlayer.IsiPhoneX() {
                // TODO
                if isFullscreen {
                    
                } else {
                    
                }
            }
        }
    }
    
    /// 播放速率(倍速播放，支持0.5、1.0、1.25、1.5、2.0)
    var rate: Float = 1.0 {
        didSet {
            player.rate = rate
            state = .playing
            playOrPauseBtn.isSelected = false
            if rate == 1.25 {
                rateBtn.setTitle(String(format: "%.2f", rate), for: .normal)
                rateBtn.setTitle(String(format: "%.2f", rate), for: .selected)
            } else {
                rateBtn.setTitle(String(format: "%.1f", rate), for: .normal)
                rateBtn.setTitle(String(format: "%.1f", rate), for: .selected)
            }
        }
    }
    
    /// 播放器着色
    override var tintColor: UIColor? {
        didSet {
            progressSlider.minimumTrackTintColor = tintColor
            bottomProgress.progressTintColor = tintColor
        }
    }
    
    var prefersStatusBarHidden = false
    
    var delegate: BYAVPlayerDelegate?
    
    /// 是否开启音量手势
    var enableVolumeGesture = false
    
    /// 是否开启后台播放模式
    var enableBackgroundMode = false
    
    /// 是否开启快进手势
    var enableFastForwardGesture = false
    
    /// 静音
    var muted = false {
        didSet {
            player.isMuted = muted
        }
    }
    
    /// 是否循环播放（不循环则意味着需要手动触发第二次播放）
    var loopPlay = false {
        didSet {
            if player != nil {
                if loopPlay {
                    player.actionAtItemEnd = .none
                } else {
                    player.actionAtItemEnd = .pause
                }
            }
        }
    }
    
    /// 设置playerLayer的填充模式
    var playerLayerGravity = BYPlayerLayerGravity.resize {
        didSet {
            switch playerLayerGravity {
            case .resize:
                self.playerLayer.videoGravity = .resize
                self.videoGravity = AVLayerVideoGravity.resize.rawValue
            case .resizeAspect:
                self.playerLayer.videoGravity = .resizeAspect
                self.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
            case .resizeAspectFill:
                self.playerLayer.videoGravity = .resizeAspectFill
                self.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            }
        }
    }
    
    /// 是否是锁定屏幕旋转状态
    var isLockScreen = false {
        didSet {
            prefersStatusBarHidden = isLockScreen
            ishiddenStatusBar = isLockScreen
            if isLockScreen {
                hiddenControlView()
            } else {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenLockBtn), object: nil)
                showControlView()
                dismissControlView()
            }
        }
    }
    
    // MARK: - public func
    convenience init(_ playerModel: BYPlayerModel) {
        self.init(frame: CGRect.zero)
        self.playerModel = playerModel
    }
    
    /// 播放
    func play() {
        if !isInitPlayer {
            creatPlayerAndReadyToPlay()
            playOrPauseBtn.isSelected = false
        } else {
            if state == .stopped || state == .pause {
                state = .playing
                playOrPauseBtn.isSelected = false
                player.play()
            } else if state == .finished {
                print("finished")
            }
        }
    }
    
    /// 暂停
    func pause() {
        if state == .playing {
            state = .stopped
        }
        player.pause()
        playOrPauseBtn.isSelected = true
    }
    
    /// 获取正在播放的时间点
    ///
    /// - Returns: double的一个时间点
    func currentTime() -> Double {
        if player != nil {
            return CMTimeGetSeconds(player.currentTime())
        }
        return 0.0
    }
    
    /// 获取视频长度
    ///
    /// - Returns: double的一个时间点
    func duration() -> Double {
        guard player != nil else {
            return 0.0
        }
        
        let playerItem = player.currentItem!
        if playerItem.status == .readyToPlay {
            return CMTimeGetSeconds(playerItem.asset.duration)
        }
        return 0.0
    }
    
    /// playOrPauseBtn点击事件
    ///
    /// - Parameter sender: playOrPauseBtn
    func playOrPause(_ sender: UIButton) {
        if state == .stopped || state == .failed {
            play()
            rate = Float(rateBtn.currentTitle!)!
        } else if state == .playing {
            pause()
        } else if state == .finished || state == .pause {
            rate = Float(rateBtn.currentTitle!)!
        }
        delegate?.player(self, clickedPlayOrPauseButton: sender)
    }
    
    /// 重置播放器,然后切换下一个播放资源
    func resetPlayer() {
        currentItem = nil
        isInitPlayer = false
        bottomProgress.progress = 0
        playerModel = nil
        seekTime = 0
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        // 暂停
        pause()
        progressSlider.value = 0
        bottomProgress.progress = 0
        loadingProgress.progress = 0
        leftTimeLabel.text = convertTime(0.0)
        rightTimeLabel.text = convertTime(0.0)
        // 移除原来的layer
        playerLayer.removeFromSuperlayer()
        // 替换PlayerItem为nil
        player.replaceCurrentItem(with: nil)
        player = nil
    }
    
    /// 版本号
    ///
    /// - Returns: 当前版本号
    class func getVersion() -> String {
        return "1.0.0"
    }
    
    /// 获取当前的旋转状态
    ///
    /// - Returns: CGAffineTransform
    class func getCurrentDeviceOrientation() -> CGAffineTransform {
        // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
        let orientation = UIApplication.shared.statusBarOrientation
        // 根据要进行旋转的方向来计算旋转的角度
        if orientation == .portrait {
            return CGAffineTransform.identity
        } else if orientation == .landscapeLeft {
            return CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        } else if orientation == .landscapeRight {
            return CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        }
        return CGAffineTransform.identity
    }
    
    class func IsiPhoneX() -> Bool {
        return UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 1125, height: 2436), (UIScreen.main.currentMode?.size)!) : false
    }
    
    // MARK: - private func
    private func creatPlayerAndReadyToPlay() {
        isInitPlayer = true
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        // 设置player的参数
        if currentItem != nil {
            player = AVPlayer(playerItem: currentItem!)
        } else {
            urlAsset = AVURLAsset(url: videoURL!)
            currentItem = AVPlayerItem(asset: urlAsset!)
            player = AVPlayer(playerItem: currentItem!)
        }
        
        if loopPlay {
            player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        } else {
            player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.pause
        }
        // ios10新添加的属性，如果播放不了，可以试试打开这个代码
        player.automaticallyWaitsToMinimizeStalling = true
        
        player.usesExternalPlaybackWhileExternalScreenIsActive = true
        playerLayer = AVPlayerLayer(player: player)
        // Player视频的默认填充模式，AVLayerVideoGravityResizeAspect
        playerLayer.frame = contentView.layer.bounds
        playerLayer.videoGravity = AVLayerVideoGravity(rawValue: videoGravity)
        contentView.layer.insertSublayer(playerLayer, at: 0)
        state = .buffering
        // 监听播放状态
        initTimer()
        player.play()
    }
    
    private func initTimer() {
        playbackTimeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { (time) in
            self.syncScrubber()
        })
    }
    
    private func syncScrubber() {
        let playerDuration = playerItemDuration()
        let totalTime = Float(CMTimeGetSeconds(playerDuration))
        let nowTime = Double((currentItem?.currentTime().value)!) / Double((currentItem?.currentTime().timescale)!)
        leftTimeLabel.text = convertTime(nowTime)
        rightTimeLabel.text = convertTime(Double(totalTime))
        
        if totalTime.isNaN {
            rightTimeLabel.text = ""
        }
        
        if CMTIME_IS_INVALID(playerDuration) {
            
        }
        
        //拖拽slider中，不更新slider的值
        if isDragingSlider == true {
            
        } else {
            let value = (progressSlider.maximumValue - progressSlider.minimumValue) * Float(nowTime) / totalTime + progressSlider.minimumValue
            progressSlider.value = value
            bottomProgress.setProgress(Float(nowTime) / totalTime, animated: true)
        }
    }
    
    private func playerItemDuration() -> CMTime {
        let playerItem = currentItem!
        if playerItem.status == .readyToPlay {
            return playerItem.duration
        }
        return CMTime.invalid
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        initPlayer()
    }
    
    private func initPlayer() {
        UIApplication.shared.isIdleTimerDisabled = true
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        // player内部的一个view，用来管理子视图
        contentView.backgroundColor = UIColor.black
        addSubview(contentView)
        backgroundColor = UIColor.black
        
        //创建fastForwardView，快进⏩和快退的view
        FF_View.isHidden = true
        contentView.addSubview(FF_View)
        contentView.addSubview(lightView)
        // 设置默认值
        enableVolumeGesture = true
        enableFastForwardGesture = true
        
        // 小菊花
        contentView.addSubview(loadingView)
        loadingView.startAnimating()
        
        // topView
        topView.image = playerImage("top_shadow")
        topView.isUserInteractionEnabled = true
        contentView.addSubview(topView)
        
        // bottomView
        bottomView.image = playerImage("bottom_shadow")
        bottomView.isUserInteractionEnabled = true
        contentView.addSubview(bottomView)
        
        // playOrPauseBtn
        playOrPauseBtn.showsTouchWhenHighlighted = true
        playOrPauseBtn.addTarget(self, action: #selector(playOrPause(_:)), for: .touchUpInside)
        playOrPauseBtn.setImage(playerImage("player_ctrl_icon_pause"), for: .normal)
        playOrPauseBtn.setImage(playerImage("player_ctrl_icon_play"), for: .selected)
        bottomView.addSubview(self.playOrPauseBtn)
        playOrPauseBtn.isSelected = true // //默认状态，即默认是不自动播放
        
        let volumeView = MPVolumeView()
        for view in volumeView.subviews {
            if (view.superclass?.isSubclass(of: UISlider.self))! {
                self.volumeSlider = view as? UISlider
            }
        }
        loadingProgress.progressTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        loadingProgress.trackTintColor = UIColor.clear
        bottomView.addSubview(loadingProgress)
        loadingProgress.setProgress(0.0, animated: false)
        bottomView.sendSubviewToBack(loadingProgress)
        
        // slider
        progressSlider.minimumValue = 0.0
        progressSlider.minimumValue = 1.0
        progressSlider.setThumbImage(playerImage("dot"), for: .normal)
        progressSlider.minimumTrackTintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        progressSlider.backgroundColor = UIColor.clear
        progressSlider.value = 0.0 // 初始值
        // 进度条的拖拽事件
        progressSlider.addTarget(self, action: #selector(stratDragSlide(_:)), for: .valueChanged)
        // 进度条的点击事件
        progressSlider.addTarget(self, action: #selector(updateProgress(_:)), for: [.touchUpInside, .touchUpOutside])
        // 给进度条添加单击手势
        progressTap = UITapGestureRecognizer(target: self, action: #selector(actionTapGesture(_:)))
        progressTap!.delegate = self
        progressSlider.addGestureRecognizer(progressTap!)
        bottomView.addSubview(progressSlider)
        
        bottomProgress.trackTintColor = UIColor.clear
        bottomProgress.progressTintColor = tintColor != nil ? tintColor! : UIColor.green
        bottomProgress.alpha = 0
        contentView.addSubview(bottomProgress)
        
        // fullScreenBtn
        fullScreenBtn.showsTouchWhenHighlighted = true
        fullScreenBtn.addTarget(self, action: #selector(fullScreenAction(_:)), for: .touchUpInside)
        fullScreenBtn.setImage(playerImage("player_icon_fullscreen"), for: .normal)
        fullScreenBtn.setImage(playerImage("player_icon_fullscreen"), for: .selected)
        bottomView.addSubview(fullScreenBtn)
        
        // lockBtn
        lockBtn.showsTouchWhenHighlighted = true
        lockBtn.addTarget(self, action: #selector(lockAction(_:)), for: .touchUpInside)
        lockBtn.setImage(playerImage("player_icon_unlock"), for: .normal)
        lockBtn.setImage(playerImage("player_icon_lock"), for: .selected)
        lockBtn.isHidden = true
        contentView.addSubview(lockBtn)
        
        // leftTimeLabel显示左边的时间进度
        leftTimeLabel.textAlignment = .left
        leftTimeLabel.textColor = UIColor.white
        leftTimeLabel.font = UIFont.systemFont(ofSize: 11)
        bottomView.addSubview(leftTimeLabel)
        leftTimeLabel.text = convertTime(0.0) // 设置默认值
        
        // rightTimeLabel显示右边的总时间
        rightTimeLabel.textAlignment = .right
        rightTimeLabel.textColor = UIColor.white
        rightTimeLabel.font = UIFont.systemFont(ofSize: 11)
        bottomView.addSubview(rightTimeLabel)
        rightTimeLabel.text = convertTime(0.0)
        
        // backBtn
        backBtn.showsTouchWhenHighlighted = true
        backBtn.setImage(playerImage("close.png"), for: .normal)
        backBtn.setImage(playerImage("close.png"), for: .selected)
        backBtn.addTarget(self, action: #selector(colseTheVideo), for: .touchUpInside)
        topView.addSubview(backBtn)
        
        // rateBtn
        rateBtn.addTarget(self, action: #selector(switchRate(_:)), for: .touchUpInside)
        rateBtn.setTitle("1.0", for: .normal)
        rateBtn.setTitle("1.0", for: .selected)
        topView.addSubview(rateBtn)
        rateBtn.isHidden = true
        
        // titleLabel
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        topView.addSubview(titleLabel)
        
        // 加载失败的提示label
        loadFailedLabel.textColor = UIColor.lightGray
        loadFailedLabel.textAlignment = .center
        loadFailedLabel.text = "视频加载失败"
        loadFailedLabel.isHidden = true
        contentView.addSubview(loadFailedLabel)
        
        // 添加子控件的默认约束
        addUIControlConstraints()
        
        // 单击的 Recognizer
        singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap!.numberOfTapsRequired = 1 // 单机
        singleTap!.numberOfTouchesRequired = 1
        singleTap!.delegate = self
        contentView.addGestureRecognizer(singleTap!)
        
        // 双击的 Recognizer
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTouchesRequired = 1
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        // 解决点击当前view时候响应其他控件事件
        singleTap?.delaysTouchesBegan = true
        doubleTap.delaysTouchesBegan = true
        singleTap?.require(toFail: doubleTap) // 如果双击成立，则取消单击手势（双击的时候不会走单击事件
        contentView.addGestureRecognizer(doubleTap)
    }
    
    private func addUIControlConstraints() {
        let views = ["contentView": contentView,
                     "FF_View": FF_View,
                     "loadingView": loadingView,
                     "topView": topView,
                     "bottomView": bottomView,
                     "lockBtn": lockBtn,
                     "playOrPauseBtn": playOrPauseBtn,
                     "leftTimeLabel": leftTimeLabel,
                     "rightTimeLabel": rightTimeLabel,
                     "loadingProgress": loadingProgress,
                     "progressSlider": progressSlider,
                     "bottomProgress": bottomProgress,
                     "fullScreenBtn": fullScreenBtn,
                     "rateBtn": rateBtn,
                     "backBtn": backBtn,
                     "titleLabel": titleLabel,
                     "loadFailedLabel": loadFailedLabel]
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[contentView]-0-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[contentView]-0-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views))
        
        FF_View.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[FF_View(70)]", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[FF_View(120)]", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: FF_View, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: FF_View, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topView(topViewH)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: ["topViewH": BYAVPlayer.IsiPhoneX() ? 50 : 90], views: views))
        contentView.addConstraint(NSLayoutConstraint(item: topView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: topView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: topView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0))
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topView(topViewH)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: ["topViewH": 50], views: views))
        contentView.addConstraint(NSLayoutConstraint(item: topView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: topView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0))
        
        lockBtn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: lockBtn, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15))
        contentView.addConstraint(NSLayoutConstraint(item: lockBtn, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        
        playOrPauseBtn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: playOrPauseBtn, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: playOrPauseBtn, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10))
        
        leftTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: leftTimeLabel, attribute: .leading, relatedBy: .equal, toItem: bottomView, attribute: .leading, multiplier: 1, constant: 50))
        contentView.addConstraint(NSLayoutConstraint(item: leftTimeLabel, attribute: .top, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1, constant: 8))
        
        rightTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: rightTimeLabel, attribute: .trailing, relatedBy: .equal, toItem: bottomView, attribute: .trailing, multiplier: 1, constant: -50))
        contentView.addConstraint(NSLayoutConstraint(item: rightTimeLabel, attribute: .top, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1, constant: 8))
        
        // TODO
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = contentView.bounds
    }
    
    private func convertTime(_ second: Double) -> String {
        let d = Date(timeIntervalSince1970: TimeInterval(second))
        if second/3600 >= 1 {
            dateFormatter.dateFormat = "HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "mm:ss"
        }
        return dateFormatter.string(from: d)
    }
    
    private func dismissControlView() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(autoDismissControlView), object: nil)
        perform(#selector(autoDismissControlView), with: nil, afterDelay: 5.0)
    }
    
    private func showControlView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 1.0
            self.topView.alpha = 1.0
            self.lockBtn.alpha = 1.0
            self.bottomProgress.alpha = 0
            self.isHiddenTopAndBottomView = false
            self.delegate?.player(self, isHiddenTopAndBottomView: self.isHiddenTopAndBottomView)
        }) { (isFinished) in
            
        }
    }
    
    private func seekToTimeToPlay(_ _seekTime: Double) {
        var seekTime1 = Float(_seekTime)
        
        if player != nil && player.currentItem?.status == .readyToPlay {
            if seekTime1 >= totalTime {
                seekTime1 = 0
            }
            if seekTime1 < 0 {
                seekTime1 = 0
            }
            //        int32_t timeScale = self.player.currentItem.asset.duration.timescale;
            //currentItem.asset.duration.timescale计算的时候严重堵塞主线程，慎用
            /* A timescale of 1 means you can only specify whole seconds to seek to. The timescale is the number of parts per second. Use 600 for video, as Apple recommends, since it is a product of the common video frame rates like 50, 60, 25 and 24 frames per second*/
            player.seek(to: CMTimeMakeWithSeconds(Float64(seekTime1), preferredTimescale: (currentItem?.currentTime().timescale)!), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { (isFinished) in
                self.seekTime = 0
            }
        }
    }
    
    private func hiddenControlView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 0.0
            self.topView.alpha = 0.0
            if self.isFullscreen {
                self.bottomProgress.alpha = 1.0
            } else {
                self.bottomProgress.alpha = 0.0
            }
            if self.isLockScreen {
                //5s hiddenLockBtn
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hiddenLockBtn), object: nil)
                self.perform(#selector(self.hiddenLockBtn), with: nil, afterDelay: 5.0)
            } else {
                self.lockBtn.alpha = 0
            }
            self.isHiddenTopAndBottomView = true
            self.delegate?.player(self, isHiddenTopAndBottomView: self.isHiddenTopAndBottomView)
        }) { (isFinished) in
            
        }
    }
    // 计算缓冲进度
    private func availableDuration() -> TimeInterval {
        let loadedTimeRanges = currentItem!.loadedTimeRanges
        let timeRange = loadedTimeRanges.first as! CMTimeRange // 获取缓冲区域
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSeconds = CMTimeGetSeconds(timeRange.duration)
        let result = startSeconds + durationSeconds //  计算缓冲总进度
        return result
    }
    
    private func loadedTimeRanges() {
        if state == .pause {
            
        } else {
            state = .buffering
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            if self.state == .playing || self.state == .finished {
                
            } else {
                self.play()
            }
            self.loadingView.stopAnimating()
        }
    }
    
    private func moveProgressControllWithTempPoint(_ tempPoint: CGPoint) -> Float {
        // 90代表整个屏幕代表的时间
        var tempValue = Double(touchBeginValue + CGFloat(TotalScreenTime) * ((tempPoint.x - self.touchBeginPoint.x)/(UIScreen.main.bounds.size.width)))
        if tempValue > duration() {
            tempValue = duration()
        } else if tempValue < 0 {
            tempValue = 0
        }
        return Float(tempValue)
    }
    
    private func timeValueChangingWithValue(_ value: Float) {
        if CGFloat(value) > touchBeginValue {
            FF_View.stateImageView.image = playerImage("progress_icon_r")
        } else if CGFloat(value) < touchBeginValue {
            FF_View.stateImageView.image = playerImage("progress_icon_l")
        }
        FF_View.isHidden = false
        FF_View.timeLabel.text = String(format: "%@/%@", convertTime(Double(value)), convertTime(Double(totalTime)))
        leftTimeLabel.text = convertTime(Double(value))
    }
    
    
    
    // MARK: - Actions
    @objc func autoDismissControlView() {
        hiddenControlView()
    }
    
    @objc func moviePlayDidEnd(_ notify: Notification) {
        delegate?.playerFinishedPlay(self)
        
        player.seek(to: CMTime.zero, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { (isFinished) in
            if isFinished {
                if self.isLockScreen {
                    self.lockAction(self.lockBtn)
                } else {
                    self.showControlView()
                }
                if self.loopPlay {
                    let deadline = DispatchTime.now() + 0.2
                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                        self.state = .finished
                        self.bottomProgress.progress = 0
                        self.playOrPauseBtn.isSelected = true
                    }
                }
            }
        }
    }
    
    // 进入后台
    @objc func appDidEnterBackground(_ notify: Notification) {
        if state == .finished {
            return
        } else if state == .stopped { // 如果已经人为的暂停了
            isPauseBySystem = false
        } else if state == .playing {
            if enableBackgroundMode {
                playerLayer.player = nil
                playerLayer.removeFromSuperlayer()
                rate = Float(rateBtn.currentTitle!)!
            } else {
                isPauseBySystem = true
                pause()
                state = .pause
            }
        }
    }
    
    // 进入前台
    @objc func appWillEnterForeground(_ notify: Notification) {
        if state == .finished {
            if enableBackgroundMode {
                playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = contentView.bounds
                playerLayer.videoGravity = .resizeAspect
                contentView.layer.insertSublayer(playerLayer, at: 0)
            } else {
                return
            }
        } else if state == .stopped {
            return
        } else if state == .pause {
            if isPauseBySystem {
                isPauseBySystem = false
                play()
            }
        } else if state == .playing {
            if enableBackgroundMode {
                playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = contentView.bounds
                playerLayer.videoGravity = .resizeAspect
                contentView.layer.insertSublayer(playerLayer, at: 0)
                play()
                rate = Float(rateBtn.currentTitle!)!
            } else {
                return
            }
        }
    }
    
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isKind(of: UIControl.self) ?? false {
            return false
        }
        return true
    }
    
    @objc func handleDoubleTap(_ tap: UITapGestureRecognizer) {
        delegate?.player(self, doubleTaped: tap)
    }
    
    @objc func handleSingleTap(_ tap: UITapGestureRecognizer) {
        if isLockScreen {
            if lockBtn.alpha != 0 {
                lockBtn.alpha = 0
                prefersStatusBarHidden = true
                ishiddenStatusBar = true
            } else {
                lockBtn.alpha = 1
                prefersStatusBarHidden = false
                ishiddenStatusBar = false
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenLockBtn), object: nil)
                perform(#selector(hiddenLockBtn), with: nil, afterDelay: 5.0)
            }
        }
        
        delegate?.player(self, singleTaped: tap)
        
        if isLockScreen {
            return
        }
        
        dismissControlView()
        UIView.animate(withDuration: 0.5, animations: {
            if self.bottomView.alpha == 0.0 {
                self.showControlView()
            } else {
                self.hiddenControlView()
            }
        }) { (isFinish) in
            
        }
    }
    
    @objc func hiddenLockBtn() {
        lockBtn.alpha = 0.0
        prefersStatusBarHidden = true
        ishiddenStatusBar = true
        delegate?.player(self, singleTaped: singleTap!)
    }
    
    @objc func switchRate(_ sender: UIButton) {
        var rate = Float(rateBtn.currentTitle!)!
        if rate == 0.5 {
            rate = rate + 0.5
        } else if rate == 1.0 || rate == 1.25 {
            rate = rate + 0.25
        } else if rate == 1.5 || rate == 2 {
            rate = rate + 0.5
        }
        self.rate = rate
    }
    
    @objc func colseTheVideo(_ sender: UIButton) {
        delegate?.player(self, clickedCloseButton: sender)
    }
    
    @objc func stratDragSlide(_ slider: UISlider) {
        isDragingSlider = true
    }
    
    @objc func updateProgress(_ slider: UISlider) {
        isDragingSlider = false
        player.seek(to: CMTime(seconds: Double(slider.value), preferredTimescale: currentItem!.currentTime().timescale))
    }
    
    @objc func actionTapGesture(_ tap: UITapGestureRecognizer) {
        let touchLocation = tap.location(in: progressSlider)
        let value = (progressSlider.maximumValue - progressSlider.minimumValue) * Float(touchLocation.x/progressSlider.frame.size.width)
        progressSlider.setValue(value, animated: true)
        
        player.seek(to: CMTime(seconds: Double(progressSlider.value), preferredTimescale: currentItem!.currentTime().timescale))
        if player.rate != 1.0 {
            playOrPauseBtn.isSelected = false
            player.play()
        }
    }
    
    @objc func fullScreenAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.player(self, clickedFullScreenButton: sender)
    }
    
    @objc func lockAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isLockScreen = sender.isSelected
        delegate?.player(self, clickedLockButton: sender)
    }
    
    // MARK: - touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 这个是用来判断, 如果有多个手指点击则不做出响应
        guard let touch = touches.first else {
            return
        }
        if touches.count > 1 || touch.tapCount > 1 || (event?.allTouches?.count)! > 1 {
            return
        }
        // 这个是用来判断, 手指点击的是不是本视图, 如果不是则不做出响应
        if touch.view != contentView && touch.view != self {
            return
        }
        super.touchesBegan(touches, with: event)
        
        // 触摸开始, 初始化一些值
        hasMoved = false
        touchBeginValue = CGFloat(progressSlider.value)
        // 位置
        touchBeginPoint = touch.location(in: self)
        // 亮度
        touchBeginLightValue = UIScreen.main.brightness
        // 声音
        touchBeginVoiceValue = CGFloat(volumeSlider.value)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        if touches.count > 1 || touch.tapCount > 1 || (event?.allTouches?.count)! > 1 {
            return
        }
        // 这个是用来判断, 手指点击的是不是本视图, 如果不是则不做出响应
        if touch.view != contentView && touch.view != self {
            return
        }
        super.touchesMoved(touches, with: event)
        
        //如果移动的距离过于小, 就判断为没有移动
        let tempPoint = touch.location(in: self)
        if Double(abs(tempPoint.x - touchBeginPoint.x)) < LeastDistance && Double(abs(tempPoint.y - touchBeginPoint.y)) < LeastDistance {
            return
        }
        hasMoved = true
        // 如果还没有判断出使什么控制手势, 就进行判断
        // 滑动角度的tan值
        let tan = abs(tempPoint.y - touchBeginPoint.y) / abs(tempPoint.x - touchBeginPoint.x)
        if tan < 1 / sqrt(3) { //当滑动角度小于30度的时候, 进度手势
            controlType = .progress
        } else if tan > sqrt(3) { // 当滑动角度大于60度的时候, 声音和亮度
            // 判断是在屏幕的左半边还是右半边滑动, 左侧控制为亮度, 右侧控制音量
            if touchBeginPoint.x < bounds.size.width / 2 {
                controlType = .light
            } else {
                controlType = .voice
            }
        } else { // 如果是其他角度则不是任何控制
            controlType = .defaultType
            return
        }
        if controlType == .progress { // 如果是进度手势
            if enableFastForwardGesture {
                let value = moveProgressControllWithTempPoint(tempPoint)
                timeValueChangingWithValue(value)
            }
        } else if controlType == .voice { // 如果是音量手势
            if isFullscreen { // 全屏的时候才开启音量的手势调节
                if enableVolumeGesture {
                    // 根据触摸开始时的音量和触摸开始时的点去计算出现在滑动到的音量
                    let voiceValue = touchBeginVoiceValue - ((tempPoint.y - self.touchBeginPoint.y)/self.bounds.size.height)
                    // 判断控制一下, 不能超出 0~1
                    if voiceValue < 0 {
                        volumeSlider.value = 0
                    } else if voiceValue > 1 {
                        volumeSlider.value = 1
                    } else {
                        volumeSlider.value = Float(voiceValue)
                    }
                }
            } else {
                return
            }
        } else if controlType == .light { // 如果是亮度手势
            if isFullscreen {
                // 根据触摸开始时的亮度, 和触摸开始时的点来计算出现在的亮度
                var tempLightValue = touchBeginLightValue - ((tempPoint.y - touchBeginPoint.y)/self.bounds.size.height)
                if tempLightValue < 0 {
                    tempLightValue = 0
                } else if tempLightValue > 1 {
                    tempLightValue = 1
                }
                // 控制亮度的方法
                UIScreen.main.brightness = tempLightValue
                // 实时改变现实亮度进度的view
                print("亮度调节 = \(tempLightValue)")
                contentView.bringSubviewToFront(lightView)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        // 判断是否移动过
        if hasMoved {
            if controlType == .progress { // 进度控制就跳到响应的进度
                let tempPoint = touches.first?.location(in: self)
                if enableFastForwardGesture {
                    let value = moveProgressControllWithTempPoint(tempPoint!)
                    seekToTimeToPlay(Double(value))
                }
                FF_View.isHidden = true
            } else if controlType == .light { // 如果是亮度控制, 控制完亮度还要隐藏显示亮度的view
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        FF_View.isHidden = true
        super.touchesEnded(touches, with: event)
        // 判断是否移动过
        if hasMoved {
            if controlType == .progress { //进度控制就跳到响应的进度
                if enableFastForwardGesture {
                    let tempPoint = touches.first?.location(in: self)
                    if enableFastForwardGesture {
                        let value = moveProgressControllWithTempPoint(tempPoint!)
                        seekToTimeToPlay(Double(value))
                    }
                    FF_View.isHidden = true
                }
            } else if controlType == .light { // 如果是亮度控制, 控制完亮度还要隐藏显示亮度的view
                
            }
        }
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        /* AVPlayerItem "status" property value observer. */
        if context == PlayViewStatusObservationContext {
            if keyPath == "status" {
                let status = change?[NSKeyValueChangeKey.newKey] as! AVPlayer.Status
                switch status {
                case .unknown:
                    self.loadingProgress.setProgress(0.0, animated: false)
                    self.state = .buffering
                    self.loadingView.startAnimating()
                case .readyToPlay:
                    /* Once the AVPlayerItem becomes ready to play, i.e.
                     [playerItem status] == AVPlayerItemStatusReadyToPlay,
                     its duration can be fetched from the item. */
                    if self.state == .stopped || self.state == .pause {
                        
                    } else {
                        //5s dismiss controlView
                        self.dismissControlView()
                        self.state = .playing
                    }
                    self.delegate?.playerReadyToPlay(self, playerStatus: .playing)
                    self.loadingView.stopAnimating()
                    if self.seekTime != 0 {
                        self.seekToTimeToPlay(self.seekTime)
                    }
                    if self.muted {
                        self.player.isMuted = self.muted
                    }
                    if self.state == .stopped || self.state == .pause {
                        
                    } else {
                        self.rate = Float(self.rateBtn.currentTitle!)!
                    }
                case .failed:
                    self.state = .failed
                    self.delegate?.playerFailedPlay(self, playerStatus: .failed)
                    let error = self.player.currentItem?.error
                    
                    if error != nil {
                        self.loadFailedLabel.isHidden = false
                        self.bringSubviewToFront(self.loadFailedLabel)
                        // here
                        self.loadingView.stopAnimating()
                    }
                    print("视频加载失败===\(error?.localizedDescription ?? "")")
                @unknown default:
                    fatalError()
                }
                
            } else if keyPath == "duration" {
                if Float(CMTimeGetSeconds((self.currentItem?.duration)!)) != totalTime {
                    totalTime = Float(CMTimeGetSeconds(self.currentItem!.asset.duration))
                    
                    if !totalTime.isNaN {
                        progressSlider.maximumValue = Float(totalTime)
                    } else {
                        totalTime = MAXFLOAT
                    }
                    if state == .stopped || state == .pause {
                        
                    } else {
                        state = .playing
                    }
                }
            } else if keyPath == "presentationSize" {
                playerModel.presentationSize = currentItem?.presentationSize
                delegate?.playerGotVideoSize(self, videoSize: playerModel.presentationSize)
            } else if keyPath == "loadedTimeRanges" {
                // 计算缓冲进度
                let timeInterval = availableDuration()
                let duration = currentItem?.duration
                let totalDuration = CMTimeGetSeconds(duration!)
                // 缓冲颜色
                loadingProgress.progressTintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
                loadingProgress.setProgress(Float(timeInterval / totalDuration), animated: false)
            } else if keyPath == "playbackBufferEmpty" {
                loadingView.startAnimating()
                // 当缓冲是空的时候
                if currentItem?.isPlaybackBufferEmpty ?? false {
                    loadedTimeRanges()
                }
            } else if keyPath == "playbackLikelyToKeepUp" {
                loadingView.stopAnimating()
                if (currentItem?.isPlaybackLikelyToKeepUp)! && state == .buffering {
                    if state == .stopped || state == .pause {
                        
                    } else {
                        state = .playing
                    }
                }
            }
        }
    }
    
    // MARK: - private
    
    //顶部&底部操作工具栏
    private let topView = UIImageView()
    private let bottomView = UIImageView()
    // 是否初始化了播放器
    private var isInitPlayer = false
    // 用来判断手势是否移动过
    private var hasMoved = false
    // 总时间
    private var totalTime: Float = 0.0
    // 记录触摸开始时的视频播放的时间
    private var touchBeginValue: CGFloat = 0.0
    // 记录触摸开始亮度
    private var touchBeginLightValue: CGFloat = 0.0
    // 记录触摸开始的音量
    private var touchBeginVoiceValue: CGFloat = 0.0
    // 记录touch开始的点
    private var touchBeginPoint = CGPoint(x: 0, y: 0)
    // 手势控制的类型,用来判断当前手势是在控制进度?声音?亮度?
    private var controlType = BYControlType.defaultType
    // 格式化时间（懒加载防止多次重复初始化）
    private lazy var dateFormatter: DateFormatter = {
        let tmp = DateFormatter()
        tmp.timeZone = NSTimeZone(name: "CMT") as TimeZone?
        return tmp
    }()
    // 监听播放起状态的监听者
    private var playbackTimeObserver: Any?
    // 视频进度条的单击手势&播放器的单击手势
    private var progressTap, singleTap: UITapGestureRecognizer?
    // 是否正在拖曳进度条
    private var isDragingSlider = false
    // BOOL值判断操作栏是否隐藏
    private var isHiddenTopAndBottomView = false {
        didSet {
            prefersStatusBarHidden = isHiddenTopAndBottomView
        }
    }
    // BOOL值判断操作栏是否隐藏
    private var ishiddenStatusBar = false
    // 是否被系统暂停
    private var isPauseBySystem = false
    // 播放器状态
    private var state: BYPlayerState? {
        didSet {
            // 控制菊花显示、隐藏
            if state == .buffering {
                loadingView.startAnimating()
            } else {
                loadingView.stopAnimating()
            }
        }
    }
    // Player内部一个UIView，所有的控件统一管理在此view中
    private let contentView = UIView()
    // 亮度调节的view
    private let lightView = BYLightView()
    // 这个用来显示滑动屏幕时的时间
    private let FF_View = FastForwardView()
    // 显示播放时间的UILabel+加载失败的UILabel+播放视频的title
    private let leftTimeLabel = UILabel()
    private let rightTimeLabel = UILabel()
    private let titleLabel = UILabel()
    private let loadFailedLabel = UILabel()
    // 控制全屏和播放暂停按钮
    private let fullScreenBtn = UIButton()
    private let playOrPauseBtn = UIButton()
    private let lockBtn = UIButton()
    private let backBtn = UIButton()
    private let rateBtn = UIButton()
    // 进度滑块&声音滑块
    private let progressSlider = UISlider()
    private var volumeSlider: UISlider!
    // 显示缓冲进度和底部的播放进度
    private let loadingProgress = UIProgressView(progressViewStyle: .default)
    private let bottomProgress = UIProgressView(progressViewStyle: .default)
    // 菊花（加载框）
    private let loadingView = UIActivityIndicatorView(style: .medium)
    // 当前播放的item
    private var currentItem: AVPlayerItem? {
        didSet {
            if oldValue != nil {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: oldValue)
                oldValue!.removeObserver(self, forKeyPath: "status")
                oldValue!.removeObserver(self, forKeyPath: "loadedTimeRanges")
                oldValue!.removeObserver(self, forKeyPath: "playbackBufferEmpty")
                oldValue!.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
                oldValue!.removeObserver(self, forKeyPath: "duration")
                oldValue!.removeObserver(self, forKeyPath: "presentationSize")
            }
            if currentItem != nil {
                currentItem!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: PlayViewStatusObservationContext)
                
                currentItem!.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: PlayViewStatusObservationContext)
                // 缓冲区空了，需要等待数据
                currentItem!.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: PlayViewStatusObservationContext)
                // 缓冲区有足够数据可以播放了
                currentItem!.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: PlayViewStatusObservationContext)
                
                currentItem!.addObserver(self, forKeyPath: "duration", options: NSKeyValueObservingOptions.new, context: PlayViewStatusObservationContext)
                
                currentItem!.addObserver(self, forKeyPath: "presentationSize", options: NSKeyValueObservingOptions.new, context: PlayViewStatusObservationContext)
                
                player.replaceCurrentItem(with: currentItem!)
                // 添加视频播放结束通知
                NotificationCenter.default.addObserver(self, selector: #selector(moviePlayDidEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentItem)
            }
        }
    }
    // playerLayer,可以修改frame
    private var playerLayer = AVPlayerLayer()
    // player
    private var player: AVPlayer!
    // 播放资源路径URL
    private var videoURL: URL?
    // 播放资源
    private var urlAsset: AVURLAsset?
    // 跳到time处播放
    private var seekTime = 0.0
    // 视频填充模式
    lazy private var videoGravity: String = {
        return AVLayerVideoGravity.resizeAspect.rawValue
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()
        player.pause()
        player.removeTimeObserver(self.playbackTimeObserver as Any)
        
        // 移除观察者
        currentItem?.removeObserver(self, forKeyPath: "status")
        currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        currentItem?.removeObserver(self, forKeyPath: "duration")
        currentItem?.removeObserver(self, forKeyPath: "presentationSize")
        currentItem = nil
        
        playerLayer.removeFromSuperlayer()
        player.replaceCurrentItem(with: nil)
        player = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

fileprivate func calculateTimeWithTimeFormatter(_ timeSecond: Int) -> String {
    var theLastTime = ""
    if timeSecond < 60 {
        theLastTime = String(format: "00:%.2lld", timeSecond)
    } else if timeSecond > 60 && timeSecond < 3600 {
        theLastTime = String(format: "%.2lld:%.2lld", timeSecond / 60, timeSecond % 60)
    } else if timeSecond >= 3600 {
        theLastTime = String(format: "%.2lld:%.2lld:%.2lld", timeSecond / 3600, timeSecond % 3600 / 60, timeSecond % 60)
    }
    return theLastTime
}

fileprivate func playerSrcName(_ file: String) -> String {
    return "BYPlayer.bundle/" + file
}

fileprivate func playerFrameworkSrcName(_ file: String) -> String {
    return "Frameworks/BYPlayer.framework/BYPlayer.bundle/" + file
}

fileprivate func playerImage(_ file: String) -> UIImage? {
    if let image = UIImage(named: playerSrcName(file)) {
        return image
    }
    if let image = UIImage(named: playerFrameworkSrcName(file)) {
        return image
    }
    return nil
}
