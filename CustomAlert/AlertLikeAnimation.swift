//
//  AlertLikeAnimation.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/08/03.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit


class AlertLikeAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    let duration = 0.6
    var presenting = true
    var originFrame = CGRect.zero
    var justWantToDropDown: Bool = false

    /// YOU SHOULD ALWAYS IMPLEMENT THIS. You need to clean up a couple of things to make this class work correctly.
    ///　日本語：このfunctionにイメージを隠すとか、必要なことを入れてください。例えば、画像を表示するときに、imageView.isHidden = trueしてください。
    var dismissCompletion: (() -> ())?
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
              let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
              let fromView = fromVC.view,
              let toView = toVC.view else {
            return
        }
        let containerView = transitionContext.containerView
        let isBottomToTopAnimation = (toVC as? CustomAlertViewController ?? nil) != nil  ? true : false
        if isBottomToTopAnimation {
            containerView.addSubview(toView)
            toView.frame = CGRect(x: containerView.frame.origin.x, y: containerView.frame.origin.y, width: containerView.frame.width, height: containerView.frame.height)
            let upperview = toView.subviews.first!
            upperview.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
            toView.alpha = 0
            let divideBy4 = 0.3 / 2
            UIView.animate(withDuration: divideBy4, delay: 0, options: .curveEaseOut, animations: {
                upperview.transform = CGAffineTransform.identity
                toView.frame = containerView.frame
                toView.alpha = 1
            }, completion: {
                (_) -> Void in
                transitionContext.completeTransition(true)

            }
            )
        } else {

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                //                toView.alpha = 0
                fromView.alpha = 0
                //                fromView.frame = CGRect(x: containerView.frame.origin.x, y: containerView.frame.origin.y, width: containerView.frame.width, height: containerView.frame.height)
            }, completion: {
                (_) -> Void in

                //                    toView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
            )
        }
    }

    func animationEnded(_ transitionCompleted: Bool) {
        print(transitionCompleted)
    }
}
