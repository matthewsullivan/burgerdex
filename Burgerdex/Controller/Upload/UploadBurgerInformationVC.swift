//
//  UploadBurgerInformationVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-25.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//
import UIKit
import Photos

class UploadBurgerInformationVC: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    let headerBurgerNamePlaceholder  = "Mystery Burger"
    let headerBurgerKitchenPlaceholder  = "Mystery Kitchen"
    let tvPlaceHolder = "Describe your first few bites."
    
    var addIngredientButton: UIButton!
    var badges = [Badge]()
    var details : [String:AnyObject] = [:]
    var firstLayout = true
    var fields : [String:AnyObject] = [:]
    var headerBurgerNameLabel : UILabel!
    var headerKitchenLabel : UILabel!
    var heightConstraint: NSLayoutConstraint!
    var imgView:UIImageView!
    var ingredients = [String]()
    var photo : UIImage!
    var progress:Float =  0.0
    var selectedBadgesIndex = Int()
    var sizingCell: TagCell?
    var TAGS = ["Cheddar Cheese",
                "Lettuce",
                "Beef Patty",
                "Onion",
                "Ketchup",
                "Pickle",
                "Mayo",
                "Tomato",
                "Bacon",
                "Mustard",
                "Purple Onion",
                "BBQ Sauce",
                "Crispy Chicken",
                "Dill Pickle",
                "Garlic",
                "Mushrooms",
                "Relish",
                "Secret Sauce",
                "Black Olives",
                "Fried Egg",
                "Jalapenos",
                "Mozzarella",
                "Red Onion",
                "Back Bacon",
                "Chipotle",
                "Cucumber",
                "Guacamole",
                "Havarti Cheese",
                "Honey",
                "Onion Ring",
                "Pepper Jack Cheese",
                "Sauteed Onion",
                "Swiss Cheese",
                "Tortilla Chips",
                "Tzatziki",
                "Arugula",
                "Avacado",
                "Banana Peppers",
                "Blue Cheese",
                "Buffalo Chicken",
                "Caramelized Onions",
                "Coleslaw",
                "Feta Cheese",
                "Green Olives",
                "Grilled Chicken",
                "Grilled Eggplant",
                "Grilled Peppers",
                "Ham",
                "Honey Mustard",
                "Hot Sauce",
                "Monterey Jack Cheese",
                "Pastrami",
                "Pesto",
                "Pineapple",
                "Provolone Cheese",
                "Pulled Pork",
                "Queso",
                "Quinoa",
                "Ranch",
                "Spinach",
                "Sun-Dried Tomato"]
    var tags = [Tag]()
    
    weak var flowLayout: FlowLayout!
    weak var ingredientCollectionView: UICollectionView!
    weak var submitBtn: UIButton!
    
    @IBAction func submitBtn(_ sender: Any) {
        setInputValueFields()
                
        SwiftSpinner.show(delay: 0, title: "Uploading Burger" , animated: true)
        
        let submit = BurgerSubmit()
        
        details["deviceName"] = UIDevice.current.name as AnyObject
        details["deviceType"] = UIDevice.current.modelName as AnyObject
        details["iphone"] = "1" as AnyObject
        details["ratingLbl"] = "" as AnyObject
        details["seasonal"] = details["limited"] as AnyObject
        details["timezone"] = TimeZone.current.identifier as AnyObject
        
        submit.submitBurger(details: details, image:photo, completion: { (data) in
            if (data[0] as! Int) == 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                           at: UITableView.ScrollPosition.top,
                                           animated: false)
                
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                
                SwiftSpinner.show("Success..", animated: false).addTapHandler({
                    SwiftSpinner.hide()
                }, subtitle: "Tap to dismiss")

                self.delay(seconds: 1.5, completion: {
                    SwiftSpinner.hide()
                })
            } else {
                let response = data[1]

                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                           at: UITableView.ScrollPosition.top,
                                           animated: false)
                
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                
                SwiftSpinner.show("Oops..",animated: false).addTapHandler({
                    SwiftSpinner.hide()
                }, subtitle: (response as! String) + "\n\n Tap anywhere and try again.")
            }
        })
        
        let tmpLbl = UILabel()

        tmpLbl.text = "5.0"
        
        details["ratingLbl"] = tmpLbl
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        details["name"] =  headerBurgerNamePlaceholder as AnyObject
        details["kitchen"] =  headerBurgerKitchenPlaceholder as AnyObject
        details["locations"] = "" as AnyObject
        details["price"] =  "" as AnyObject
        details["descript"] =  tvPlaceHolder as AnyObject
        
        self.view.endEditing(true)
        
        self.tableView.allowsSelection = false
        self.tableView.isScrollEnabled = true
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255,
                                                                     green: 173/255,
                                                                     blue: 107/255,
                                                                     alpha: 1)
        
        let burgerHeaderView = BurgerHeaderView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        
        self.tableView.tableHeaderView  = burgerHeaderView
        
        burgerHeaderView.burgerImage.image =   photo
        
        tableView.estimatedRowHeight = 405.0
        tableView.rowHeight = UITableView.automaticDimension
        
        guard let fusionBadge = Badge.init(ratingTitle: "",
                                           badgeTitle: "fusion",
                                           badgeIcon: UIImage(named: "fusion")!)
        else {
            fatalError("Unable to instantiate fusion badge")
        }
        
        self.badges += [fusionBadge]
        
        guard let veggieBadge = Badge.init(ratingTitle: "",
                                           badgeTitle: "veggie",
                                           badgeIcon: UIImage(named: "veggie")!)
        else {
            fatalError("Unable to instantiate veggie badge")
        }
        
        self.badges += [veggieBadge]
        
        guard let spicyBadge = Badge.init(ratingTitle: "",
                                          badgeTitle: "spicy",
                                          badgeIcon: UIImage(named: "spicy")!)
        else {
            fatalError("Unable to instantiate spicy badge")
        }
        
        self.badges += [spicyBadge]
        
        guard let extinctBadge = Badge.init(ratingTitle: "",
                                            badgeTitle: "extinct",
                                            badgeIcon: UIImage(named: "available")!)
        else {
            fatalError("Unable to instantiate extinct badge")
        }
        
        self.badges += [extinctBadge]
        
        guard let seasonalBadge = Badge.init(ratingTitle: "",
                                             badgeTitle: "limited",
                                             badgeIcon: UIImage(named: "seasonal")!)
        else {
            fatalError("Unable to instantiate seasonal badge")
        }
        
        self.badges += [seasonalBadge]
        
        guard let hasChallengeBadge = Badge.init(ratingTitle: "",
                                                 badgeTitle: "challenge",
                                                 badgeIcon: UIImage(named: "hasChallenge")!)
        else {
            fatalError("Unable to instantiate hasChallenge badge")
        }
        
        self.badges += [hasChallengeBadge]
        
        guard let hasModsBadge = Badge.init(ratingTitle: "",
                                            badgeTitle: "mods",
                                            badgeIcon: UIImage(named: "hasMods")!)
        else {
            fatalError("Unable to instantiate hasChallege badge")
        }
        
        self.badges += [hasModsBadge]
        
        details["fusion"] = "0" as AnyObject
        details["veggie"] = "0" as AnyObject
        details["spicy"] = "0" as AnyObject
        details["extinct"] = "0" as AnyObject
        details["limited"] = "0" as AnyObject
        details["hasChallenge"] = "0" as AnyObject
        details["hasMods"] = "0" as AnyObject
        
        let tmpLbl = UILabel()

        tmpLbl.text = "5.0"
        
        details["ratingLbl"] = tmpLbl
        
        for name in TAGS {
            let tag = Tag()
            tag.name = name
            
            self.tags.append(tag)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UploadBurgerInformationVC.keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UploadBurgerInformationVC.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                   at: UITableView.ScrollPosition.top,
                                   animated: false)
        
        
        let colour = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255, green: 173/255, blue: 107/255,alpha: 1)
        self.navigationController?.navigationBar.backgroundColor = colour
    }
    
    func delay(seconds: Double, completion: @escaping () -> ()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }

    func determineDetailProgress(){
        var atLeastOneIngredient = false
        
        progress = 0.15
        
        if !(fields["name"]?.text ?? "").isEmpty{
            progress = (progress + 0.15 <= 1.0) ? progress + 0.15 : 1.0
            
            headerBurgerNameLabel.text = fields["name"]?.text
        } else {
            headerBurgerNameLabel.text = headerBurgerNamePlaceholder
        }
        
        if !(fields["kitchen"]?.text ?? "").isEmpty{
            progress = (progress + 0.15 <= 1.0) ? progress + 0.15 : 1.0
            
            headerKitchenLabel.text = fields["kitchen"]?.text
        } else {
            headerKitchenLabel.text = headerBurgerKitchenPlaceholder
        }
        
        for tags in self.tags {
            atLeastOneIngredient = tags.selected ? true : false;
        }
        
        if !(fields["locations"]?.text ?? "").isEmpty{progress = (progress + 0.15 <= 1.0) ? progress + 0.15 : 1.0}
        if !(fields["price"]?.text ?? "").isEmpty{progress = (progress + 0.15 <= 1.0) ? progress + 0.15 : 1.0}
        if (fields["descript"]?.text != tvPlaceHolder){progress = (progress + 0.15 <= 1.0) ? progress + 0.15 : 1.0}
        if atLeastOneIngredient{progress = (progress + 0.15 <= 1.0) ? progress + 0.15 : 1.0}
        
        if !(fields["name"]?.text ?? "").isEmpty &&
           !(fields["kitchen"]?.text ?? "").isEmpty &&
           !(fields["locations"]?.text ?? "").isEmpty &&
           !(fields["price"]?.text ?? "").isEmpty &&
           !(fields["descript"]?.text ?? "").isEmpty &&
            (fields["descript"]?.text != tvPlaceHolder) &&
            atLeastOneIngredient{
            
            self.submitBtn.isEnabled = true
            self.submitBtn.alpha = 1.0;
            
        } else {
            self.submitBtn.isEnabled = false
            self.submitBtn.alpha = 0.5;
        }
        
        self.imgView.uploadImage(image:photo, progress: progress)
    }
    
    func redrawIngredientHeight() {
        let height = self.ingredientCollectionView.collectionViewLayout.collectionViewContentSize.height
        
        setInputValueFields()
        
        heightConstraint.constant = height
        
        self.view.layoutIfNeeded()
        self.tableView.reloadData()
    }
    
    func setInputValueFields(){
        details["name"] =  fields["name"]?.text as AnyObject
        details["kitchen"] =  fields["kitchen"]?.text as AnyObject
        details["locations"] =  fields["locations"]?.text as AnyObject
        details["price"] =  fields["price"]?.text as AnyObject
        details["descript"] =  fields["descript"]?.text as AnyObject
        details["rating"] =  fields["rating"]?.text as AnyObject
        details["ingredients"] = ingredients.joined(separator: ", ") as AnyObject
    }
    
    func tableView(_: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {return UITableView.automaticDimension}
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        determineDetailProgress()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        determineDetailProgress()
        
        return true;
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray && textView.isFirstResponder && textView.text == tvPlaceHolder{
            textView.text = nil
            textView.textColor = .gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let calcHeight = textView.sizeThatFits(textView.frame.size).height
        let startHeight = textView.frame.size.height
        
        if startHeight != calcHeight {
            let scrollTo = self.tableView.contentSize.height - self.tableView.frame.size.height
            
            UIView.setAnimationsEnabled(false)
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            self.tableView.setContentOffset(CGPoint(x:0, y:scrollTo), animated: false)
            
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == ""{
            textView.textColor = .lightGray
            textView.text = tvPlaceHolder
        }
        
        determineDetailProgress()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {return 1}
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = scrollView as? UITableView {
            var offset = scrollView.contentOffset.y / 40
            
            if (offset > 1) {
                offset = 1
                
                let colour = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: offset)
                
                
                self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255,
                                                                             green: 173/255,
                                                                             blue: 107/255,
                                                                             alpha: 1)
                self.navigationController?.navigationBar.backgroundColor = colour
            } else {
                let colour = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: offset)
                
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationController?.navigationBar.backgroundColor = colour
            }
            
            let headerView = self.tableView.tableHeaderView as! BurgerHeaderView

            headerView.scrollViewDidScroll(scrollView: scrollView)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UploadInfoCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UploadTableViewCell
        else {
            fatalError("The dequeued cell is not an instance of UploadTableViewCell.")
        }
        
        cell.burgerNameTextField.delegate = self
        cell.kitchenNameTextField.delegate = self
        cell.regionNameTextField.delegate = self
        cell.priceTextField.delegate = self
        cell.burgerDescriptionTextView.delegate = self
        cell.newIngredientTextField.delegate = self
        
        cell.burgerNameTextField.resignFirstResponder()
        cell.kitchenNameTextField.resignFirstResponder()
        cell.regionNameTextField.resignFirstResponder()
        cell.priceTextField.resignFirstResponder()
        cell.burgerDescriptionTextView.resignFirstResponder()
        cell.newIngredientTextField.resignFirstResponder()
        
        flowLayout = cell.flowLayout
        flowLayout.sectionInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        
        ingredientCollectionView = cell.ingredientCollectionView
        
        heightConstraint = cell.heightConstraint
        
        let cellNib = UINib(nibName: "TagCell", bundle: nil)
        
        ingredientCollectionView.register(cellNib, forCellWithReuseIdentifier: "TagCell")

        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! TagCell?
        
        cell.ratingSlider.minimumValue = 0.0
        cell.ratingSlider.maximumValue = 10.0
        cell.ratingSlider.value = 5.0
        cell.ratingSlider.addTarget(self, action: #selector(updateRatingLabel(sender:)), for: .allEvents)
        
        addIngredientButton = cell.addIngredientButton
        addIngredientButton.addTarget(self, action: #selector(addIngredient(_:)), for: .touchUpInside)
        
        cell.burgerDescriptionTextView.delegate = self
        cell.burgerDescriptionTextView.textColor = .lightGray
        cell.burgerDescriptionTextView.text = tvPlaceHolder
        
        fields["name"] = cell.burgerNameTextField
        fields["kitchen"] = cell.kitchenNameTextField
        fields["locations"] = cell.regionNameTextField
        fields["price"] =  cell.priceTextField
        fields["descript"] = cell.burgerDescriptionTextView
        fields["rating"] = cell.ratingNumberLabel
        fields["addIngredientLabel"] = cell.newIngredientTextField
        
        cell.burgerNameTextField.text = details["name"] as! String != headerBurgerNamePlaceholder ?  (details["name"] as! String) : ""
        cell.burgerDescriptionTextView.text = (details["descript"] as! String)
        cell.kitchenNameTextField.text =  details["kitchen"] as! String != headerBurgerKitchenPlaceholder ? (details["kitchen"] as! String) : ""
        cell.priceTextField.text = (details["price"] as! String)
        cell.regionNameTextField.text = (details["locations"] as! String)
        
        self.submitBtn = cell.submitBtn
        
        self.submitBtn.isEnabled = false
        self.submitBtn.alpha = 0.5;
        
        let ratingLbl = Float((details["ratingLbl"]?.text as AnyObject) as! String)

        if (ratingLbl != 5.0) {
            cell.ratingSlider.value = ratingLbl!
            
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {return section == 1 ? 0.0 : 80.0}
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return indexPath.section == 1 ? 80 : tableView.rowHeight}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return 1}
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            let  cell = tableView.dequeueReusableCell(withIdentifier: "UploadHeaderCell") as! UploadHeaderTableViewCell
            
            if (details["name"] as! String) != headerBurgerNamePlaceholder && (details["name"] as! String) != "" {
                cell.burgerName.text = (details["name"] as! String)
            } else {
                cell.burgerName.text = headerBurgerNamePlaceholder
            }
            
            if (details["kitchen"] as! String) != headerBurgerKitchenPlaceholder && (details["kitchen"] as! String) != ""{
                cell.kitchenName.text = (details["kitchen"] as! String)
            } else {
                cell.kitchenName.text = headerBurgerKitchenPlaceholder
            }
            
            headerBurgerNameLabel = cell.burgerName
            headerKitchenLabel = cell.kitchenName
            
            progress = 0.15
            
            self.imgView = cell.progressContainerView
            self.imgView.style = .sector
            
            self.imgView.uploadImage(image:photo, progress: progress)
            
            determineDetailProgress()
            
            return cell.contentView
        }
            
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? UploadTableViewCell else { return }

        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    }
    
    @objc private func addIngredient(_ sender: UIButton?) {
        let ingredientLabel = self.fields["addIngredientLabel"] as! UITextField
        
        if (!(ingredientLabel.text ?? "").isEmpty) {
            if !TAGS.contains(ingredientLabel.text!) {
                let tag = Tag()

                tag.name = ingredientLabel.text
                
                self.tags.append(tag)
                
                ingredientCollectionView.reloadData()
                
                redrawIngredientHeight()
            }
        }
    }
    
    @objc func dismissKeyboard() {view.endEditing(true)}

    @objc func keyboardWillShow(notification: NSNotification){
        let userInfo = notification.userInfo!
        
        var contentInset:UIEdgeInsets = self.tableView.contentInset
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        contentInset.bottom = keyboardFrame.size.height
        
        self.tableView.contentInset = contentInset
        
        determineDetailProgress()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        
        self.tableView.contentInset = contentInset
        
        determineDetailProgress()
    }
    
    @objc func reset() {
        self.imgView.uploadImage(image:photo, progress: progress)
        
        if(progress <= 1.0) {
            self.perform(#selector(self.reset), with: nil, afterDelay: 0.3)
        }
        
        progress += 0.1
    }
    
    @objc func updateRatingLabel(sender: UISlider!) {
        let value = sender.value
        
        DispatchQueue.main.async {
            let ratingLabel = self.fields["rating"] as! UILabel
            
            self.details["ratingLbl"] = self.fields["rating"]
            
            ratingLabel.text = String(format:"%.1f", value)
        }
    }
}

