//
//  CustomAlertViewController.swift
//  TableViewDynamicsSections
//
//  Created by c.uraga on 2017/07/26.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit
let gray700 = UIColor(myHex: "#9B9B9B")
protocol KeyboardView: class {
    var _upperView: UIView! { get set }
    var constraintToAdjust: NSLayoutConstraint! { get set }
    var isAlreadyDisplayed: Bool { get set}
    var transitionMoved: Bool { get set}
    /// the container view that holds the subviews for the scroll view.
    /// call this function to register the notificaiton of the keyboards.
    func registerForKeyboardNotifications()
    /// this method actually adjusts the view when the keyboard was shown
    func keyboardWasShown(_ notification: NSNotification)
    /// when the keyboard will be hidden, we adjust the scrollview to go back to its previous frame and contentInset
    func keyboardWillBeHidden(_ notification: NSNotification)
    
    
    /// The selector for when the keyboard will be shown. Mostly this will call keyboardWasShown
    var keyboardWillBeShown: Selector { get }
    /// the selector for when the keyboard will be hidden. Mostly this will call keyboardWillBeHidden
    var keyboardWillBeHidden: Selector { get }
    /// the previous uiedgeInset the scrollview had before.
    var viewPreviousEdgeInset: CGRect! { get set}
}

extension KeyboardView where Self: UIViewController {
    
    /// Register for apple suplloed keyboard will be shown/hidden
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: keyboardWillBeShown, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: keyboardWillBeHidden, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /// Is called when the keyboard is shown to adjust the insets of the scrollview.
    ///
    /// - Parameter notification: the notification supploed us with information of the keyboard such as the keyboard size height.
    func keyboardWasShown(_ notification: NSNotification) {
        let info = notification.userInfo
        
        if let kbSize = (info?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print(kbSize)
            print(_upperView.frame)
            print(_upperView.frame.midY)
            if !isAlreadyDisplayed {
                viewPreviousEdgeInset = view.frame
                
                let distanceBetweenMidAnd = _upperView.frame.minY - (kbSize.minY + kbSize.height)
                UIView.animate(withDuration: 0.1, delay:0.1,  animations: {
                    var frame = self._upperView.frame

                    self.constraintToAdjust.constant -= kbSize.height / 2
//                    self.view.frame = CGRect(x: self.viewPreviousEdgeInset.origin.x, y: self.viewPreviousEdgeInset.origin.y + kbSize.height, width: self.viewPreviousEdgeInset.width, height: self.viewPreviousEdgeInset.height)
                })
                isAlreadyDisplayed = true
            }
        }
    }
    
