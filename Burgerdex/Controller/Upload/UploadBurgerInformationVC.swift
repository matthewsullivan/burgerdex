//
//  UploadBurgerInformationVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-25.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit
import Photos

class UploadBurgerInformationVC: UITableViewController, UITextFieldDelegate, UITextViewDelegate{
    
    var photo : PHAsset!
    var badges = [Badge]()
    var fields : [String:AnyObject] = [:]
    var selectedBadgesIndex = Int()

    let TAGS = ["Cheddar Cheese",
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
    
    var sizingCell: TagCell?
    
    var tags = [Tag]()
    
    var heightConstraint: NSLayoutConstraint!
    
    weak var ingredientCollectionView: UICollectionView!
    weak var flowLayout: FlowLayout!
    
    var firstLayout = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.endEditing(true)
        
        self.tableView.allowsSelection = false
        self.tableView.isScrollEnabled = true
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255,
                                                                     green: 173/255,
                                                                     blue: 107/255,
                                                                     alpha: 1)
        
        
        
        let burgerHeaderView = BurgerHeaderView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        
        self.tableView.tableHeaderView  = burgerHeaderView
        
        burgerHeaderView.burgerImage.image =   getAssetThumbnail(asset: photo)
        
        tableView.estimatedRowHeight = 405.0
        tableView.rowHeight = UITableViewAutomaticDimension
                
        guard let fusionBadge = Badge.init(ratingTitle: "",
                                           badgeTitle: "fusion",
                                           badgeIcon: UIImage(named: "fusion")!
            )else {
                
                fatalError("Unable to instantiate fusion badge")
        }
        
        self.badges += [fusionBadge]

        guard let veggieBadge = Badge.init(ratingTitle: "",
                                           badgeTitle: "veggie",
                                           badgeIcon: UIImage(named: "veggie")!
            )else {
                
                fatalError("Unable to instantiate veggie badge")
        }
        
        self.badges += [veggieBadge]

        guard let spicyBadge = Badge.init(ratingTitle: "",
                                          badgeTitle: "spicy",
                                          badgeIcon: UIImage(named: "spicy")!
            )else {
                
                fatalError("Unable to instantiate spicy badge")
        }
        
        self.badges += [spicyBadge]

        guard let extinctBadge = Badge.init(ratingTitle: "",
                                            badgeTitle: "extinct",
                                            badgeIcon: UIImage(named: "available")!
            )else {
                
                fatalError("Unable to instantiate extinct badge")
        }
        
        self.badges += [extinctBadge]

        guard let seasonalBadge = Badge.init(ratingTitle: "",
                                             badgeTitle: "seasonal",
                                             badgeIcon: UIImage(named: "seasonal")!
            )else {
                
                fatalError("Unable to instantiate seasonal badge")
        }
        
        self.badges += [seasonalBadge]

        guard let hasChallengeBadge = Badge.init(ratingTitle: "",
                                                 badgeTitle: "challenge",
                                                 badgeIcon: UIImage(named: "hasChallenge")!
            )else {
                
                fatalError("Unable to instantiate hasChallenge badge")
        }
        
        self.badges += [hasChallengeBadge]
 
        guard let hasModsBadge = Badge.init(ratingTitle: "",
                                            badgeTitle: "mods",
                                            badgeIcon: UIImage(named: "hasMods")!
            )else {
                
                fatalError("Unable to instantiate hasChallege badge")
        }
        
        self.badges += [hasModsBadge]
        
        //let cellNib = UINib(nibName: "TagCell", bundle: nil)
        //self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! TagCell?
        
        //self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        
        
