//
//  ResizeableRect.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/09/08.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit

/// Inspired by Apple's code in their BarCode example. This allows the user to resize the rect to crop an image to their liking.
class ResizeableRect: UIView, UIGestureRecognizerDelegate {
    
    /// Will only be accessible to this class
    ///
    /// - none: if it's none, then we allow the user to move the rectangle
    /// - topLeft: If it's the top left, we increase/decrease the frame's height or width
    /// - topRight: <#topRight description#>
    /// - topMiddle: <#topMiddle description#>
    /// - bottomMiddle: <#bottomMiddle description#>
    /// - middleLeft: <#middleLeft description#>
    /// - middleRight: <#middleRight description#>
    /// - bottomLeft: <#bottomLeft description#>
    /// - bottomRight: <#bottomRight description#>
    private enum Corners{
        case none
        case topLeft
        case topRight
        case topMiddle
        case bottomMiddle
        case middleLeft
        case middleRight
        case bottomLeft
        case bottomRight
    }
    
    private var minimumRegionOfInterestSize: CGFloat {
        return regionOfInterestCornerTouchThreshold
    }
    
    /// The diameter of the circle that the user can control
    private let regionOfInterestControlDiameter: CGFloat = 12.0
    /// radius
    private var regionOfInterestControlRadius: CGFloat {
        return regionOfInterestControlDiameter / 2.0
    }
    
