//
//  ViewController.swift
//  TableViewDynamicsSections
//
//  Created by c.uraga on 2017/07/26.
//  Copyright © 2017年 c.uraga. All rights reserved.
//
extension NSLayoutAttribute {
    func getOpposite(_ isParent: Bool, value: CGFloat) -> (NSLayoutAttribute, CGFloat) {
        switch self {
        case .left:
            return isParent ? (.left, value) : (.right, value)
        case .right:
            return isParent ? (.right, value * -1) : (.left, value * -1)
        case .top:
            return isParent ? (.top, value * 1 ) : (.bottom, value * 1)
        case .bottom:
            return isParent ? (.bottom, value * -1) : (.top, value * -1)
        case .height:
            return isParent ? (.height, value) : (.notAnAttribute , value)
        case .width:
            return isParent ? (.width, value) : (.notAnAttribute , value)
        default:
            return (self, value)
        }
    }
    
    
}
extension Array {
    subscript(safe index: Int) -> Element? {
        return index < endIndex && index >= startIndex  ? self[index] : nil
    }
}
//extension NSLayoutConstraint {
//
//    override open var description: String {
//
//        let id = identifier ?? ""
//        return "id: \(id), constant: \(constant)" //you may print whatever you want here
//    }
//}
extension UIView {
    @discardableResult func activateConstraintAutomatically(_ toView: Any?, attribute: NSLayoutAttribute, multiplier: CGFloat, constant: CGFloat, toParent: Bool, _ relatedBy : NSLayoutRelation = .equal) -> NSLayoutConstraint{
        
        self.translatesAutoresizingMaskIntoConstraints = false
        let tuple = attribute.getOpposite(toParent, value: constant)
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: toView, attribute: tuple.0, multiplier: multiplier, constant: tuple.1)
        var constraintArray:[NSLayoutConstraint] = [NSLayoutConstraint]()
        //            [NSLayoutConstraint].init
        autoreleasepool {
            constraintArray.append(constraint)
            NSLayoutConstraint.activate(constraintArray)
        }
        return constraint
        
    }
    
    func activateConstraintLeftAndRightOfParent(_ parent: Any?, constant: CGFloat){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.activateConstraintAutomatically(parent, attribute: .left, multiplier: 1.0, constant: constant, toParent: true)
        self.activateConstraintAutomatically(parent, attribute: .right, multiplier: 1.0, constant: constant, toParent: true)
    }
    
    func activeConstraintTopAndLeftOfParent(_ parent: Any?, constant: CGFloat){
        self.activateConstraintAutomatically(parent, attribute: .top, multiplier: 1.0, constant: constant, toParent: true)
        self.activateConstraintAutomatically(parent, attribute: .bottom, multiplier: 1.0, constant: constant, toParent: true)
    }
    func activateConstraintLessAndGreater(to parent: Any?, attribute: NSLayoutAttribute, greater: CGFloat, less: CGFloat,  toParent: Bool){
        self.activateConstraintAutomatically(parent, attribute: attribute, multiplier: 1.0, constant: greater, toParent: toParent, .greaterThanOrEqual)
        self.activateConstraintAutomatically(parent, attribute: attribute, multiplier: 1.0, constant: less, toParent: toParent, .lessThanOrEqual)
    }
}
//These have not yet been tested fully. Just to make things writer and clearer to the reader
extension UIView {
    @discardableResult func centerX(to view: UIView) -> NSLayoutConstraint{
        return self.activateConstraintAutomatically(view, attribute: .centerX, multiplier: 1.0, constant: 0, toParent: true)
    }
    @discardableResult func centerY(to view: UIView)-> NSLayoutConstraint {
        return self.activateConstraintAutomatically(view, attribute: .centerY, multiplier: 1.0, constant: 0, toParent: true)
    }
    @discardableResult func setHeight(to value: CGFloat, withMultiplier: CGFloat = 1.0, parentView: UIView? = nil)-> NSLayoutConstraint{
        let toParent = parentView != nil
        return self.activateConstraintAutomatically(parentView, attribute: .height, multiplier: withMultiplier, constant: value, toParent: toParent)
    }
    @discardableResult func setWidth(to value: CGFloat, withMultiplier: CGFloat = 1.0, parentView: UIView? = nil) -> NSLayoutConstraint {
        let toParent = parentView != nil
        return self.activateConstraintAutomatically(parentView, attribute: .width, multiplier: withMultiplier, constant: value, toParent: toParent)
    }
    @discardableResult func setLeft(of view: UIView?, distance: CGFloat, withMultiplier: CGFloat = 1.0, isParent: Bool = true) -> NSLayoutConstraint {
        return self.activateConstraintAutomatically(view, attribute: .left, multiplier: withMultiplier, constant: distance, toParent: isParent)
    }
    @discardableResult func setRight(of view: UIView?, distance: CGFloat, withMultiplier: CGFloat = 1.0, isParent: Bool = true) -> NSLayoutConstraint {
        return self.activateConstraintAutomatically(view, attribute: .right, multiplier: withMultiplier, constant: distance, toParent: isParent)
    }
    @discardableResult func setTop(of view: UIView?, distance: CGFloat, withMultiplier: CGFloat = 1.0, isParent: Bool = false) -> NSLayoutConstraint {
        return self.activateConstraintAutomatically(view, attribute: .top, multiplier: withMultiplier, constant: distance, toParent: isParent)
    }
}
import UIKit