        for name in TAGS {
            
            let tag = Tag()
            
            tag.name = name
            
            self.tags.append(tag)
            
        }

    }

    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: self.view.bounds.width, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        
        
        return thumbnail
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? UploadTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "UploadInfoCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UploadTableViewCell  else{
            fatalError("The dequeued cell is not an instance of UploadTableViewCell.")
        }
        
        cell.burgerNameTextField.delegate = self
        cell.kitchenNameTextField.delegate = self
        cell.regionNameTextField.delegate = self
        cell.priceTextField.delegate = self
        cell.burgerDescriptionTextView.delegate = self
        
        cell.burgerNameTextField.resignFirstResponder()
        cell.kitchenNameTextField.resignFirstResponder()
        cell.regionNameTextField.resignFirstResponder()
        cell.priceTextField.resignFirstResponder()
        cell.burgerDescriptionTextView.resignFirstResponder()
        
        flowLayout = cell.flowLayout
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        ingredientCollectionView = cell.ingredientCollectionView
        heightConstraint = cell.heightConstraint
        
        
        let cellNib = UINib(nibName: "TagCell", bundle: nil)
        
        ingredientCollectionView.register(cellNib, forCellWithReuseIdentifier: "TagCell")
        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! TagCell?
        
        cell.ratingSlider.minimumValue = 0.0
        cell.ratingSlider.maximumValue = 10.0
        cell.ratingSlider.value = 5.0
        cell.ratingSlider.addTarget(self, action: #selector(updateRatingLabel(sender:)), for: .allEvents)
        
        cell.burgerDescriptionTextView.delegate = self
        cell.burgerDescriptionTextView.textColor = .lightGray
        
        cell.burgerDescriptionTextView.text = "Type your thoughts here..."
        
        fields["name"] = cell.burgerNameTextField
        fields["kitchen"] = cell.kitchenNameTextField
        fields["region"] = cell.regionNameTextField
        fields["descript"] = cell.burgerDescriptionTextView
        fields["rating"] = cell.ratingNumberLabel
        
        return cell
        
    }
    
    @objc func updateRatingLabel(sender: UISlider!) {
        let value = sender.value
        
        DispatchQueue.main.async {
            
            let ratingLabel = self.fields["rating"] as! UILabel
            
            ratingLabel.text = String(format:"%.1f", value)

        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray && textView.isFirstResponder {
            
            textView.text = nil
            textView.textColor = .gray
            
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty || textView.text == "" {
            textView.textColor = .lightGray
            textView.text = "Type your thoughts here..."
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        return true;
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        //This will do for now.
        /*
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
        */
        /*
        let contentSize = textView.sizeThatFits(textView.bounds.size)
        var frame = textView.frame
        frame.size.height = contentSize.height
        textView.frame = frame
        */
        
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        if indexPath.section == 1 {
            
            return 80
            
        }else{
            
            return tableView.rowHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {
            
            return 0.0
            
        }else{
            
            return 80.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let  cell = tableView.dequeueReusableCell(withIdentifier: "UploadHeaderCell") as! UploadHeaderTableViewCell
            
            cell.burgerName.text = "Name will go here"
            cell.kitchenName.text = "Kitchen will go here"
        
            return cell
            
        }else{
            
            return nil
            
        }
        
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let _ = scrollView as? UITableView {
            
            var offset = scrollView.contentOffset.y / 40
            
            if offset > 1 {
                
                offset = 1
                
                let colour = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: offset)
                
      
                self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255,
                                                                             green: 173/255,
                                                                             blue: 107/255,
                                                                             alpha: 1)
                self.navigationController?.navigationBar.backgroundColor = colour
 
                //UIApplication.shared.statusBarView?.backgroundColor = colour
                
            }else{
                
                let colour = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: offset)
                
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationController?.navigationBar.backgroundColor = colour
                //UIApplication.shared.statusBarView?.backgroundColor = colour
                
            }
            
            let headerView = self.tableView.tableHeaderView as! BurgerHeaderView
            
            headerView.scrollViewDidScroll(scrollView: scrollView)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                   at: UITableViewScrollPosition.top,
                                   animated: false)
        
        
        let colour = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255,
                                                                     green: 173/255,
                                                                     blue: 107/255,
                                                                     alpha: 1)
        self.navigationController?.navigationBar.backgroundColor = colour
        //UIApplication.shared.statusBarView?.backgroundColor = colour
    
    }
    
}

extension UploadBurgerInformationVC: UICollectionViewDelegate,
                                  UICollectionViewDataSource,
                                  UICollectionViewDelegateFlowLayout {
    
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
         if collectionView == self.ingredientCollectionView {
        
             return tags.count
            
         }else{
            
             return badges.count
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
         if collectionView == self.ingredientCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath as IndexPath) as! TagCell
            
            self.configureCell(cell: cell, forIndexPath: indexPath as NSIndexPath)
        
            return cell
            
         }else{
            
            let burgerBadge = badges[indexPath.row]
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCell", for: indexPath) as? BurgerBadgeCollectionViewCell  else{
                
                fatalError("The dequeued cell is not an instance of BurgerTableViewCell.")
            }
            
            cell.ratingLabel.text = burgerBadge.ratingTitle
            cell.badgeTitle.text = burgerBadge.badgeTitle
            cell.badgeImage.image = burgerBadge.badgeIcon
            cell.selectionStatus.backgroundColor = .clear
            cell.selectionStatus.layer.cornerRadius = cell.selectionStatus.frame.size.width / 2
            cell.selectionStatus.clipsToBounds = true
            
            if(firstLayout){
        
                firstLayout = false
                
                let height = self.ingredientCollectionView.collectionViewLayout.collectionViewContentSize.height
                heightConstraint.constant = height
                self.view.layoutIfNeeded()
                self.tableView.reloadData()
                
                
            }
            
            return cell
            
        }
        
    }
   
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width:view.frame.width , height:64)
    }
    
 
    internal func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        if collectionView == self.ingredientCollectionView {
        
            self.configureCell(cell: self.sizingCell!, forIndexPath: indexPath as NSIndexPath)
            
            return self.sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            
        }else{
            
            let cellSize = CGSize(width: 65, height: 85);
            
            return cellSize
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        
        self.tableView.reloadData()
        
        if collectionView == self.ingredientCollectionView {
            
            tags[indexPath.row].selected = !tags[indexPath.row].selected
            
            self.ingredientCollectionView.reloadData()
            
            let height = self.ingredientCollectionView.collectionViewLayout.collectionViewContentSize.height
            heightConstraint.constant = height
            self.view.layoutIfNeeded()
            
        }else{
            
            selectedBadgesIndex = indexPath.row
            
            let colour = UIColor(red: 222/255,
                                 green: 173/255,
                                 blue: 107/255,
                                 alpha: 1.0)
            
            if let cell = collectionView.cellForItem(at: indexPath)  as? BurgerBadgeCollectionViewCell {
                
                if  cell.selectionStatus.backgroundColor != colour{
                    
                    cell.selectionStatus.backgroundColor = colour
                    
                }else{
                    
                    cell.selectionStatus.backgroundColor = UIColor.clear
                    
                }
                
            }else{
                
                
            }
        }
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        
        let tag = tags[indexPath.row]
        
        cell.tagName.text = tag.name
        
        cell.tagName.textColor = tag.selected ? UIColor.white : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        
        cell.backgroundColor = tag.selected ? UIColor(red: 0, green: 1, blue: 0, alpha: 1) : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
    }
}
