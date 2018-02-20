//
//  CustomAlertViewController.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/08/03.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit

protocol KeyboardView: class {
    var _upperView: UIView! { get set }
    var constraintToAdjust: NSLayoutConstraint! { get set }
    var isAlreadyDisplayed: Bool { get set }
    var transitionMoved: Bool { get set }
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
    var viewPreviousEdgeInset: CGRect! { get set }
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

                _ = _upperView.frame.minY - (kbSize.minY + kbSize.height)
                UIView.animate(withDuration: 0.1, delay: 0.1, animations: {

                    self.constraintToAdjust.constant -= kbSize.height / 2
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
        self.constraintToAdjust.constant = 0
        if viewPreviousEdgeInset != nil {
            view.frame = viewPreviousEdgeInset
        }
        isAlreadyDisplayed = false
    }
}

class CustomAlertViewController: UIViewController {
    //colors
    private let BORDER_COLOR = "9E9E9E"
    private var lineColor = UIColor.init(myHex: "DBDBDF")

    var isAlreadyDisplayed: Bool = false
    var transitionMoved: Bool = false
    private var _title: String?
    private var _message: String?
    //upper view where the title, message, and textview will be
    private var _titleLabel: UILabel!
    private var _messageLabel: UILabel!
    private var _inputTextField: UITextField!
    let delegate = AlertTransitioningDelegate()
    var _upperView: UIView!
    //where to butttons will live.
    private var _actionViews: UIView!
    private var bottomConstraintForUpper: NSLayoutConstraint!
    private var widthConstraintOnlyWhenHorizontal: NSLayoutConstraint!
    private var widthConstraintLeftAndRight: (NSLayoutConstraint, NSLayoutConstraint)!
    var constraintToAdjust: NSLayoutConstraint!
    var typeOfDialog: TypeOfDialog = .alert
    convenience init(title: String?, message: String?) {
        self.init()
        self.transitioningDelegate = delegate
        self._title = title
        self._message = message
        self.modalPresentationStyle = .custom

    }

    deinit {
        print("customAlert gets deinit")
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
            _titleLabel.setAttributeText(color: UIColor.black, string: titleString, start: 0, till: titleString.count, forTextStyle: .headline, weight: 0, useSytemFont: true, typeOfFont: FontList.AppDefault.description, .center)

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
        widthConstraintOnlyWhenHorizontal = _upperView.activateConstraintAutomatically(view, attribute: .width, multiplier: 0.50, constant: 0, toParent: true)

        widthConstraintLeftAndRight = _upperView.activateConstraintLeftAndRightOfParent(view, constant: 32)
        setWidthConstraint()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
        if _inputTextField != nil {
            _inputTextField.becomeFirstResponder()
        }
    }

    private func setWidthConstraint() {
        let ifWidthIsGreater = view.frame.width > view.frame.height
        widthConstraintOnlyWhenHorizontal.isActive = ifWidthIsGreater
        widthConstraintLeftAndRight.0.isActive = !ifWidthIsGreater
        widthConstraintLeftAndRight.1.isActive = !ifWidthIsGreater
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
        passBack(_inputTextField)
    }

    func addCustomViews(customTopConstraint: CGFloat = 8 ,addCustomViewsGiven: () -> (UIView), addCustomConstraints: (UIView) -> ()) {
        let viewToAdd = addCustomViewsGiven()
        let _ = self.view
        if let lastView = _upperView.subviews.last {
            _upperView.addSubview(viewToAdd)
//            viewToAdd.activateConstraintLeftAndRightOfParent(_upperView, constant: 8)
            viewToAdd.activateConstraintAutomatically(lastView, attribute: .top, multiplier: 1.0, constant: customTopConstraint, toParent: false)
            addCustomConstraints(viewToAdd)
        }
    }

    private func addTitleLabelConstraints() {
        _titleLabel.activateConstraintLeftAndRightOfParent(_upperView, constant: 8)
        _titleLabel.setTop(of: _upperView, distance: 24, withMultiplier: 1.0, isParent: true)
        _titleLabel.numberOfLines = 0

    }

    private func addMessageConstraints(view: UIView?) {
        _messageLabel.numberOfLines = 0
        _messageLabel.activateConstraintLeftAndRightOfParent(_upperView, constant: 8)
        if let titleLabel = view as? UILabel {
            _messageLabel.setTop(of: titleLabel, distance: 8, withMultiplier: 1.0, isParent: false)
        } else {
            _messageLabel.setTop(of: _upperView, distance: 24, withMultiplier: 1.0, isParent: true)
        }
    }

