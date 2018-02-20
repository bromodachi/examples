//
//  MultiCropperViewController.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/09/08.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit

/// TODO: This class should be joined with the other cropper image controller
class FreeHandCropper: UIViewController, UIScrollViewDelegate {

    weak var delegate : PassImageBack!
    var imageView: UIImageView!
    var scrollView: UIScrollView!
    var image: UIImage?
    var maxY: CGFloat = 0
    var minY: CGFloat = 0
    var lastZoomScale: CGFloat = 1
    var imageConstraintLeft: NSLayoutConstraint!
    var imageConstraintRight: NSLayoutConstraint!
    
    var imageConstraintTop: NSLayoutConstraint!
    var imageConstraintBottom: NSLayoutConstraint!
    var once: Bool = true
    var  minZoomScale:CGFloat!
    var minValue: CGFloat = CGFloat.leastNormalMagnitude
    var maxValue: CGFloat = CGFloat.greatestFiniteMagnitude
    var pointZ: CGRect!
    var circleRect: CGRect!
    var org: UIEdgeInsets!
    var callOnce: Bool = true
    /// gets the crop area of the image and returns that frame. You shouldnt really worry too much about the elementary math used.
    var cropArea:CGRect{
        get{
            let scale = 1/scrollView.zoomScale
            let factor: CGFloat
            if imageView.image!.size.height > imageView.image!.size.width {
                factor = imageView.image!.size.width / cropper.frame.width
            }
            else {
                factor = imageView.image!.size.height / cropper.frame.height
            }
            let imageFrame = imageView.imageFrameRelativeToView
            let x = (scrollView.contentOffset.x + cropper.regionOfInterestGlobal.origin.x ) * scale * factor
            let y = (scrollView.contentOffset.y + cropper.regionOfInterestGlobal.origin.y) * scale * factor
            
            let width = cropper.regionOfInterestGlobal.width * scale * factor
            let height = cropper.regionOfInterestGlobal.height * scale * factor
            return CGRect.init(x: x, y: y, width: width, height: height)
        }
    }
    var cropper: ResizeableRect!
    override func loadView() {
        super.loadView()
        scrollView = UIScrollView()
        scrollView.delegate = self
        cropper = ResizeableRect(frame: view.frame)
        
        view.addSubview(scrollView)
        scrollView.activateConstraintAutomatically(topLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0, toParent: false)
        scrollView.activateConstraintAutomatically(bottomLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0, toParent: false)
        scrollView.activateConstraintLeftAndRightOfParent(view, constant: 0)
        scrollView.backgroundColor = UIColor.black
        scrollView.maximumZoomScale = 4
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        
        imageView = UIImageView()
        scrollView.addSubview(imageView)
        imageView.addSubview(cropper)
        imageView.backgroundColor = UIColor.black
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        imageView.activateConstraintAutomatically(scrollView, attribute: .left, multiplier: 1.0, constant: 0, toParent: true)
        imageView.activateConstraintAutomatically(scrollView, attribute: .right, multiplier: 1.0, constant: 0, toParent: true)
        imageView.activateConstraintAutomatically(scrollView, attribute: .top, multiplier: 1.0, constant: 0, toParent: true)
        imageView.activateConstraintAutomatically(scrollView, attribute: .bottom, multiplier: 1.0, constant: 0, toParent: true)
        imageView.activateConstraintAutomatically(scrollView, attribute: .centerY, multiplier: 1.0, constant: 0, toParent: true)
        imageView.activateConstraintAutomatically(scrollView, attribute: .centerX, multiplier: 1.0, constant: 0, toParent: true)
        
        
        scrollView.contentSize = imageView.image!.size
        scrollView.autoresizingMask = .flexibleWidth
        
        
        
        let previousButton = UIButton()
        view.addSubview(previousButton)
        let backText = "<"
        previousButton.setAttributeFont(color: UIColor.white, string: backText, start: 0, till: backText.characters.count, forTextStyle: .title3)
        previousButton.addTarget(self, action: #selector(previousHandler(_:)), for: .touchUpInside)
        previousButton.setTitleColor(.black, for: .normal)
        previousButton.activateConstraintAutomatically(nil, attribute: .width, multiplier: 1.0, constant: 40, toParent: false)
        previousButton.activateConstraintAutomatically(nil, attribute: .height, multiplier: 1.0, constant: 40, toParent: false)
        previousButton.activateConstraintAutomatically(view, attribute: .top, multiplier: 1.0, constant: 8, toParent: true)
        previousButton.activateConstraintAutomatically(view, attribute: .left, multiplier: 1.0, constant: 16, toParent: true)
        
        let buttonCropImage = UIButton()
        view.addSubview(buttonCropImage)
        let cropText = "使用"
        buttonCropImage.setAttributeFont(color: UIColor.white, string: cropText, start: 0, till: cropText.characters.count, forTextStyle: .title3)
        buttonCropImage.addTarget(self, action: #selector(cropImage(_:)), for: .touchUpInside)
        buttonCropImage.activateConstraintAutomatically(view, attribute: .top, multiplier: 1.0, constant: 8, toParent: true)
        buttonCropImage.activateConstraintAutomatically(view, attribute: .right, multiplier: 1.0, constant: 16, toParent: true)
        buttonCropImage.activateConstraintAutomatically(nil, attribute: .width, multiplier: 1.0, constant: 80, toParent: false)
        buttonCropImage.activateConstraintAutomatically(nil, attribute: .height, multiplier: 1.0, constant: 40, toParent: false)
        
        let cancelButton = UIButton()
        let cancelButtonText = "キャンセル"
        view.addSubview(cancelButton)
        
        cancelButton.setAttributeFont(color: UIColor.white, string: cancelButtonText, start: 0, till: cancelButtonText.characters.count, forTextStyle: .title3)
        cancelButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        cancelButton.activateConstraintAutomatically(view, attribute: .bottom, multiplier: 1.0, constant: 8, toParent: true)
        cancelButton.activateConstraintAutomatically(view, attribute: .left, multiplier: 1.0, constant: 16, toParent: true)
        cancelButton.activateConstraintAutomatically(nil, attribute: .width, multiplier: 1.0, constant: 150, toParent: false)
        cancelButton.activateConstraintAutomatically(nil, attribute: .height, multiplier: 1.0, constant: 40, toParent: false)
        imageView.bringSubview(toFront: cropper)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @objc func dismissController(){
        dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let _ = imageView
        imageView.isUserInteractionEnabled = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var innerImageFrame = scrollView.convert(imageView.imageFrameRelativeToView, to: view)
        innerImageFrame.origin.y -= topLayoutGuide.length
        cropper.frame = imageView.imageFrameRelativeToView
        innerImageFrame.origin.y = 0
        var widthToUse: CGFloat = 0
        var heightToUse: CGFloat = 0
        //TODO: use a function
        widthToUse = isWidthOrHeightLess(value: innerImageFrame.width)
        heightToUse = isWidthOrHeightLess(value: innerImageFrame.height)
        cropper.setRegionOfInterestWithProposedRegionOfInterest(CGRect.init(x: 8, y: 8, width: widthToUse, height: heightToUse))
    }
    private func isWidthOrHeightLess(value: CGFloat) -> CGFloat {
        return value <= 16 ? value : value - 16
    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateScrollInset()
    }
    
    /// When the zoom level is not 1, you must update the scrollview's inset. I've forgotten the logic of this method at the moment of commenting this
    /// but if you read the code, it's probably will make more sense
    private func updateScrollInset() {
        let imageFrame = imageView.imageFrameRelativeToView
        //        if scrollView.zoomScale == 1 {
        //            if typeOfCrop == .rectangle {
        //                scrollView.contentInset = org
        //            }
        //            else {
        //                let newY =  typeOfCrop == .rectangle ? imageView.imageFrameRelativeToView.midY : scrollView.frame.midY -  canHeightValueFromImageView() / 2
        //                let viewRect = AVMakeRect(aspectRatio: imageView.image!.size, insideRect: scrollView.frame)
        //                scrollView.contentInset = UIEdgeInsetsMake((newY - viewRect.minY),
        //                                                           (imageView.imageFrameRelativeToView.minX - circleRect.minX)  * -1,
        //                                                           (newY - viewRect.minY),
        //                                                           (imageView.imageFrameRelativeToView.minX - circleRect.minX)  * -1)
        //            }
        //        }
        //        else {
        //            let width: CGFloat
        //            if typeOfCrop == .circle {
        //                width =  (imageFrame.minX - circleRect.minX)  * -1
        //            }
        //            else {
        //                width =  0
        //            }
        //            if typeOfCrop == .circle {
        //                scrollView.contentInset = UIEdgeInsetsMake(view.convert(cropGuideView.frame, to: scrollView).minY - imageView.imageFrameRelativeToView.minY - scrollView.contentOffset.y,
        //                                                           width,
        //                                                           view.convert(cropGuideView.frame, to: scrollView).minY - imageView.imageFrameRelativeToView.minY - scrollView.contentOffset.y ,
        //                                                           width)
        //            }
        //            else{
        //                scrollView.contentInset = UIEdgeInsetsMake(view.convert(cropGuideView.frame, to: scrollView).minY - imageView.imageFrameRelativeToView.minY - scrollView.contentOffset.y,
        //                                                           width,
        //                                                           view.convert(cropGuideView.frame, to: scrollView).minY - imageView.imageFrameRelativeToView.minY - scrollView.contentOffset.y - (cropGuideView.frame.height / 2),
        //                                                           width)
        //            }
        //        }
    }
    
    
    
    /// Returns the height value. Which is just basically the length of the largest value
    ///
    /// - Returns: Which is just basically the length of the largest value
    func canHeightValueFromImageView()-> CGFloat{
        return imageView.imageFrameRelativeToView.height <=  imageView.imageFrameRelativeToView.width ? imageView.imageFrameRelativeToView.height : imageView.imageFrameRelativeToView.width
    }
    
    @objc func previousHandler(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    /// Crops an image of the given crop area.
    ///
    /// - Parameter button: <#button description#>
    @objc func cropImage(_ button: UIButton) {
        guard let croppedCGImage = imageView.image?.cgImage?.cropping(to: cropArea) else {
            return
        }
        print(cropArea)
        let croppedImage = UIImage(cgImage: croppedCGImage)
        delegate.useImageCropped(image: croppedImage)
        dismiss(animated: true, completion: nil)
    }

}
