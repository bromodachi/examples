//
//  PaddingOnTextField.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/08/03.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit

class PaddingOnTextField: UITextField {

    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds,
                UIEdgeInsetsMake(0, 5, 0, 5))
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds,
                UIEdgeInsetsMake(0, 5, 0, 5))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds,
                UIEdgeInsetsMake(0, 5, 0, 5))

    }
}
