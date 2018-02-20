//
//  MultiImageHorizontalScrollView.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/09/08.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit

class MultiImageHorizontalScrollView: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    fileprivate var listOfViews: [UIImageView]!
    
    func refactorImages(photos  : [UIImage]) {
        //if for some reason, this drops speed, then we will improve it
        listOfViews.removeAll()
        for view in subviews {
            //remove all views
            view.removeFromSuperview()
        }
        for (index, photo) in photos.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.image = photo
            listOfViews.append(imageView)
            addViewToParent(index: index)
        }
    }
    
    
    convenience init(photos  : [UIImage]){
        self.init()
        listOfViews = [UIImageView]()
        refactorImages(photos: photos)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.isPagingEnabled = true
        self.contentSize = CGSize(width: frame.width * listOfViews.count.cgFloat, height: frame.height)
        
    }
    
    
    func addViewToParent(index: Int){
        let width  = self.frame.width
        let height = self.frame.height
        let x = index.cgFloat * width
        let frame = CGRect(x: x, y: 0, width: width, height: height)
        let viewToWorkWith = listOfViews[index]
        viewToWorkWith.frame = frame
        self.addSubview(viewToWorkWith)
    }
}
