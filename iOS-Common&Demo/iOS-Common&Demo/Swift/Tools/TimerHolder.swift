import UIKit

@objc
protocol TimerHolderDelegate {
    func onTimerFired(_ holder: TimerHolder)
}

class TimerHolder: NSObject {
    @objc weak var timerDelegate: TimerHolderDelegate?
    
    @objc func startTimer(seconds: TimeInterval, delegate: TimerHolderDelegate, repeats: Bool) {
        timerDelegate = delegate
        _repeats = repeats
        if (_timer.isSome) {
            _timer?.invalidate()
            _timer = nil
        }
        _timer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(on(timer:)), userInfo: nil, repeats: repeats)
    }
    
    @objc func stopTimer() {
        _timer?.invalidate()
        _timer = nil
        timerDelegate = nil
    }
    
    // private
    private var _timer: Timer?
    private var _repeats = false
    
    @objc private func on(timer: Timer) {
        if !_repeats {
            _timer = nil
        }
        timerDelegate?.onTimerFired(self)
    }
    
    deinit {
        stopTimer()
    }
}
