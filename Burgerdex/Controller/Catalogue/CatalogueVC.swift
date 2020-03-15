//
//  CatalogueVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-02.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//
import UIKit

class CatalogueVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let kLazyLoadCollectionCellImage = 1

    let sharedSession = URLSession.shared
    
    var burgers = [BurgerPreview]()
    var burgerSortedArray = [BurgerSort]()
    var burgerThumbnail: UIImage!
    var filters = [String]()
    var lastContentOffset: CGFloat = 0
    var noMoreData = false
    var pageIndex = 1
    var sbshown: Bool = false
    var selectedBurger: BurgerPreview!
    var selectedFilterIndex = Int()
    var statusBarCorrect: CGFloat = 20.0
    
    struct BurgerSort {
        var sectionName : String!
        var sectionObjects : [BurgerPreview]!
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var errorContainerView: UIView!
    @IBOutlet weak var errorHeaderLabel: UILabel!
    @IBOutlet weak var errorBodyLabel: UILabel!
    @IBOutlet weak var errorImageContainer: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func errorButtonLabel(_ sender: Any) {
        self.requestCatalogueBurgerData(page:1, filter:self.selectedFilterIndex)
    }

    @IBAction func searchBurgerBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "searchBurgersSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "burgerSegue") {
            let burgerViewController = segue.destination as! BurgerVC
            
            burgerViewController.burgerThumbnail = burgerThumbnail.size.width == 0.0 ? UIImage(named:"baconBeast") : burgerThumbnail;
            burgerViewController.burger = selectedBurger
        } else if (segue.identifier == "multipleSightingSegue") {
            let burgerViewController = segue.destination as! BurgerDashboardVC
            
            burgerViewController.burgerThumbnail = burgerThumbnail.size.width == 0.0 ? UIImage(named:"baconBeast") : burgerThumbnail;
            burgerViewController.burger = selectedBurger
        } else {
            let navVC = segue.destination as? UINavigationController
            let burgerViewController = navVC?.viewControllers.first as! SearchBurgerVC
            
            burgerViewController.burgers = burgers
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Catalogue"
        
        layoutCatalogueTableView()
        checkForStatusBars()
        
        hideErrorView()
    }
    
    func checkForStatusBars() {
        if UIDevice.current.modelName != "iPhone10,3" || UIDevice.current.modelName != "iPhone10,6" {
            if (UIApplication.shared.statusBarFrame.height == 40) {
                statusBarCorrect = UIApplication.shared.statusBarFrame.height - 20
                sbshown = true
            } else {
                sbshown = false
                statusBarCorrect = UIApplication.shared.statusBarFrame.height
            }
            
            NotificationCenter.default.addObserver(forName: UIApplication.didChangeStatusBarFrameNotification, object: nil, queue: nil, using: statusbarChange)
        }
    }
    
    func displayErrorView(errorType: Int) {
        self.errorContainerView.isHidden = false
        
        if (errorType == 0) {
            self.errorImageContainer.image = UIImage(named: "noFood")
            self.errorHeaderLabel.text = "SORRY"
            self.errorBodyLabel.text = "No Burger Matches.."
            self.errorButton.isHidden = true
        }
        
        if (errorType == 1) {
            self.errorImageContainer.image = UIImage(named: "noFood")
            self.errorHeaderLabel.text = "Network Error"
            self.errorBodyLabel.text = "It seems that the network connection has been lost."
            self.errorButton.isHidden = false
        }
    }
    
    func hideErrorView() {errorContainerView.isHidden = true}
    
    func layoutCatalogueTableView(){
        filters += ["Featured",
                    "No",
                    "Discovered",
                    "Rating",
                    "Vegetarian",
                    "Spicy",
                    "Limited Time",
                    "Extinct",
                    "Challenge",
                    "Price-Hi",
                    "Price-Low",
                    "Fusion",
                    "Modded",
                    "Location",
                    "Kitchen"]
        
        self.collectionView.reloadData()
        
        self.burgers = BurgerPreview.generatePlaceholderBurgers() as! [BurgerPreview]
        
        self.collectionView.selectItem(at: IndexPath(row: 1, section: 0),
                                       animated: false,
                                       scrollPosition:UICollectionView.ScrollPosition.left)
        
        self.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: 1, section: 0))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (
            selectedFilterIndex == 14 ||
            selectedFilterIndex == 13 ||
            selectedFilterIndex == 2
        ) {
            return burgerSortedArray.count
        }
        
        return 1
    }
    
    func requestCatalogueBurgerData(page:Int, filter:Int){
        self.tableView.allowsSelection = false
        self.tableView.isScrollEnabled = false
        
        self.pageIndex = 1
        
        self.tableView.reloadData()
        
        TableLoader.removeLoaderFrom(self.tableView)
        TableLoader.addLoaderTo(self.tableView)
        
        noMoreData = false
        
        BurgerPreview.fetchBurgerPreviews(page: page, filter: filter, session: sharedSession ,completion: { (data) in
            if (data[0] as! Int) == 1 {
                if (data[1] as AnyObject).count > 0 {
                    self.hideErrorView()
                    
                    self.burgers.removeAll()
                    self.pageIndex = 1
                    
                    self.burgers = data[1] as! [BurgerPreview]
                    
                    self.burgerSortedArray.removeAll()
                    
                    if (self.selectedFilterIndex == 14) {
                        let predicate = { (element: BurgerPreview) in
                            return element.kitchen
                        }
                        
                        let dictionary = Dictionary(grouping: self.burgers, by: predicate)
                        
                        let sortedByKeyDictionary = dictionary.sorted { $0.0 < $1.0 }
                        
                        for (key, value) in sortedByKeyDictionary {
                            self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
                        }
                    }
                    
                    if (self.selectedFilterIndex == 13) {
                        let predicate = { (element: BurgerPreview) in
                            return element.location
                        }
                        
                        let dictionary = Dictionary(grouping: self.burgers, by: predicate)
                        
                        let sortedByKeyDictionary = dictionary.sorted { $0.0 < $1.0 }
                        
                        for (key, value) in sortedByKeyDictionary {
                            self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
                        }
                    }
                    
                    if (self.selectedFilterIndex == 2) {
                        let predicate = { (element: BurgerPreview) in
                            return element.year
                        }
                        
                        let dictionary = Dictionary(grouping: self.burgers, by: predicate)
                        let sortedByKeyDictionary = dictionary.sorted { $0.0 < $1.0 }
                        
                        for (key, value) in sortedByKeyDictionary {
                            self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                    TableLoader.removeLoaderFrom(self.tableView)
                    
                    self.tableView.allowsSelection = true
                    self.tableView.isScrollEnabled = true
                    
                    self.pageIndex  += 1
                } else {
                    self.displayErrorView(errorType: 0)
                    
                    self.burgers.removeAll()
                    
                    TableLoader.removeLoaderFrom(self.tableView)
                    
                    self.tableView.reloadData()
                    
                    self.tableView.allowsSelection = true
                    self.tableView.isScrollEnabled = true
                }
            } else {
                self.displayErrorView(errorType: 1)
                
                self.burgers.removeAll()
                
                TableLoader.removeLoaderFrom(self.tableView)
                
                self.tableView.reloadData()
                
                self.tableView.allowsSelection = true
                self.tableView.isScrollEnabled = true
            }
        })
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (
            selectedFilterIndex == 14 ||
            selectedFilterIndex == 13 ||
            selectedFilterIndex == 2
        ) {
            if self.tableView.scrolledToBottom == true {
                if(self.noMoreData != true) {
                    BurgerPreview.fetchBurgerPreviews(page: self.pageIndex,
                                                      filter: self.selectedFilterIndex,
                                                      session: sharedSession,
                                                      completion: {(data) in
                        if (data[1] as AnyObject).count > 0 {
                            self.burgers += data[1] as! [BurgerPreview]
                            self.pageIndex  += 1
                            
                            self.burgerSortedArray.removeAll()
                            
                            if (self.selectedFilterIndex == 14) {
                                let predicate = { (element: BurgerPreview) in
                                    return element.kitchen
                                }
                                
                                let dictionary = Dictionary(grouping: self.burgers, by: predicate)
                                let sortedByKeyDictionary = dictionary.sorted { $0.0 < $1.0 }
                                
                                for (key, value) in sortedByKeyDictionary {
                                    self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
                                }
                            }
                            
                            if (self.selectedFilterIndex == 13) {
                                let predicate = { (element: BurgerPreview) in
                                    return element.location
                                }
                                
                                let dictionary = Dictionary(grouping: self.burgers, by: predicate)
                                let sortedByKeyDictionary = dictionary.sorted { $0.0 < $1.0 }
                                
                                for (key, value) in sortedByKeyDictionary {
                                    self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
                                }
                            }
                            
                            if (self.selectedFilterIndex == 2) {
                                let predicate = { (element: BurgerPreview) in
                                    return element.year
                                }
                                
                                let dictionary = Dictionary(grouping: self.burgers, by: predicate)
                                let sortedByKeyDictionary = dictionary.sorted { $0.0 > $1.0 }
                                
                                for (key, value) in sortedByKeyDictionary {
                                    self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
                                }
                            }
                            
                            self.tableView.reloadData()
                        } else {
                            self.noMoreData = true
                        }
                    })
                }
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let _ = scrollView as? UITableView {
            self.collectionView.frame = CGRect(x:self.collectionView.frame.origin.x,
                                               y: (self.navigationController?.navigationBar.frame.size.height)! + statusBarCorrect,
                                               width:self.collectionView.frame.width,
                                               height:self.collectionView.frame.height
            )
            
            self.lastContentOffset = scrollView.contentOffset.y
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = scrollView as? UITableView {
            self.collectionView.frame = CGRect(x:self.collectionView.frame.origin.x,
                                               y: (self.navigationController?.navigationBar.frame.size.height)! + statusBarCorrect,
                                               width:self.collectionView.frame.width,
                                               height:self.collectionView.frame.height
            )
            
            self.lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    func statusbarChange(notif: Notification) -> Void {
        if (sbshown) {
            sbshown = false
            statusBarCorrect = UIApplication.shared.statusBarFrame.height
        } else {
            sbshown = true
            statusBarCorrect = UIApplication.shared.statusBarFrame.height - 20
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var burger : BurgerPreview
        
        if (
            selectedFilterIndex == 14 ||
            selectedFilterIndex == 13 ||
            selectedFilterIndex == 2
        ) {
            burger = burgerSortedArray[indexPath.section].sectionObjects[indexPath.row]
        } else {
            burger = burgers[indexPath.row]
        }
        
        burgerThumbnail = burger.photo
        selectedBurger = burger
        
        self.performSegue(withIdentifier: burger.sightings > 1 ? "multipleSightingSegue" : "burgerSegue", sender: self)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.pageIndex > 1 {TableLoader.removeLoaderFrom(self.tableView)}

        let cellIdentifier = "CatalogueTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CatalogueTableViewCell
        
        var burger : BurgerPreview
        
        if (
            selectedFilterIndex == 14 ||
            selectedFilterIndex == 13 ||
            selectedFilterIndex == 2
        ) {
            burger = burgerSortedArray[indexPath.section].sectionObjects[indexPath.row]
        } else {
            burger = burgers[indexPath.row]
        }
        
        cell.selectionStyle = .none
        
        cell.burgerName.text = burger.name
        cell.kitchenName.text = burger.kitchen
        cell.catalogueNumberLabel.text = burger.displayTag
        cell.catalogueNumberNumber.text = burger.displayText
        cell.burgerID = burger.burgerID
        
        if (burger.catalogueNumber != 0) {
            updateImageForCell(cell,
                               inTableView: tableView,
                               withImageURL: burger.thumbUrl,
                               andImageView: cell.burgerImage!,
                               atIndexPath: indexPath)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 80.0}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (
            selectedFilterIndex == 14 ||
            selectedFilterIndex == 13 ||
            selectedFilterIndex == 2
        ) {
            return burgerSortedArray[section].sectionObjects.count
        }
            
        return burgers.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (
            selectedFilterIndex == 14 ||
            selectedFilterIndex == 13 ||
            selectedFilterIndex == 2
        ){
            return burgerSortedArray[section].sectionName
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = burgers.count - 1
        
        if (indexPath.row == lastElement && !noMoreData && self.pageIndex > 1){
            BurgerPreview.fetchBurgerPreviews(page: self.pageIndex,
                                              filter: self.selectedFilterIndex,
                                              session: sharedSession,
                                              completion: { (data) in
                                                if (data[1] as AnyObject).count > 0 {
                                                    self.burgers += data[1] as! [BurgerPreview]
                                                    self.pageIndex  += 1
                                                    
                                                    self.tableView.reloadData()
                                                } else {
                                                    self.noMoreData = true
                                                }
            })
        }
    }
    
    func updateImageForCell(_ cell: UITableViewCell,
                            inTableView tableView: UITableView,
                            withImageURL: String,
                            andImageView: UIImageView,
                            atIndexPath indexPath: IndexPath) {
        let imageView = andImageView
        imageView.image = kLazyLoadPlaceholderImage
        
        var burger : BurgerPreview
        
        if (
            selectedFilterIndex == 14 ||
            selectedFilterIndex == 13 ||
            selectedFilterIndex == 2
        ) {
            burger = burgerSortedArray[indexPath.section].sectionObjects[indexPath.row]
        } else {
            burger = burgers[indexPath.row]
        }
        
        let imageURL = burger.thumbUrl
        
        ImageManager.sharedInstance.downloadImageFromURL(imageURL) { (success, image) -> Void in
            if success && image != nil {
                if (tableView.indexPath(for: cell) as NSIndexPath?)?.row == (indexPath as NSIndexPath).row {
                    imageView.image = image
                    burger.photo = imageView.image!
                }
            }
        }
    }
}

extension CatalogueVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterNames = filters[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCatalogueCell", for: indexPath) as? FilterCatalogueCollectionViewCell
        else {
            fatalError("The dequeued cell is not an instance of FilterCatalogueCell.")
        }
        
        cell.filterName.text = filterNames
        
        if (selectedFilterIndex == indexPath.row) {
            cell.backgroundColor = UIColor(red: 222/255, green: 173/255, blue: 107/255,alpha: 1)
            cell.filterName.textColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor.clear
            cell.filterName.textColor = UIColor.gray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize = filters[indexPath.row].size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
        
        return CGSize(width: size.width + 25.0, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFilterIndex = indexPath.row
        
        ImageManager.sharedInstance.clearCache();
        
        collectionView.scrollToItem(at: IndexPath(row: selectedFilterIndex, section: 0), at: .left, animated: true)
        
        if (self.burgers.count == 0) {
            self.burgers = BurgerPreview.generatePlaceholderBurgers() as! [BurgerPreview]
            
            self.tableView.reloadData()
        }
        
        if (
            selectedFilterIndex == 14 ||
            selectedFilterIndex == 13 ||
            selectedFilterIndex == 2
        ) {
            self.burgerSortedArray.removeAll()
            
            let dictionary = ["": self.burgers]
            let sortedByKeyDictionary = dictionary.sorted { $0.0 < $1.0 }
            
            for (key, value) in sortedByKeyDictionary {
                self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
            }
            
            self.tableView.reloadData()
        }
        
        collectionView.reloadData()
        
        self.hideErrorView()
        
        if (
            selectedFilterIndex == 14 ||
            selectedFilterIndex == 13 ||
            selectedFilterIndex == 2
        ) {
            if (self.burgerSortedArray.count > 0) {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                           at: UITableView.ScrollPosition.top,
                                           animated: false)
            }
        } else {
            if (self.burgers.count > 0) {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                           at: UITableView.ScrollPosition.top,
                                           animated: false)
            }
        }
        
        self.requestCatalogueBurgerData(page:1, filter:self.selectedFilterIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {return filters.count}
}

extension UIScrollView {
    var scrolledToBottom: Bool {
        let bottomEdge = contentSize.height + contentInset.bottom - bounds.height

        return contentOffset.y >= bottomEdge
    }

    var scrolledToTop: Bool {
        let topEdge = 0 - contentInset.top

        return contentOffset.y <= topEdge
    }
}