    /// only init when it's ready to used.
    private lazy var resizeRegionOfInterestGestureRecognizer: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(resizeRegionOfInterestWithGestureRecognizer(_:)))
    }()
    
    
    //Creates a focus like layer with the outside of the rect black see through
    private var maskLayer: CAShapeLayer = CAShapeLayer()
    
    /// Color is red which outlines the rectangle
    private let regionOfInterestOutline = CAShapeLayer()
    private let regionOfInterestCornerTouchThreshold: CGFloat = 50
    private var topLeftControl: CAShapeLayer = CAShapeLayer()
    private var topRightControl: CAShapeLayer = CAShapeLayer()
    private var topMiddle: CAShapeLayer = CAShapeLayer()
    private var bottomMiddle: CAShapeLayer = CAShapeLayer()
    private var middleLeft: CAShapeLayer = CAShapeLayer()
    private var middleRight: CAShapeLayer = CAShapeLayer()
    private var bottomLeftControl: CAShapeLayer = CAShapeLayer()
    private var bottomRightControl: CAShapeLayer = CAShapeLayer()
    private(set) var regionOfInterestGlobal = CGRect.null
    private var currentUserControlledCorner: Corners = .none
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        sharedInit()
    }
    
    private func sharedInit(){
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.opacity = 0.5
        layer.addSublayer(maskLayer)
        
        regionOfInterestOutline.path = UIBezierPath(rect: regionOfInterestGlobal).cgPath
        regionOfInterestOutline.fillColor = UIColor.clear.cgColor
        regionOfInterestOutline.strokeColor = UIColor.red.cgColor
        layer.addSublayer(regionOfInterestOutline)
        
        topLeftControl.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: regionOfInterestControlDiameter, height: regionOfInterestControlDiameter)).cgPath
        topLeftControl.fillColor = UIColor.white.cgColor
        layer.addSublayer(topLeftControl)
        
        topRightControl.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: regionOfInterestControlDiameter, height: regionOfInterestControlDiameter)).cgPath
        topRightControl.fillColor = UIColor.white.cgColor
        layer.addSublayer(topRightControl)
        
        topMiddle.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: regionOfInterestControlDiameter, height: regionOfInterestControlDiameter)).cgPath
        topMiddle.fillColor = UIColor.white.cgColor
        layer.addSublayer(topMiddle)
        
        
        
        middleLeft.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: regionOfInterestControlDiameter, height: regionOfInterestControlDiameter)).cgPath
        middleLeft.fillColor = UIColor.white.cgColor
        layer.addSublayer(middleLeft)
        
        middleRight.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: regionOfInterestControlDiameter, height: regionOfInterestControlDiameter)).cgPath
        middleRight.fillColor = UIColor.white.cgColor
        layer.addSublayer(middleRight)
        
        bottomMiddle.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: regionOfInterestControlDiameter, height: regionOfInterestControlDiameter)).cgPath
        bottomMiddle.fillColor = UIColor.white.cgColor
        layer.addSublayer(bottomMiddle)
        
        bottomLeftControl.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: regionOfInterestControlDiameter, height: regionOfInterestControlDiameter)).cgPath
        bottomLeftControl.fillColor = UIColor.white.cgColor
        layer.addSublayer(bottomLeftControl)
        
        bottomRightControl.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: regionOfInterestControlDiameter, height: regionOfInterestControlDiameter)).cgPath
        bottomRightControl.fillColor = UIColor.white.cgColor
        layer.addSublayer(bottomRightControl)
        resizeRegionOfInterestGestureRecognizer.delegate = self
        addGestureRecognizer(resizeRegionOfInterestGestureRecognizer)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Disable CoreAnimation actions so that the positions of the sublayers immediately move to their new position.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Create the path for the mask layer. We use the even odd fill rule so that the region of interest does not have a fill color.
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        path.append(UIBezierPath(rect: regionOfInterestGlobal))
        path.usesEvenOddFillRule = true
        maskLayer.path = path.cgPath
        
        regionOfInterestOutline.path = CGPath(rect: regionOfInterestGlobal, transform: nil)
        
        topLeftControl.position = CGPoint(x: regionOfInterestGlobal.origin.x - regionOfInterestControlRadius, y: regionOfInterestGlobal.origin.y - regionOfInterestControlRadius)
        topRightControl.position = CGPoint(x: regionOfInterestGlobal.origin.x + regionOfInterestGlobal.size.width - regionOfInterestControlRadius, y: regionOfInterestGlobal.origin.y - regionOfInterestControlRadius)
        
        topMiddle.position = CGPoint(x: regionOfInterestGlobal.origin.x + (regionOfInterestGlobal.size.width / 2 ) - regionOfInterestControlRadius, y: regionOfInterestGlobal.origin.y - regionOfInterestControlRadius)
        bottomMiddle.position = CGPoint(x: regionOfInterestGlobal.origin.x + (regionOfInterestGlobal.size.width / 2 ) - regionOfInterestControlRadius, y: regionOfInterestGlobal.origin.y + regionOfInterestGlobal.size.height - regionOfInterestControlRadius)
        
        middleLeft.position = CGPoint(x: regionOfInterestGlobal.origin.x - regionOfInterestControlRadius, y: regionOfInterestGlobal.origin.y + (regionOfInterestGlobal.size.height / 2) - regionOfInterestControlRadius)
        
        middleRight.position = CGPoint.init(x: regionOfInterestGlobal.origin.x + regionOfInterestGlobal.size.width - regionOfInterestControlRadius, y: regionOfInterestGlobal.origin.y + (regionOfInterestGlobal.size.height / 2) - regionOfInterestControlRadius)
        
        bottomLeftControl.position = CGPoint(x: regionOfInterestGlobal.origin.x - regionOfInterestControlRadius, y: regionOfInterestGlobal.origin.y + regionOfInterestGlobal.size.height - regionOfInterestControlRadius)
        bottomRightControl.position = CGPoint(x: regionOfInterestGlobal.origin.x + regionOfInterestGlobal.size.width - regionOfInterestControlRadius, y: regionOfInterestGlobal.origin.y + regionOfInterestGlobal.size.height - regionOfInterestControlRadius)
        
        CATransaction.commit()
    }
    @objc func resizeRegionOfInterestWithGestureRecognizer(_ resizeRegionOfInterestGestureRecognizer: UIPanGestureRecognizer) {
        let touchLocation = resizeRegionOfInterestGestureRecognizer.location(in: resizeRegionOfInterestGestureRecognizer.view)
        let oldRegionOfInterest = regionOfInterestGlobal
        
        switch resizeRegionOfInterestGestureRecognizer.state {
        case .began:
            
            currentUserControlledCorner = cornerOfRect(oldRegionOfInterest, closestToPointWithTouchThreshold: touchLocation)
        case .changed:
            var newRegionOfInterest = oldRegionOfInterest
            switch currentUserControlledCorner {
            case .none:
                let translation = resizeRegionOfInterestGestureRecognizer.translation(in: resizeRegionOfInterestGestureRecognizer.view)
                if regionOfInterestGlobal.contains(touchLocation) {
                    newRegionOfInterest.origin.x += translation.x
                    newRegionOfInterest.origin.y += translation.y
                }
                resizeRegionOfInterestGestureRecognizer.setTranslation(CGPoint.zero, in: resizeRegionOfInterestGestureRecognizer.view)
            case .topLeft:
                newRegionOfInterest = CGRect(x: touchLocation.x, y: touchLocation.y, width: oldRegionOfInterest.size.width + oldRegionOfInterest.origin.x - touchLocation.x, height: oldRegionOfInterest.size.height + oldRegionOfInterest.origin.y - touchLocation.y)
            case .topMiddle:
                newRegionOfInterest = CGRect(x: oldRegionOfInterest.origin.x, y: touchLocation.y, width: oldRegionOfInterest.size.width, height: oldRegionOfInterest.size.height + oldRegionOfInterest.origin.y - touchLocation.y)
            case .middleLeft:
                newRegionOfInterest = CGRect(x: touchLocation.x, y: oldRegionOfInterest.origin.y, width: oldRegionOfInterest.size.width + oldRegionOfInterest.origin.x - touchLocation.x, height: oldRegionOfInterest.size.height )
            case .middleRight:
                newRegionOfInterest = CGRect(x:  oldRegionOfInterest.origin.x, y:  oldRegionOfInterest.origin.y, width: touchLocation.x - oldRegionOfInterest.origin.x, height: oldRegionOfInterest.size.height )
                
            case .topRight:
                newRegionOfInterest = CGRect(x: newRegionOfInterest.origin.x, y: touchLocation.y, width: touchLocation.x - newRegionOfInterest.origin.x, height: oldRegionOfInterest.size.height + newRegionOfInterest.origin.y - touchLocation.y)
            case .bottomMiddle:
                newRegionOfInterest = CGRect(x: oldRegionOfInterest.origin.x, y: oldRegionOfInterest.origin.y, width: oldRegionOfInterest.size.width, height: touchLocation.y - oldRegionOfInterest.origin.y )
            case .bottomLeft:
                newRegionOfInterest = CGRect(x: touchLocation.x,
                                             y: oldRegionOfInterest.origin.y,
                                             width: oldRegionOfInterest.size.width + oldRegionOfInterest.origin.x - touchLocation.x,
                                             height: touchLocation.y - oldRegionOfInterest.origin.y)
            case .bottomRight:
                newRegionOfInterest = CGRect(x: oldRegionOfInterest.origin.x,
                                             y: oldRegionOfInterest.origin.y,
                                             width: touchLocation.x - oldRegionOfInterest.origin.x,
                                             height: touchLocation.y - oldRegionOfInterest.origin.y)
            }
            setRegionOfInterestWithProposedRegionOfInterest(newRegionOfInterest)
        case .ended:
            
            currentUserControlledCorner = .none
        default:
            return
        }
    }
    func setRegionOfInterestWithProposedRegionOfInterest(_ proposedRegionOfInterest: CGRect){
        guard let mother = self.superview?.frame else {
            fatalError("no mother")
        }
        let visible = mother.intersection(CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height))
        let oldRegion = regionOfInterestGlobal
        var newRegion = proposedRegionOfInterest.standardized
        if currentUserControlledCorner == .none {
            var xOff:CGFloat = 0
            var yOff: CGFloat = 0
            let zero:CGFloat = CGFloat(0)
            if !visible.contains(newRegion.origin) {
                xOff = max(visible.minX - newRegion.minX , zero)
                yOff = max(visible.minY - newRegion.minY, zero)
            }
            if !visible.contains(CGPoint(x: visible.maxX, y: visible.maxY)) {
                xOff = min(visible.maxX - newRegion.maxX, xOff)
                yOff = min(visible.maxY - newRegion.maxY, yOff)
            }
            newRegion = newRegion.offsetBy(dx: xOff, dy: yOff)
        }
        newRegion = visible.intersection(newRegion)
        if proposedRegionOfInterest.size.width < minimumRegionOfInterestSize {
            switch currentUserControlledCorner {
            case .bottomLeft, .topLeft:
                newRegion.origin.x = oldRegion.origin.x + oldRegion.size.width - minimumRegionOfInterestSize
                newRegion.size.width = minimumRegionOfInterestSize
            case .topRight:
                newRegion.origin.x = oldRegion.origin.x
                newRegion.size.width = minimumRegionOfInterestSize
            default:
                newRegion.origin = oldRegion.origin
                newRegion.size.width = minimumRegionOfInterestSize
            }
        }
        if proposedRegionOfInterest.size.height < minimumRegionOfInterestSize {
            switch currentUserControlledCorner {
            case .bottomLeft, .topLeft:
                newRegion.origin.y = oldRegion.origin.y + oldRegion.size.height - minimumRegionOfInterestSize
                newRegion.size.height = minimumRegionOfInterestSize
            case .topRight:
                newRegion.origin.y = oldRegion.origin.y
                newRegion.size.height = minimumRegionOfInterestSize
            default:
                newRegion.origin = oldRegion.origin
                newRegion.size.height = minimumRegionOfInterestSize
            }
        }
        
        regionOfInterestGlobal = newRegion
        //Should never be called, but incase the rect is infinity, we just append it to the while rect of its parent
        if regionOfInterestGlobal.origin.x == CGFloat.infinity {
            regionOfInterestGlobal.origin.x = 0
            regionOfInterestGlobal.origin.y = 0
            regionOfInterestGlobal.size.height = self.frame.height
            regionOfInterestGlobal.size.width = self.frame.width
        }
        setNeedsLayout()
    }
    private func cornerOfRect(_ rect: CGRect, closestToPointWithTouchThreshold point: CGPoint) -> Corners {
        var closestDistance = CGFloat.greatestFiniteMagnitude
        var closetCorner: Corners = .none
        let corners: [(Corners, CGPoint)] = [
            (Corners.topLeft, rect.origin),
            (Corners.topRight, CGPoint.init(x: rect.maxX, y: rect.minY)),
            (Corners.topMiddle, CGPoint.init(x: rect.midX, y: rect.minY)),
            (Corners.middleLeft, CGPoint.init(x: rect.minX, y: rect.midY)),
            (Corners.middleRight, CGPoint.init(x: rect.maxX, y: rect.midY)),
            (Corners.bottomMiddle, CGPoint.init(x: rect.midX, y: rect.maxY)),
            (Corners.bottomLeft, CGPoint.init(x: rect.minX, y: rect.maxY)),
            (Corners.bottomRight, CGPoint.init(x: rect.maxX, y: rect.maxY))
        ]
        for (corner, cornerPoint) in corners {
            let deltaX = point.x - cornerPoint.x
            let deltaY = point.y - cornerPoint.y
            let distance = sqrt((deltaX * deltaX) + (deltaY * deltaY) )
            
            if distance < closestDistance {
                closestDistance = distance
                closetCorner = corner
            }
        }
        if closestDistance > regionOfInterestCornerTouchThreshold {
            return .none
        }
        return closetCorner
        
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Ignore drags outside of the region of interest (plus some padding).
        if gestureRecognizer == resizeRegionOfInterestGestureRecognizer {
            let touchLocation = touch.location(in: gestureRecognizer.view)
            
            let paddedRegionOfInterest = regionOfInterestGlobal.insetBy(dx: -regionOfInterestCornerTouchThreshold, dy: -regionOfInterestCornerTouchThreshold)
            if !paddedRegionOfInterest.contains(touchLocation) {
                return false
            }
        }
        
        return true
    }
    var previewViewRegionOfInterestObserveContext = 0
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow multiple gesture recognizers to be recognized simultaneously if and only if the touch location is not within the touch threshold.
        if gestureRecognizer == resizeRegionOfInterestGestureRecognizer {
            let touchLocation = gestureRecognizer.location(in: gestureRecognizer.view)
            
            let closestCorner = cornerOfRect(regionOfInterestGlobal, closestToPointWithTouchThreshold: touchLocation)
            return closestCorner == .none
        }
        
        return true
    }
    
    
}