    /// Keyboard will be hidden is self explanatory. We just set scrollview's contenteInset to the previous contentinset.
    ///
    /// - Parameter notification: gets the notification that is set when this method is called. This never gets used in this method.
    func keyboardWillBeHidden(_ notification: NSNotification) {
        print(viewPreviousEdgeInset)
        self.constraintToAdjust.constant  = 0
        if viewPreviousEdgeInset != nil {
            view.frame = viewPreviousEdgeInset
        }
        isAlreadyDisplayed = false
    }
}
extension UIView {
    func createTopAndBottom(color: UIColor, _ size: CGFloat = 1){
        self.createTopBorder(color: color)
        self.createBottomBorder(color: color)
    }
    func createBottomBorder(_ rectSize : CGRect){
        
        let startingPoint = CGPoint(x: rectSize.minX , y: rectSize.maxY)
        let endPoint = CGPoint(x: rectSize.maxX, y: rectSize.maxY)
        
        let path = UIBezierPath()
        path.move(to: startingPoint)
        path.addLine(to: endPoint)
        
        path.lineWidth = 5.0
        tintColor = gray700.withAlphaComponent(0.38)
        tintColor.setStroke()
        
        path.stroke()
        
    }
    func createTopBorder(color: UIColor, _ size: CGFloat = 1){
        let border = CALayer()
        let b : CGFloat = 0
        border.frame = CGRect(x:  b, y: b, width: CGFloat(self.frame.width), height: size)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
    func createRightBorder(color: UIColor, _ size: CGFloat = 1 ){
        let border = CALayer()
        border.frame = CGRect(x:  self.frame.width - 1, y: 0, width: size, height: self.frame.height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
    func createLeftBorder(color: UIColor, _ size: CGFloat = 1){
        let border = CALayer()
        border.frame = CGRect(x:  0, y: 0, width: size, height: self.frame.height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
    func createBottomBorder(color: UIColor, _ size: CGFloat = 1){
        let border = CALayer()
        border.frame = CGRect(x:  0, y: self.frame.height, width: self.frame.width, height: size)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
    
    func createCircleOfView() {
        layer.cornerRadius = self.frame.width / 2
    }
    func enableConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setUpperCurved(borderColor: UIColor){
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
        
        let borderLayer = CAShapeLayer()
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.path = maskLayer.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = 5 * 2
        borderLayer.frame = self.bounds
        self.layer.addSublayer(borderLayer)
    }
    
    
    func setUpperLeftAndButtomLeftCurved(){
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 5, height: 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    func setUpperRightAndButtomRightCurved(){
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 5, height: 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    func setBottomCurved(borderColor: UIColor){
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        
        self.layer.mask = maskLayer
        let borderLayer = CAShapeLayer()
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.path = maskLayer.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = 5 * 2
        borderLayer.frame = self.bounds
        self.layer.addSublayer(borderLayer)
    }
    
}
enum FontList: CustomStringConvertible{
    case HelveticaNeue, HelveticaNeueBold, HelveticaNeueMedium, HelveticaNeueCondensedBold, AppDefault
    var description: String {
        switch self {
        case .HelveticaNeue:
            return "Helvetica Neue"
        case .HelveticaNeueBold:
            return "HelveticaNeue-Bold"
        case .HelveticaNeueMedium:
            return "Helvetica Neue Medium"
        case .HelveticaNeueCondensedBold:
            return "HelveticaNeue-CondensedBold"
        case .AppDefault:
            return "Helvetica Neue"
        }
    }
    
}

func getMutableString(color: UIColor, string: String, start: Int, till: Int, forTextStyle: UIFontTextStyle, weight: CGFloat = 0, useSytemFont: Bool = true, typeOfFont : String = "Helvetica Neue", _ setAlignment: NSTextAlignment = NSTextAlignment.left, _ lineSpacing: CGFloat?  = nil, _ specifiyStaticFontSize: CGFloat?  = nil) -> NSMutableAttributedString{
    let  mutableString = NSMutableAttributedString(string: string)
    
    let fontSize = UIFont.preferredFont(forTextStyle: forTextStyle)
    let range = NSRange.init(location: start, length: till)
    
    //set alignment
    let centeredParagraphStyle = NSMutableParagraphStyle()
    if let lineSpace = lineSpacing {
        centeredParagraphStyle.lineSpacing = lineSpace
        //            centeredParagraphStyle.lineHeightMultiple = lineSpace
    }
    centeredParagraphStyle.alignment = setAlignment
    
    //UIFont
    let font: UIFont
    if useSytemFont {
        font = weight == 0 ? UIFont.boldSystemFont(ofSize: fontSize.pointSize) : UIFont.systemFont(ofSize: fontSize.pointSize, weight: UIFont.Weight(rawValue: weight))
    }
    else {
        let tempFontSize = specifiyStaticFontSize == nil ? fontSize.pointSize : specifiyStaticFontSize!
        guard let fontTemp = UIFont(name: typeOfFont, size: tempFontSize) else {
            fatalError("Wrong font passed. Program will crash")
        }
        font = fontTemp
        
    }
    
    var attributeArray: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor : color]
    attributeArray[NSAttributedStringKey.paragraphStyle] =  centeredParagraphStyle
    mutableString.addAttributes(attributeArray, range: range)
    
    return mutableString
}
extension UILabel{
    func setAttributeColor(color: UIColor, string: String, start: Int, till: Int) {
        let  mutableString = NSMutableAttributedString(string: string)
        let range = NSRange.init(location: start, length: till)
        mutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        self.attributedText = mutableString
    }
    
    /// A helper function sets an attribute font for a uilabel.
    ///
    /// - Parameters:
    ///   - color: The color you want to set
    ///   - string: the string that will be a mutable attributed string
    ///   - start: the start of where you want the attribute to begin(usually 0)
    ///   - till: until what portion of the sting you want it to be(usually the end of the string)
    ///   - forTextStyle: the textStyle you want
    ///   - weight: bold weight(defaults to 0 meaning no bold)
    func setAttributeFont(color: UIColor, string: String, start: Int, till: Int, forTextStyle: UIFontTextStyle, _ weight: CGFloat = 0){
        let  mutableString = NSMutableAttributedString(string: string)
        let fontSize = UIFont.preferredFont(forTextStyle: forTextStyle)
        let range = NSRange.init(location: start, length: mutableString.length)
        let font = weight == 0 ? UIFont.boldSystemFont(ofSize: fontSize.pointSize) : UIFont.systemFont(ofSize: fontSize.pointSize, weight: UIFont.Weight(rawValue: weight))
        mutableString.addAttributes([NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor : color], range: range)
        self.attributedText = mutableString
    }
    
    /// A helper function that sets an attribute font but with a stroke to the text(refer to how the user name appears in HOMEVC)
    ///
    /// - Parameters:
    ///   - color: The color you want to set
    ///   - string: the string that will be a mutable attributed string
    ///   - start: the start of where you want the attribute to begin(usually 0)
    ///   - till: until what portion of the sting you want it to be(usually the end of the string)
    ///   - forTextStyle: the textStyle you want
    ///   - weight: bold weight(defaults to 0 meaning no bold)
    func setAttributeFontStroke(color: UIColor, string: String, start: Int, till: Int, forTextStyle: UIFontTextStyle, _ weight: CGFloat = 0){
        let  mutableString = NSMutableAttributedString(string: string)
        let fontSize = UIFont.preferredFont(forTextStyle: forTextStyle)
        let range = NSRange.init(location: start, length: till)
        
        let font = weight == 0 ? UIFont.boldSystemFont(ofSize: fontSize.pointSize) : UIFont.systemFont(ofSize: fontSize.pointSize, weight: UIFont.Weight(rawValue: weight))
        mutableString.addAttributes([NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.strokeColor : UIColor.black, NSAttributedStringKey.strokeWidth : -2], range: range)
        self.attributedText = mutableString
    }
    
    /// Really shouldnt be using this, should be using one of the above. However, if you want a nonbold attribute font, use this
    ///
    /// - Parameters:
    ///   - color: The color you want to set
    ///   - string: the string that will be a mutable attributed string
    ///   - start: the start of where you want the attribute to begin(usually 0)
    ///   - till: until what portion of the sting you want it to be(usually the end of the string)
    ///   - forTextStyle: the textStyle you want
    func setNonBoldAttributeFont(color: UIColor, string: String, start: Int, till: Int, forTextStyle: UIFontTextStyle){
        let  mutableString = NSMutableAttributedString(string: string)
        //        let fontSize = UIFont.preferredFont(forTextStyle: forTextStyle)
        let range = NSRange.init(location: start, length: till)
        mutableString.addAttributes([NSAttributedStringKey.foregroundColor : color], range: range)
        self.attributedText = mutableString
    }
    
    /// A combination of the above but can change the font text/size
    ///
    /// - Parameters:
    ///   - color: The color you want to set
    ///   - string: the string that will be a mutable attributed string
    ///   - start: the start of where you want the attribute to begin(usually 0)
    ///   - till: until what portion of the sting you want it to be(usually the end of the string)
    ///   - forTextStyle: the textStyle you want
    ///   - weight: bold weight(defaults to 0 meaning no bold)
    ///   - useSytemFont: If you want it to be the system font(san francisco)
    ///   - typeOfFont: if you set false above, YOU MUST PASS A STRING OF THE FONT YOU WANT
    ///   - setAlignment: alignment of the text. Defaults to .left
    ///   - lineSpacing: if needs line spacing. Default to nil
    ///   - specifiyStaticFontSize: If you want it to be a custom font. I suggest avoiding this and just use textStyle. However, if you really want it, you can set your own font size
    func setAttributeText(color: UIColor, string: String, start: Int, till: Int, forTextStyle: UIFontTextStyle, weight: CGFloat = 0, useSytemFont: Bool = true, typeOfFont : String = "Helvetica Neue", _ setAlignment: NSTextAlignment = NSTextAlignment.left, _ lineSpacing: CGFloat? = nil, _ specifiyStaticFontSize: CGFloat?  = nil ) {
        let  mutableString = NSMutableAttributedString(string: string)
        let testString = getMutableString(color: color, string: string, start: start, till: mutableString.length, forTextStyle: forTextStyle, weight: weight, useSytemFont: useSytemFont, typeOfFont: typeOfFont, setAlignment, lineSpacing, specifiyStaticFontSize)
        self.attributedText = testString
    }
}

extension UITextField {
    
    /// Changes the font size, color, etc for the placeholder
    ///
    /// - Parameters:
    ///   - color: The color you want to set
    ///   - string: the string that will be a mutable attributed string
    ///   - start: the start of where you want the attribute to begin(usually 0)
    ///   - till: until what portion of the sting you want it to be(usually the end of the string)
    ///   - forTextStyle: the textStyle you want
    ///   - weight: bold weight(defaults to 0 meaning no bold)
    ///   - useSytemFont: If you want it to be the system font(san francisco)
    ///   - typeOfFont: if you set false above, YOU MUST PASS A STRING OF THE FONT YOU WANT
    ///   - setAlignment: alignment of the text. Defaults to .left
    func setAttributePlaceHolder(color: UIColor, string: String, start: Int, till: Int, forTextStyle: UIFontTextStyle, weight: CGFloat = 0, useSytemFont: Bool = true, typeOfFont : String = "Helvetica Neue", _ setAlignment: NSTextAlignment = NSTextAlignment.left) {
        let  mutableString = NSMutableAttributedString(string: string)
        self.attributedPlaceholder = getMutableString(color: color, string: string, start: start, till: till, forTextStyle: forTextStyle, weight: weight, useSytemFont: useSytemFont, typeOfFont: typeOfFont, setAlignment)
    }
    /// A combination of the above but can change the font text/size
    ///
    /// - Parameters:
    ///   - color: The color you want to set
    ///   - string: the string that will be a mutable attributed string
    ///   - start: the start of where you want the attribute to begin(usually 0)
    ///   - till: until what portion of the sting you want it to be(usually the end of the string)
    ///   - forTextStyle: the textStyle you want
    ///   - weight: bold weight(defaults to 0 meaning no bold)
    ///   - useSytemFont: If you want it to be the system font(san francisco)
    ///   - typeOfFont: if you set false above, YOU MUST PASS A STRING OF THE FONT YOU WANT
    ///   - setAlignment: alignment of the text. Defaults to .left
    ///   - lineSpacing: if needs line spacing. Default to nil
    ///   - specifiyStaticFontSize: If you want it to be a custom font. I suggest avoiding this and just use textStyle. However, if you really want it, you can set your own font size
    func setAttributeText(color: UIColor, string: String, start: Int, till: Int, forTextStyle: UIFontTextStyle, weight: CGFloat = 0, useSytemFont: Bool = true, typeOfFont : String = "Helvetica Neue", _ setAlignment: NSTextAlignment = NSTextAlignment.left) {
        self.attributedText = getMutableString(color: color, string: string, start: start, till: till, forTextStyle: forTextStyle, weight: weight, useSytemFont: useSytemFont, typeOfFont: typeOfFont, setAlignment)
    }
    
}

extension UIButton {
    
    /// Add border to the bottom
    ///
    /// - Parameters:
    ///   - color: <#color description#>
    ///   - width: <#width description#>
    func addBottomBorderWithColorWithImageView(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:(self.imageView?.frame.size.width)!, y:self.frame.size.height - width, width:self.frame.size.width - (self.imageView?.frame.size.width)!, height:width)
        self.layer.addSublayer(border)
    }
}
extension UIButton {
    //If using auto layout: needs to be called after constraints are set. Sets the color of your passing to the background color when the user presses it.
    func backgroundColorWithColor(color: UIColor, state: UIControlState){
        UIGraphicsBeginImageContext(self.bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).addClip()
            context.setFillColor(color.cgColor)
            context.fill(self.bounds)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(image, for: state)
        }
    }
    
    
    
    func setGrayHighlightedBackgroundColor(){
        self.backgroundColorWithColor(color: UIColor.gray, state: .highlighted)
    }
    
    func setAttributeFont(color: UIColor, string: String, start: Int, till: Int, forTextStyle: UIFontTextStyle){
        autoreleasepool {
            let  mutableString = NSMutableAttributedString(string: string)
            let fontSize = UIFont.preferredFont(forTextStyle: forTextStyle)
            let range = NSRange.init(location: start, length: till)
            mutableString.addAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: fontSize.pointSize), NSAttributedStringKey.foregroundColor : color], range: range)
            self.setAttributedTitle(mutableString, for: .normal)
        }
        //        self.setAttributedTitle(<#T##title: NSAttributedString?##NSAttributedString?#>, for: UIControlState)
    }
    /// A combination of the above but can change the font text/size
    ///
    /// - Parameters:
    ///   - color: The color you want to set
    ///   - string: the string that will be a mutable attributed string
    ///   - start: the start of where you want the attribute to begin(usually 0)
    ///   - till: until what portion of the sting you want it to be(usually the end of the string)
    ///   - forTextStyle: the textStyle you want
    ///   - weight: bold weight(defaults to 0 meaning no bold)
    ///   - useSytemFont: If you want it to be the system font(san francisco)
    ///   - typeOfFont: if you set false above, YOU MUST PASS A STRING OF THE FONT YOU WANT
    ///   - setAlignment: alignment of the text. Defaults to .left
    func setAttributeText(color: UIColor, string: String, start: Int, till: Int, forTextStyle: UIFontTextStyle, weight: CGFloat = 0, useSytemFont: Bool = true, typeOfFont : String = "Helvetica Neue", _ setAlignment: NSTextAlignment = NSTextAlignment.left) {
        setAttributedTitle(getMutableString(color: color, string: string, start: start, till: till, forTextStyle: forTextStyle, weight: weight, useSytemFont: useSytemFont, typeOfFont: typeOfFont, setAlignment), for: .normal)
    }
    
    
    func setAttributeFontStroke(color: UIColor, string: String, start: Int, till: Int, forTextStyle: UIFontTextStyle, _ weight: CGFloat = 0){
        let  mutableString = NSMutableAttributedString(string: string)
        let fontSize = UIFont.preferredFont(forTextStyle: forTextStyle)
        let range = NSRange.init(location: start, length: till)
        
        let font = weight == 0 ? UIFont.boldSystemFont(ofSize: fontSize.pointSize) : UIFont.systemFont(ofSize: fontSize.pointSize, weight: UIFont.Weight(rawValue: weight))
        mutableString.addAttributes([NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.strokeColor : UIColor.black, NSAttributedStringKey.strokeWidth : -2], range: range)
        self.setAttributedTitle(mutableString, for: .normal)
        //        self.attributedText = mutableString
    }
    
    /// To make the original setAttributeText take less necessary paramaters. The default type of font will be whatever FontList.AppDefault is. In this
    /// app, it will be Helvetica Neue
    /// - Parameters:
    ///   - color: UIColor
    ///   - string: text to get attributed
    ///   - textStyle: Headline is the default value
    ///   - textAlignment: Default is left alignment
    ///   - typeOfFont: Default to Helvetica Neue
    func setAttributeTextGiven(color: UIColor, string: String, textStyle: UIFontTextStyle = .headline, textAlignment: NSTextAlignment = .left, typeOfFont : String = FontList.AppDefault.description ) {
        self.setAttributeText(color: color, string: string, start: 0, till: string.count, forTextStyle: textStyle, weight: 0, useSytemFont: false, typeOfFont: typeOfFont, textAlignment)
    }
}
extension UIColor {
    
    /*!hexのstringを使えるように。　#があるかないかどっちでもいいですが、ちゃんと５か６まで書いてください！！
     短いコードのhexコードはダメです。
     例：#FFF -> ダメ！
     #FFFFFF ->OK*/
    convenience init(myHex: String) {
        var hex = myHex.uppercased()
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        if hex.characters.count != 6 && hex.characters.count != 5 {
            self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
        }
        else {
            var rgb: UInt32 = 0
            Scanner(string: hex).scanHexInt32(&rgb)
            
            let red:CGFloat = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green:CGFloat = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue:CGFloat = CGFloat((rgb & 0x0000FF)) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
let defaultBlue = UIColor(myHex: "007AFF")
let splitterLightBlue = UIColor(myHex: "DFE2E9")
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


class CustomAlertAction: UIButton{
    var _title: String?
    var _style: CustomAlertStyle
    var _action: (()-> ())?
    override init(frame: CGRect) {
        _title = ""
        _style = .defaultAction
        _action = { print("does nothing") }
        super.init(frame: frame)
    }
    convenience init(title: String?, style: CustomAlertStyle, handler: (()->())?) {
        self.init()
        _title = title
        _style = style
        _action = handler
        if let title = _title {
            let fontList = _style == .cancel ?  FontList.HelveticaNeueBold.description : FontList.HelveticaNeue.description
            self.setAttributeTextGiven(color: style.color, string: title, textStyle: .headline, textAlignment: .center, typeOfFont: fontList)
        }
        self.layer.borderWidth = 0
        self.backgroundColor = UIColor.clear
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AlertLikeAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.6
    var presenting = true
    var originFrame = CGRect.zero
    var justWantToDropDown: Bool = false
    
    /// YOU SHOULD ALWAYS IMPLEMENT THIS. You need to clean up a couple of things to make this class work correctly.
    ///　日本語：このfunctionにイメージを隠すとか、必要なことを入れてください。例えば、画像を表示するときに、imageView.isHidden = trueしてください。
    var dismissCompletion: (()->())?
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromView = fromVC.view,
            let toView = toVC.view  else {
                return
        }
        let containerView = transitionContext.containerView
        let isBottomToTopAnimation = (toVC as? CustomAlertViewController ?? nil) != nil  ? true : false
        if isBottomToTopAnimation {
             containerView.addSubview(toView)
            toView.frame = CGRect(x: containerView.frame.origin.x, y: containerView.frame.origin.y, width: containerView.frame.width, height: containerView.frame.height)
            let upperview = toView.subviews.first!
            upperview.transform = CGAffineTransform.init(scaleX:  1.1, y:  1.1)
            toView.alpha = 0
            let divideBy4 = 0.3 / 2
            UIView.animate(withDuration: divideBy4, delay: 0, options: .curveEaseOut, animations: {
                upperview.transform = CGAffineTransform.identity
                toView.frame = containerView.frame
                toView.alpha = 1
            }, completion: {
                (_)-> Void in
                transitionContext.completeTransition(true)
                
            }
            )
        }
        else {
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
//                toView.alpha = 0
                fromView.alpha = 0
//                fromView.frame = CGRect(x: containerView.frame.origin.x, y: containerView.frame.origin.y, width: containerView.frame.width, height: containerView.frame.height)
            }, completion: {
                (_)-> Void in
                
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
/// Behaves like an alert but instead, you can customize it by adding your own view underneath a title, message, or uitextfield. It comes with its own set of animation so all you need to do is present it!　Only draw back about this class is that you must manually call setConstraintsForActionButton.
///
class CustomAlertViewController: UIViewController{
    var isAlreadyDisplayed: Bool  = false
    var transitionMoved: Bool = false
    private var _title: String?
    private var _message: String?
    //upper view where the title, message, and textview will be
    private var _titleLabel: UILabel!
    private var _messageLabel:UILabel!
    private var _inputTextField: UITextField!
    let delegate = AlertTransitioningDelegate()
    var _upperView: UIView!
    //where to butttons will live.
    private var _actionViews: UIView!
    
    
    private var lineColor = UIColor.init(myHex: "DBDBDF")
    private var bottomConstraintForUpper: NSLayoutConstraint!
    private let BORDER_COLOR = "9E9E9E"
    var constraintToAdjust: NSLayoutConstraint!
    convenience init(title: String?, message: String?) {
        self.init()
        self.transitioningDelegate = delegate
        self._title = title
        self._message = message
        self.modalPresentationStyle = .custom
        
    }
    override func loadView() {
        view = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        
        _upperView = UIView()
        _upperView.backgroundColor = UIColor.init(myHex: "F9F9F9")
        _upperView.layer.cornerRadius = 8
        view.addSubview(_upperView)
        if let titleString = self._title {
            _titleLabel = UILabel()
            _titleLabel.setAttributeText(color: UIColor.black, string: titleString, start: 0, till: titleString.count, forTextStyle: .title3, weight: 0, useSytemFont: false, typeOfFont: FontList.AppDefault.description, .center)
            
            _upperView.addSubview(_titleLabel)
            addTitleLabelConstraints()
        }
        if let messageString = self._message {
            _messageLabel = UILabel()
            _messageLabel.setAttributeText(color: UIColor.black, string: messageString, start: 0, till: messageString.count, forTextStyle: .subheadline, weight: 0, useSytemFont: false, typeOfFont: FontList.AppDefault.description, .center)
            let lastView = _upperView.subviews.last
            _upperView.addSubview(_messageLabel)
            addMessageConstraints(view: lastView)
        }
        constraintToAdjust = _upperView.centerY(to: view)
        _upperView.centerX(to: view)
        _upperView.activateConstraintLeftAndRightOfParent(view, constant: 32)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
        if _inputTextField != nil {
            _inputTextField.becomeFirstResponder()
        }
    }
    
    func addTextField(passBack: (UITextField) -> ()) {
        let _ = self.view
        _inputTextField = PaddingOnTextField()
        _inputTextField.layer.borderColor = UIColor.init(myHex: BORDER_COLOR).cgColor
        _inputTextField.layer.borderWidth = 0.5
        let lastView = _upperView.subviews.last
        _upperView.addSubview(_inputTextField)
        _inputTextField.setHeight(to: 32)
        addTextFieldConstraint(view: lastView)
        _inputTextField.backgroundColor = UIColor.white
        //        _inputTextField.activateConstraintAutomatically(_upperView, attribute: .bottom, multiplier: 1.0, constant: 8, toParent: true)
        passBack(_inputTextField)
    }
    
    func addCustomViews(addCustomViewsGiven: ()->(UIView), addCustomConstraints: (UIView) -> () ){
        let viewToAdd = addCustomViewsGiven()
        if let lastView = _upperView.subviews.last {
            _upperView.addSubview(viewToAdd)
            viewToAdd.activateConstraintLeftAndRightOfParent(_upperView, constant: 8)
            viewToAdd.activateConstraintAutomatically(lastView, attribute: .top, multiplier: 1.0, constant: 8, toParent: false)
            addCustomConstraints(viewToAdd)
        }
    }
    private func addTitleLabelConstraints(){
        _titleLabel.activateConstraintLeftAndRightOfParent(_upperView, constant: 8)
        _titleLabel.setTop(of: _upperView, distance: 24, withMultiplier: 1.0, isParent: true)
        _titleLabel.numberOfLines = 0
        
    }
    private func addMessageConstraints(view: UIView? ){
        _messageLabel.activateConstraintLeftAndRightOfParent(_upperView, constant: 8)
        if let titleLabel =  view as? UILabel {
            _messageLabel.setTop(of: titleLabel, distance: 8, withMultiplier: 1.0, isParent: false)
        }
        else {
            _messageLabel.setTop(of: _upperView, distance: 24, withMultiplier: 1.0, isParent: true)
        }
    }
    private func addTextFieldConstraint(view: UIView? ) {
        _inputTextField.activateConstraintLeftAndRightOfParent(_upperView, constant: 14)
        if let titleLabel =  view {
            let constraint = NSLayoutConstraint.init(item: _inputTextField, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 20)
            NSLayoutConstraint.activate([constraint])
            self.view.layoutIfNeeded()
        }
        else {
            _inputTextField.setTop(of: _upperView, distance: 20, withMultiplier: 1.0, isParent: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if _upperView != nil {
            if _actionViews != nil {
                _upperView.layer.cornerRadius = 16
                //                _upperView.layer.borderWidth = 3
                //                _upperView.layer.borderColor = UIColor.init(myHex: "EEEEEE").cgColor
            }
        }
    }
    
    func addAction(action: CustomAlertAction){
        if _actionViews == nil {
            if _upperView == nil {
                let _ = self.view
            }
            _upperView.layer.cornerRadius = 0
            _actionViews = UIView()
            let last = _upperView.subviews.last ?? _upperView
            let upperLine = UIView()
            upperLine.backgroundColor = lineColor
            _upperView.addSubview(upperLine)
            upperLine.setHeight(to: 0.5)
            upperLine.activateConstraintLeftAndRightOfParent(_upperView, constant: 0)
            upperLine.activateConstraintAutomatically(last, attribute: .top, multiplier: 1.0, constant: 24, toParent: false)
            _upperView.addSubview(_actionViews)
            _actionViews.activateConstraintLeftAndRightOfParent(_upperView, constant: 0)
            _actionViews.activateConstraintAutomatically(upperLine, attribute: .top, multiplier: 1.0, constant: 0, toParent: false)
            _actionViews.activateConstraintAutomatically(_upperView, attribute: .bottom, multiplier: 1.0, constant: 0, toParent: true)
        }
        _actionViews.addSubview(action)
        action.addTarget(self, action: #selector(callButtonHandler(_:)), for: .touchUpInside)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(view.frame)
    }
    //FOR NOW YOU MUST CALL THIS
    func setConstraintsForActionButton(){
        if _actionViews.subviews.count == 1 {
            let view = _actionViews.subviews[0]
            view.activateConstraintLeftAndRightOfParent(_actionViews, constant: 0)
            view.activeConstraintTopAndLeftOfParent(_actionViews, constant: 0)
        }
        else {
            let actionViewsSubViews = _actionViews.subviews
            for i in 0..<actionViewsSubViews.count {
                let view = actionViewsSubViews[i]
                if i == 0 {
                    view.activateConstraintAutomatically(self._actionViews, attribute: .left, multiplier: 1.0, constant: 0, toParent: true)
                }
                else {
                    let buttonBefore = actionViewsSubViews[i - 1]
                    let verticalLine = UIView()
                    verticalLine.setWidth(to: 0.5)
                    verticalLine.backgroundColor = lineColor
                    _actionViews.addSubview(verticalLine)
                    verticalLine.activeConstraintTopAndLeftOfParent(_actionViews, constant: 0)
                    verticalLine.activateConstraintAutomatically(buttonBefore, attribute: .left, multiplier: 1.0, constant: 0, toParent: false)
                    view.activateConstraintAutomatically(verticalLine, attribute: .left, multiplier: 1.0, constant: 0, toParent: false)
                    view.activateConstraintAutomatically(buttonBefore, attribute: .width, multiplier: 1.0, constant: 0, toParent: true)
                    if i == actionViewsSubViews.count  - 1  {
                        view.activateConstraintAutomatically(self._actionViews, attribute: .right, multiplier: 1.0, constant: 0, toParent: true)
                    }
                }
                view.activateConstraintAutomatically(self._actionViews, attribute: .top, multiplier: 1.0, constant: 8, toParent: true)
                view.activateConstraintAutomatically(self._actionViews, attribute: .bottom, multiplier: 1.0, constant: 8, toParent: true)
            }
        }
    }
    
    @objc private func callButtonHandler(_ button: CustomAlertAction){
        if button._style == .cancel {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            button._action?()
            self.dismiss(animated: true, completion: nil)
        }
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        print(parent)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: size.width, height: size.height)
            
//            self.view.activateConstraintAutomatically(self.parent?.view, attribute: .top, multiplier: 1.0, constant: 0, toParent: true)
        }, completion: {
            _ in
            self._upperView.setNeedsDisplay()
//            if self.segmentedControl != nil {
//                self.segmentValueChanged(self.segmentedControl)
//            }
        })
    }

    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue:
     
     
     
     UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertLikeAnimation()
    }
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        <#code#>
//    }
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        <#code#>
//    }
    
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        
        let topOrientation = self.navigationController?.visibleViewController?.interfaceOrientation
        
        let presentingOrientation = presentingViewController?.interfaceOrientation
        
        return   presentingOrientation!
    }
    var viewPreviousEdgeInset: CGRect!
    
    var keyboardWillBeHidden: Selector = #selector(hideKeyboard(_:))
    var keyboardWillBeShown = #selector(showKeyboard(_:))
}
extension CustomAlertViewController {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animation = AlertLikeAnimation()
        return animation
    }
}
extension CustomAlertViewController: KeyboardView {
    
    @objc func hideKeyboard(_ notification: NSNotification) {
        keyboardWillBeHidden(notification)
    }
    
    @objc func showKeyboard(_ notification: NSNotification) {
        keyboardWasShown(notification)
    }
}
