//
//  CustomAlertAction.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/08/03.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit

enum CustomAlertStyle {
    case defaultAction, destructive, cancel


    var color: UIColor {
        switch self {
        case .defaultAction:
            return defaultBlue
        case .destructive:
            return UIColor.red
        case .cancel:
            return defaultBlue
        }
    }
}

class CustomAlertAction: UIButton {
    var _title: String?
    var _style: CustomAlertStyle
    var _action: (() -> ())?
    override init(frame: CGRect) {
        _title = ""
        _style = .defaultAction
        _action = {
            print("does nothing")
        }

        super.init(frame: frame)
    }

    convenience init(title: String?, style: CustomAlertStyle, handler: (() -> ())?) {
        self.init()
        _title = title
        _style = style
        _action = handler
        if let title = _title {
            let fontList = _style == .cancel ?  FontList.HelveticaNeueBold.description : FontList.HelveticaNeue.description
            self.setAttributeTextGiven(color: style.color, string: title, textStyle: .headline, textAlignment: .center, typeOfFont: fontList)
        }
        self.layer.borderWidth = 0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
