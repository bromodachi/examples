//
//  AlertTransitioningDelegate.swift
//  TableViewDynamicsSections
//
//  Created by c.uraga on 2017/07/27.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit

class AlertTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    @available(iOS 2.0, *)
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertLikeAnimation()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertLikeAnimation()
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AlertPresentation(presentedViewController: presented, presenting: presenting)
    }
}