class ViewController: UITableViewController , UIPopoverPresentationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    var sections: [String]!
    var items: [[String]]!
    var textField: UITextField!
    var saveIndexOfRowSelected: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        sections = [String]()
        items = [[String]]()
//        appendValueAndIncreaseItems(sectionName: "others")
//        items[0].append("no items")
        tableView.backgroundColor = UIColor.white
        let addSections = UIBarButtonItem(title: "Add section", style: .done, target: self, action: #selector(addSections(_:)))
        let addItems = UIBarButtonItem(title: "Add item", style: .done, target: self, action: #selector(addItem(_:)))
        navigationItem.rightBarButtonItems = [addSections, addItems]
        // Do any additional setup after loading the view, typically from a nib.
    }
//    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return sections[section]
//    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    func appendValueAndIncreaseItems(sectionName: String){
        sections.append(sectionName)
        items.append([String]())
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIden")
        cell?.textLabel?.text = items[indexPath.section][indexPath.row]
        return cell!
    }
    @objc func addSections(_ button: UIButton){
        
        var valueToAppend: String?
        let alert = UIAlertController(title: "This is a title rawr!", message: "新規道具リストを作成する新規道具リストの名前を入力", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {
            textfield in
            self.textField = textfield
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { (action) in
            self.appendNewSection(value: self.textField.text)
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            print("alert view: ", alert.view.frame)
        })
        present(alert, animated: true, completion: nil)
    }
    @objc func addItem(_ button: UIButton) {
        saveIndexOfRowSelected = 0
        let alert = CustomAlertViewController(title: "Add a new item", message: "Message here")
        alert.addTextField(passBack: {
            textfield in
            self.textField = textfield
            
        })
        alert.addCustomViews(addCustomViewsGiven: { () -> (UIView) in
            let pickerView = UIPickerView()
            pickerView.dataSource = self
            pickerView.delegate = self
            return pickerView
        }, addCustomConstraints: {(view) in
            view.setHeight(to: 60)
        })
        alert.addAction(action: CustomAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(action: CustomAlertAction(title: "Add", style: .defaultAction, handler: {
            self.appendNewItem(value: self.textField.text)
        }))
        alert.setConstraintsForActionButton()
        
        present(alert, animated: true, completion: nil)
    }
    func appendNewItem(value: String?){
        guard let valueToAppend = value, let _ = items[safe: saveIndexOfRowSelected] else {
            return
        }
        items[saveIndexOfRowSelected].append(valueToAppend)
        tableView.insertRows(at: [IndexPath.init(row: items[saveIndexOfRowSelected].count - 1 , section: saveIndexOfRowSelected)], with: .automatic)
    }
    func appendNewSection(value: String?) {
        if let valueToAppend = value {
            appendValueAndIncreaseItems(sectionName: valueToAppend)
//            IndexSet.init(integer: 0)
            tableView.beginUpdates()
            tableView.insertSections(IndexSet.init(integer: sections.count - 1), with: .automatic)
            tableView.endUpdates()
            print(sections)
//            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
//        return .none
//    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // returns the # of rows in each component..
    @available(iOS 2.0, *)
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sections.count
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributedString: NSAttributedString = NSAttributedString(string: "")
        autoreleasepool {
            attributedString = NSAttributedString(string: sections[row], attributes: [NSAttributedStringKey.foregroundColor:UIColor.black])
        }
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 20
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        saveIndexOfRowSelected = row
    }


}

