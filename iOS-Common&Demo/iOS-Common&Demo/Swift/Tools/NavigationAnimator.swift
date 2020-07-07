//
//  NavigationAnimator.swift
//  pois_retcam_ios
//
//  Created by CardiorayT1 on 2019/1/3.
//  Copyright © 2019 houboye. All rights reserved.
//

import UIKit

enum NavigationAnimationType {
    case normal
    case cross
}

@objc
protocol NavigationAnimatorDelegate {
    func animationWillStart(_ animator: NavigationAnimator)
    func animationDidEnd(_ animator: NavigationAnimator)
}

class NavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var currentOpearation: UINavigationController.Operation?
    var animationType = NavigationAnimationType.normal
    var delegate: NavigationAnimatorDelegate?
    
    private(set) var navigationController: UINavigationController!
    
    init(_ navigationController: UINavigationController) {
        super.init()
        self.navigationController = navigationController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch currentOpearation {
        case .pop?:
            popAnimation(transitionContext)
        case .push?:
            pushAnimation(transitionContext)
        default:
            break
        }
    }
    
    private func pushAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        
        let containerView = transitionContext.containerView
        let navigationController = fromViewController?.navigationController
        let tabbarController = fromViewController?.tabBarController
        //使用xib可能会出现view的size不对的情况
        var frame = fromViewController?.view.frame
        if ((toViewController?.edgesForExtendedLayout)!.rawValue & UIRectEdge.top.rawValue) == 0 {
            frame = frame?.offsetBy(dx: 0, dy: (navigationController?.navigationBar.frame.size.height)! + (navigationController?.navigationBar.frame.origin.y)!)
        }
        if ((toViewController?.edgesForExtendedLayout)!.rawValue & UIRectEdge.bottom.rawValue) == 0 {
            frame = frame?.divided(atDistance: (tabbarController?.tabBar.frame.size.height)!, from: CGRectEdge.maxYEdge).remainder
        }
        
        let hidesBottomBar = (toViewController?.hidesBottomBarWhenPushed)! && navigationController!.viewControllers.first != toViewController
        
        if hidesBottomBar {
            frame!.size.height = (frame?.size.height)! + Device.tabbarHeight
        }
        
        toViewController?.view.frame = frame!
        
        containerView.addSubview((fromViewController?.view)!)
        containerView.addSubview((toViewController?.view)!)
        
        let width = containerView.frame.size.width
        toViewController?.view.frame.origin.x = width
        
        callAnimationWillStart()
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            fromViewController?.view.frame.origin.x = width * 0.5 - (fromViewController?.view.frame.size.width)!
            toViewController?.view.frame.origin.x = width - (toViewController?.view.frame.size.width)!
        }) { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.callAnimationDidEnd()
        }
    }
    
    private func popAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        
        let snapshootHeight = UIApplication.shared.statusBarFrame.size.height + (fromViewController?.navigationController?.navigationBar.frame.size.height)!
        
        let fakeBar = fromViewController?.navigationController?.view.resizableSnapshotView(from: CGRect(x: 0, y: 0, width: (fromViewController?.view.frame.size.width)!, height: snapshootHeight), afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero)
        
        let tureBar = toViewController?.navigationController?.navigationBar
        
        let hidesBottomBar = (toViewController?.hidesBottomBarWhenPushed)! && navigationController.viewControllers.first != toViewController
        
        let tabbar = fromViewController?.tabBarController?.tabBar
        let containerView = transitionContext.containerView
        
        containerView.addSubview((toViewController?.view)!)
        if hidesBottomBar {
            containerView.addSubview(tabbar!)
        }
        if animationType == .cross {
            containerView.addSubview(tureBar!)
            fromViewController?.view.addSubview(fakeBar!)
        }
        containerView.addSubview((fromViewController?.view)!)
        
        let width = containerView.frame.size.width
        toViewController?.view.frame.origin.x = width * 0.5 - (toViewController?.view.frame.size.width)!
        tabbar!.frame.origin.x = width * 0.5 - tabbar!.frame.size.width
        
        callAnimationWillStart()
        
        let tabbarController = fromViewController?.tabBarController
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromViewController?.view.frame.origin.x = width
            toViewController?.view.frame.origin.x = width - (toViewController?.view.frame.size.width)!
            tabbar!.frame.origin.x = width - tabbar!.frame.size.width
            fakeBar?.alpha = 0.0
        }) { (finished) in
            tabbarController?.view.addSubview(tabbar!)
            toViewController?.navigationController?.view.addSubview(tureBar!)
            fakeBar?.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.callAnimationDidEnd()
        }
    }
    
    private func callAnimationWillStart() {
        delegate?.animationWillStart(self)
    }
    
    private func callAnimationDidEnd() {
        delegate?.animationDidEnd(self)
    }
}