extension UploadBurgerInformationVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width:view.frame.width , height:64)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.ingredientCollectionView {
            self.configureCell(cell: self.sizingCell!, forIndexPath: indexPath as NSIndexPath)
            
            return self.sizingCell!.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        }
        
        return CGSize(width: 65, height: 85)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.ingredientCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath as IndexPath) as! TagCell
            
            self.configureCell(cell: cell, forIndexPath: indexPath as NSIndexPath)
            
            return cell
        } else {
            let burgerBadge = badges[indexPath.row]
            let colour = UIColor(red: 222/255,
                                 green: 173/255,
                                 blue: 107/255,
                                 alpha: 1.0)
            
            var detailsKey = burgerBadge.badgeTitle
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCell", for: indexPath) as? BurgerBadgeCollectionViewCell
            else {
                    fatalError("The dequeued cell is not an instance of BurgerTableViewCell.")
            }
            
            cell.ratingLabel.text = burgerBadge.ratingTitle
            cell.badgeTitle.text = burgerBadge.badgeTitle
            cell.badgeImage.image = burgerBadge.badgeIcon
            cell.selectionStatus.backgroundColor = .clear
            cell.selectionStatus.layer.cornerRadius = cell.selectionStatus.frame.size.width / 2
            cell.selectionStatus.clipsToBounds = true
            
            if burgerBadge.badgeTitle == "challenge" {detailsKey = "hasChallenge"}
            if burgerBadge.badgeTitle == "mods" {detailsKey = "hasMods"}
            
            if (details[detailsKey] as AnyObject) as! String == "1"{
                cell.selectionStatus.backgroundColor = colour
            }
            
            if(firstLayout){
                firstLayout = false
                
                redrawIngredientHeight()
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if (collectionView == self.ingredientCollectionView) {
            tags[indexPath.row].selected = !tags[indexPath.row].selected
            
            determineDetailProgress()
            
            self.ingredientCollectionView.reloadData()
        } else {
            selectedBadgesIndex = indexPath.row
            
            let colour = UIColor(red: 222/255, green: 173/255, blue: 107/255, alpha: 1.0)
            
            if let cell = collectionView.cellForItem(at: indexPath)  as? BurgerBadgeCollectionViewCell {
                
                if (cell.selectionStatus.backgroundColor != colour) {
                    if indexPath.row == 0 {details["fusion"] = "1" as AnyObject}
                    if indexPath.row == 1 {details["veggie"] = "1" as AnyObject}
                    if indexPath.row == 2 {details["spicy"] = "1" as AnyObject}
                    if indexPath.row == 3 {details["extinct"] = "1" as AnyObject}
                    if indexPath.row == 4 {details["limited"] = "1" as AnyObject}
                    if indexPath.row == 5 {details["hasChallenge"] = "1" as AnyObject}
                    if indexPath.row == 6 {details["hasMods"] = "1" as AnyObject}
                    
                    cell.selectionStatus.backgroundColor = colour
                } else {
                    if indexPath.row == 0 {details["fusion"] = "0" as AnyObject}
                    if indexPath.row == 1 {details["veggie"] = "0" as AnyObject}
                    if indexPath.row == 2 {details["spicy"] = "0" as AnyObject}
                    if indexPath.row == 3 {details["extinct"] = "0" as AnyObject}
                    if indexPath.row == 4 {details["limited"] = "0" as AnyObject}
                    if indexPath.row == 5 {details["hasChallenge"] = "0" as AnyObject}
                    if indexPath.row == 6 {details["hasMods"] = "0" as AnyObject}
                    
                    cell.selectionStatus.backgroundColor = UIColor.clear
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.ingredientCollectionView ? tags.count : badges.count
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]

        cell.tagName.text = tag.name
        
        if (tag.selected) {
            if !ingredients.contains(tag.name!) {
                ingredients.append(tag.name!)
            }
        } else {
            if let index = ingredients.firstIndex(of: tag.name!) {
                ingredients.remove(at: index)
            }
        }
        
        cell.tagName.textColor = tag.selected ? UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: 1) : UIColor(red: 56/255,green: 49/255, blue: 40/255, alpha: 1)
        cell.backgroundColor = tag.selected ? UIColor(red: 222/255, green: 173/255, blue: 107/255, alpha: 1): UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    }
}