    private func addTextFieldConstraint(view: UIView?) {
        _inputTextField.activateConstraintLeftAndRightOfParent(_upperView, constant: 14)
        if let titleLabel = view {
            let constraint = NSLayoutConstraint.init(item: _inputTextField, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 20)
            NSLayoutConstraint.activate([constraint])
            self.view.layoutIfNeeded()
        } else {
            _inputTextField.setTop(of: _upperView, distance: 20, withMultiplier: 1.0, isParent: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if _upperView != nil {
            if _actionViews != nil {
                _upperView.layer.cornerRadius = 16
            }
        }
    }

    func addAction(action: CustomAlertAction) {
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
    func setConstraintsForActionButton() {
        if typeOfDialog == .alert {
            setupAlertForAction()
        }
        else {
            setupConstraintsForSheet()
        }
    }
    
    private func setupAlertForAction(){
        if _actionViews.subviews.count == 1 {
            let view = _actionViews.subviews[0]
            view.activateConstraintLeftAndRightOfParent(_actionViews, constant: 0)
            view.activateConstraintTopAndBottomOfParent(_actionViews, constant: 0)
            view.activateConstraintAutomatically(nil, attribute: .height, multiplier: 1.0, constant: 50, toParent: false, .greaterThanOrEqual)
        } else {
            let actionViewsSubViews = _actionViews.subviews
            for i in 0..<actionViewsSubViews.count {
                let view = actionViewsSubViews[i]
                if i == 0 {
                    view.activateConstraintAutomatically(self._actionViews, attribute: .left, multiplier: 1.0, constant: 0, toParent: true)
                } else {
                    let buttonBefore = actionViewsSubViews[i - 1]
                    let verticalLine = UIView()
                    verticalLine.setWidth(to: 0.5)
                    verticalLine.backgroundColor = lineColor
                    _actionViews.addSubview(verticalLine)
                    verticalLine.activateConstraintTopAndBottomOfParent(_actionViews, constant: 0)
                    verticalLine.activateConstraintAutomatically(buttonBefore, attribute: .left, multiplier: 1.0, constant: 0, toParent: false)
                    view.activateConstraintAutomatically(verticalLine, attribute: .left, multiplier: 1.0, constant: 0, toParent: false)
                    view.activateConstraintAutomatically(buttonBefore, attribute: .width, multiplier: 1.0, constant: 0, toParent: true)
                    view.activateConstraintAutomatically(nil, attribute: .height, multiplier: 1.0, constant: 30, toParent: false, .greaterThanOrEqual)
                    if i == actionViewsSubViews.count - 1 {
                        view.activateConstraintAutomatically(self._actionViews, attribute: .right, multiplier: 1.0, constant: 0, toParent: true)
                    }
                }
                view.activateConstraintAutomatically(self._actionViews, attribute: .top, multiplier: 1.0, constant: 8, toParent: true)
                view.activateConstraintAutomatically(self._actionViews, attribute: .bottom, multiplier: 1.0, constant: 8, toParent: true)
            }
        }
    }
    private func setupConstraintsForSheet(){
        if _actionViews.subviews.count == 1 {
            let view = _actionViews.subviews[0]
            view.activateConstraintLeftAndRightOfParent(_actionViews, constant: 0)
            view.activateConstraintTopAndBottomOfParent(_actionViews, constant: 0)
            view.activateConstraintAutomatically(nil, attribute: .height, multiplier: 1.0, constant: 50, toParent: false, .greaterThanOrEqual)
        } else {
            let actionViewsSubViews = _actionViews.subviews
            var lastView: UIView? = nil
            for i in 0..<actionViewsSubViews.count {
                let view = actionViewsSubViews[i]
                var topView = i == 0 ? self._actionViews : actionViewsSubViews[i - 1]
                if i != 0 {
                    let verticalLine = UIView()
                    verticalLine.setHeight(to: 0.5)
                    verticalLine.backgroundColor = lineColor
                    _actionViews.addSubview(verticalLine)
                    verticalLine.activateConstraintAutomatically(topView, attribute: .top, multiplier: 1.0, constant: 8, toParent: false)
                    verticalLine.activateConstraintLeftAndRightOfParent(self._actionViews, constant: 0)
                    topView = verticalLine
                }
                view.activateConstraintLeftAndRightOfParent(self._actionViews, constant: 0)
                view.activateConstraintAutomatically(topView, attribute: .top, multiplier: 1.0, constant: 8, toParent: topView == self._actionViews)
                lastView = view
            }
            lastView?.activateConstraintAutomatically(self._actionViews, attribute: .bottom, multiplier: 1.0, constant: 8, toParent: true)
        }
    }

    @objc private func callButtonHandler(_ button: CustomAlertAction) {
        if button._style == .cancel {
            self.dismiss(animated: true, completion: nil)
        } else {
            button._action?()
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: size.width, height: size.height)
            self.setWidthConstraint()
        }, completion: {
            _ in
            self._upperView.setNeedsDisplay()
        })
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertLikeAnimation()
    }

//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//
//        let topOrientation = self.navigationController?.visibleViewController?.interfaceOrientation
//
//        let presentingOrientation = presentingViewController?.interfaceOrientation
//
//        return   presentingOrientation!
//    }
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

