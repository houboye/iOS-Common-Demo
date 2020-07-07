//
//  NavigationHandler.swift
//  pois_retcam_ios
//
//  Created by CardiorayT1 on 2019/1/3.
//  Copyright © 2019 houboye. All rights reserved.
//

import UIKit

@objcMembers
class NavigationHandler: NSObject, UIGestureRecognizerDelegate, NavigationAnimatorDelegate {
    
    private(set) var recognizer: UIPanGestureRecognizer!
    
    private var navigationController: UINavigationController!
    private var interaction: UIPercentDrivenInteractiveTransition!
    private var animator: NavigationAnimator!
    private var currentOperation: UINavigationController.Operation!
    private var uiPopShadow: CAGradientLayer! {
        let popShadow = CAGradientLayer()
        popShadow.frame = CGRect(x: -6, y: 0, width: 6, height: (navigationController.tabBarController?.view.frame.size.height)!)
        popShadow.startPoint = CGPoint(x: 1.0, y: 0.5)
        popShadow.endPoint = CGPoint(x: 0, y: 0.5)
        popShadow.colors = [UIColor(white: 0.0, alpha: 0.2).cgColor, UIColor.clear.cgColor]
        
        return popShadow
    }
    private var isAnimating: Bool = false
    
    init(navigationController: UINavigationController) {
        super.init()
        recognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        recognizer.delegate = self
        recognizer.delaysTouchesBegan = false
        navigationController.view.addGestureRecognizer(recognizer)
        animator = NavigationAnimator(navigationController)
        animator.delegate = self
        self.navigationController = navigationController
    }
    
    @objc func pan(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else {
            return
        }
        
        switch recognizer.state {
        case .began:
            let location = recognizer.location(in: view)
            if location.x < view.bounds.midX &&
                navigationController.viewControllers.count > 1 { // left half
                interaction = UIPercentDrivenInteractiveTransition()
                navigationController.popViewController(animated: true)
            }
        case .changed:
            let translation = recognizer.translation(in: view)
            let d = translation.x / view.frame.size.width
            interaction.update(d)
        case .ended, .cancelled:
            if recognizer.location(in: view).x > view.frame.size.width * 0.5 {
                interaction.finish()
            } else {
                interaction.cancel()
            }
            interaction = nil
        default:
            break
        }
    }
    
    // UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let forbid = isForbidInteractivePop(navigationController.topViewController!)
        if forbid || isAnimating {
            return false
        }
        let view = gestureRecognizer.view
        let location = gestureRecognizer.location(in: view)
        return location.x < Device.navigationBarHeight
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.view?.superview?.isKind(of: UITableView.self) ?? false
    }
    
    // NavigationAnimatorDelegate
    func animationWillStart(_ animator: NavigationAnimator) {
        isAnimating = true
    }
    
    func animationDidEnd(_ animator: NavigationAnimator) {
        isAnimating = false
    }
    
    // Private
    func isUseClearBar(_ vc: UIViewController) -> Bool {
        let sel = NSSelectorFromString("useClearBar")
        var use = false
        if vc.responds(to: sel) {
            use = vc.perform(sel)?.takeRetainedValue() as! Bool
        }
        return use
    }
    
    func isForbidInteractivePop(_ vc: UIViewController) -> Bool {
        let sel = NSSelectorFromString("forbidInteractivePop")
        var use = false
        if vc.responds(to: sel) {
            use = vc.perform(sel)?.takeRetainedValue() as! Bool
        }
        return use
    }
}

extension NavigationHandler: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interaction
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        currentOperation = operation
        animator.currentOpearation = operation
        let cross = isUseClearBar(fromVC) || isUseClearBar(toVC)
        animator.animationType = cross ? .cross : .normal
        
        if operation == .pop {
            fromVC.view.layer.addSublayer(uiPopShadow)
        }
        
        return animator
        
    }
}
