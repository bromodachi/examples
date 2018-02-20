//
//  SendButtonWithNumberOfImages.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/09/08.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit
class RoundedLabel: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2
        layer.masksToBounds = true
        clipsToBounds = true
    }
}
class SendButtonWithNumberOfImages: UIView {
    
    /// Amount of messages a user has left to read
    var amountOfMessages: RoundedLabel!
    // The word send in japanese
    var messageIcon: UILabel!
    
    
    var numberOfMessage: String {
        get {
            if let string = amountOfMessages.text {
                return string
            }
            else {
                return ""
                
            }
        }
        set {
            amountOfMessages.text = newValue
            //            self.amountOfMessages.layer.cornerRadius = (self.amountOfMessages.frame.width * 1.25) / 2
            //            UIView.animate(withDuration: 0.3, animations: {
            //                self.amountOfMessages.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            //                 self.amountOfMessages.layoutIfNeeded()
            //            }, completion: {
            //                (Bool)-> Void in
            //                UIView.animate(withDuration: 0.3, animations: {
            //                    self.amountOfMessages.transform = CGAffineTransform.identity
            //                }, completion: { _ -> Void in
            //                    print(self.amountOfMessages.frame)
            //                    self.amountOfMessages.layer.cornerRadius = 25 / 2
            //                })
            //            })
            
        }
    }
    /// if we have new messages, we unhide the round circle, aka containsNewMessageRound
    private var _hasNewMessages: Bool = false
    
    ///has new messages set/gets if we have new messages or not.
    var hasNewMessages: Bool {
        get {
            return _hasNewMessages
        }
        set(newMessages) {
            _hasNewMessages  = newMessages
        }
    }
    
    
    /// Default inits that sets the view to the frame you want
    ///
    /// - Parameter frame: Size of the view you want it to be
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    /// Inits the view and if we have new messages, we should the green icon
    ///
    /// - Parameter hasNewMessage: true or false on whether we have new messages or not.
    convenience init(hasNewMessage: Bool) {
        self.init(frame: CGRect.zero)
        self.hasNewMessages = hasNewMessage
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        messageIcon = UILabel()
        messageIcon.isUserInteractionEnabled = true
        messageIcon.text = "次へ"
        addSubview(messageIcon)
        messageIcon.activateConstraintLeftAndRightOfParent(self, constant: 0)
        messageIcon.activateConstraintTopAndBottomOfParent(self, constant: 0)
        
        amountOfMessages = RoundedLabel()
        
        amountOfMessages.textColor = UIColor.white
        amountOfMessages.backgroundColor = GetColorForCampOrIishii.mainColor
        amountOfMessages.textAlignment = .center
        addSubview(amountOfMessages)
        amountOfMessages.activateConstraintAutomatically(self, attribute: .width, multiplier: 0.5, constant: 0, toParent: true)
        let constraint = NSLayoutConstraint.init(item: amountOfMessages, attribute: .height, relatedBy: .equal, toItem: amountOfMessages, attribute: .width, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([constraint])
        amountOfMessages.activateConstraintAutomatically(messageIcon, attribute: .centerY, multiplier: 1.0, constant: 0, toParent: true)
        amountOfMessages.activateConstraintAutomatically(messageIcon, attribute: .right, multiplier: 1.0, constant: 5, toParent: false)
        
        
        
    }
    
    /// override layoutsubviews to make the alert icon round
    override func layoutSubviews() {
        super.layoutSubviews()
        print(amountOfMessages.frame)
        amountOfMessages.layer.cornerRadius = amountOfMessages.frame.width / 2
        self.amountOfMessages.layer.masksToBounds = true
        self.amountOfMessages.clipsToBounds = true
    }
    
    
}
