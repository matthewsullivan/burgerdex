//
//  CatalogueVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-02.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class CatalogueVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var errorButton: UIButton!
    private let kLazyLoadCollectionCellImage = 1
    @IBOutlet weak var errorContainerView: UIView!
    @IBOutlet weak var errorHeaderLabel: UILabel!
    @IBOutlet weak var errorBodyLabel: UILabel!
    @IBOutlet weak var errorImageContainer: UIImageView!
    @IBAction func errorButtonLabel(_ sender: Any) {
        
        self.requestCatalogueBurgerData(page:1, filter:self.selectedFilterIndex)
        
    }
    
    
    @IBAction func searchBurgerBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "searchBurgersSegue", sender: self)
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedBurger: BurgerPreview!
    var burgerThumbnail: UIImage!
    
    var burgers = [BurgerPreview]()
    var filters = [String]()
    var selectedFilterIndex = Int()
    var images: [String] = []
    
    var pageIndex = 1
    var noMoreData = false

    var sbshown: Bool = false
    var statusBarCorrect: CGFloat = 20.0
    
    //Main URL Session for previews.
    let sharedSession = URLSession.shared
    
    struct BurgerSort {
        
        var sectionName : String!
        var sectionObjects : [BurgerPreview]!
    }
    
    var burgerSortedArray = [BurgerSort]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Catalogue"

        layoutCatalogueTableView()
        checkForStatusBars()
        
        hideErrorView()
        
    }
    
    func hideErrorView(){
        
         errorContainerView.isHidden = true
        
    }
    
    func displayErrorView(errorType: Int){
        
        self.errorContainerView.isHidden = false
        //Error Type 0 = Filter match
        //Error Type 1 = Network Connection
    
        if errorType == 0 {
            
            self.errorImageContainer.image = UIImage(named: "noFood")
            self.errorHeaderLabel.text = "SORRY"
            self.errorBodyLabel.text = "No Burger Matches.."
            self.errorButton.isHidden = true
        }
    
        if errorType == 1 {
            
            self.errorImageContainer.image = UIImage(named: "noFood")
            self.errorHeaderLabel.text = "Network Error"
            self.errorBodyLabel.text = "It seems that the network connection has been lost."
            self.errorButton.isHidden = false
        }
    
    }
    
    func checkForStatusBars(){
        
        if UIDevice.current.modelName != "iPhone10,3" || UIDevice.current.modelName != "iPhone10,6" {
            
            //Status bar shown for location services or incoming call
            if (UIApplication.shared.statusBarFrame.height == 40) {
                
                statusBarCorrect = UIApplication.shared.statusBarFrame.height - 20
                
                sbshown = true
                
            }else{
                
                sbshown = false
                
                statusBarCorrect = UIApplication.shared.statusBarFrame.height
            }
        
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil, queue: nil, using: statusbarChange)
        }
        
    }
    
    func statusbarChange(notif: Notification) -> Void {
        

        if (sbshown) {
            
            
            sbshown = false
            statusBarCorrect = UIApplication.shared.statusBarFrame.height
            
        }else{
            

            sbshown = true
            statusBarCorrect = UIApplication.shared.statusBarFrame.height - 20
        }
        
        
    }
    
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
        
        self.collectionView.selectItem(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition:UICollectionViewScrollPosition.left)
        
        self.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: 1, section: 0))
        //requestCatalogueBurgerData(page:1, filter:1)
        
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
            
            if (data[0] as! Int) == 1{
                
                if (data[1] as AnyObject).count > 0 {
                                        
                    self.hideErrorView()
                    
                    self.burgers.removeAll()
                    self.pageIndex = 1
                    
                    self.burgers = data[1] as! [BurgerPreview]
                    
                    self.burgerSortedArray.removeAll()
                    
                    if self.selectedFilterIndex == 14{
                        
                        let predicate = { (element: BurgerPreview) in
                            return element.kitchen
                        }
                        
                        let dictionary = Dictionary(grouping: self.burgers, by: predicate)
                        
                        let sortedByKeyDictionary = dictionary.sorted { $0.0 < $1.0 }
                        
                        for (key, value) in sortedByKeyDictionary {
                            
                            
                            self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
                        }
                        
                    }
                    
                    if self.selectedFilterIndex == 13{
                        
                        let predicate = { (element: BurgerPreview) in
                            return element.location
                        }
                        
                        let dictionary = Dictionary(grouping: self.burgers, by: predicate)
                        
                        let sortedByKeyDictionary = dictionary.sorted { $0.0 < $1.0 }
                        
                        for (key, value) in sortedByKeyDictionary {
                          
                            self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
                        }
                        
                    }
                    
                    if self.selectedFilterIndex == 2{
                        
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
                    
                }else{
                    
                    //0 for no matches. 1 for network problems.
                    self.displayErrorView(errorType: 0)
                    
                    self.burgers.removeAll()
                    
                    TableLoader.removeLoaderFrom(self.tableView)
                    
                    self.tableView.reloadData()
                    
                    self.tableView.allowsSelection = true
                    self.tableView.isScrollEnabled = true
                    
                    //Set the collection filter back to previous value if web call fails
                    print("No Burgers")
                    
                }
                
            }else{
                
                //0 for no matches. 1 for network problems.
                self.displayErrorView(errorType: 1)
                
                self.burgers.removeAll()
                
                TableLoader.removeLoaderFrom(self.tableView)
                
                self.tableView.reloadData()
                
                self.tableView.allowsSelection = true
                self.tableView.isScrollEnabled = true
                
                //Set the collection filter back to previous value if web call fails
                print("handle web error here")
                
            }
            
        })
  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if selectedFilterIndex == 14 || selectedFilterIndex == 13 || selectedFilterIndex == 2{
            
            return burgerSortedArray.count
            
        }else{
            
             return 1
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedFilterIndex == 14 || selectedFilterIndex == 13 || selectedFilterIndex == 2{
            
            return burgerSortedArray[section].sectionObjects.count
            
        }else{
            
            return burgers.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.pageIndex > 1 {TableLoader.removeLoaderFrom(self.tableView)}
        
        let cellIdentifier = "CatalogueTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CatalogueTableViewCell
        
        var burger : BurgerPreview
        
        if selectedFilterIndex == 14 || selectedFilterIndex == 13 || selectedFilterIndex == 2{
            
            burger = burgerSortedArray[indexPath.section].sectionObjects[indexPath.row]
            
        }else{
            
            burger = burgers[indexPath.row]
        }
        
        cell.selectionStyle = .none
        
        cell.burgerName.text = burger.name
        cell.kitchenName.text = burger.kitchen
        cell.catalogueNumberLabel.text = burger.displayTag
        cell.catalogueNumberNumber.text = burger.displayText
        cell.burgerID = burger.burgerID
        
        if burger.catalogueNumber != 0{
            
            updateImageForCell(cell,
                               inTableView: tableView,
                               withImageURL: burger.thumbUrl,
                               andImageView: cell.burgerImage!,
                               atIndexPath: indexPath)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if selectedFilterIndex == 14 || selectedFilterIndex == 13 || selectedFilterIndex == 2{
            
            return burgerSortedArray[section].sectionName
            
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastElement = burgers.count - 1
        
        if (indexPath.row == lastElement && !noMoreData && self.pageIndex > 1){
            
            BurgerPreview.fetchBurgerPreviews(page: self.pageIndex, filter: self.selectedFilterIndex, session: sharedSession ,completion: { (data) in
                
                print("Secondary Call")
                
                if (data[1] as AnyObject).count > 0 {
                    
                    print(data[1])
                    
                    self.burgers += data[1] as! [BurgerPreview]
                    
                    self.pageIndex  += 1
                    
                    self.tableView.reloadData()
                    
                }else{
                    
                    self.noMoreData = true
                    
                    //Set the collection filter back to previous value if web call fails
                    print("Pagination Error or no more data")
                    
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
        
        if selectedFilterIndex == 14 || selectedFilterIndex == 13 || selectedFilterIndex == 2{
            
            burger = burgerSortedArray[indexPath.section].sectionObjects[indexPath.row]
            
        }else{
            
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
    
    //Revisit this method This seems to be causing many issues.
    func loadImagesForOnscreenRows() {
        /*
        if burgers.count > 0 {
            
            let visiblePaths = tableView.indexPathsForVisibleRows ?? [IndexPath]()
            
            for indexPath in visiblePaths {
                
                let burger = burgers[indexPath.row]
                
                let cell = tableView(self.tableView, cellForRowAt: indexPath) as! CatalogueTableViewCell
                
                updateImageForCell(cell, inTableView: tableView,
                                   withImageURL: burger.thumbUrl,
                                   andImageView: cell.burgerImage!,
                                   atIndexPath: indexPath)
            }
        }
 */
    }
    
    // MARK: - When decelerated or ended dragging, we must update visible rows
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
        if let _ = scrollView as? UITableView {
                    
            loadImagesForOnscreenRows()
            
        }
        
        //if scrolled to bottom on section filter make call for more data
        //print(self.tableView.scrolledToBottom)
        
        /*
            Massive hack to allow the table view with sections to have pagination calls done correctly.
         
            First we check to make sure we have a filter that contains section headers.
            Then we check to see if the tableview scroll view has reached the bottom.
            Call until self.noMoreData is true. Ignore the rest
         
            WE DO THIS BECAUSE WE CANNOT COMPARE THE LAST INDEXPATH[ROW] TO THE LAST BURGER ARRAY INDEX COUNT -1.
         
            We are in a section here so the last index row is always changing and will always be less than the overall burger array count.
        */
        
        if selectedFilterIndex == 14 || selectedFilterIndex == 13 || selectedFilterIndex == 2{
            
            if self.tableView.scrolledToBottom == true{
            
                if(self.noMoreData != true){
        
                    BurgerPreview.fetchBurgerPreviews(page: self.pageIndex, filter: self.selectedFilterIndex, session: sharedSession ,completion: { (data) in
                    
                        if (data[1] as AnyObject).count > 0 {
                            
                            self.burgers += data[1] as! [BurgerPreview]
                            
                            self.pageIndex  += 1
                            
                            self.burgerSortedArray.removeAll()
                            
                            if self.selectedFilterIndex == 14{
                                
                                let predicate = { (element: BurgerPreview) in
                                    return element.kitchen
                                }
                                
                                let dictionary = Dictionary(grouping: self.burgers, by: predicate)
                                
                                let sortedByKeyDictionary = dictionary.sorted { $0.0 < $1.0 }
                                
                                for (key, value) in sortedByKeyDictionary {
                                
                                    self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
                                }
                                
                            }
                            
                            if self.selectedFilterIndex == 13{
                                
                                let predicate = { (element: BurgerPreview) in
                                    return element.location
                                }
                                
                                let dictionary = Dictionary(grouping: self.burgers, by: predicate)
                                
                                let sortedByKeyDictionary = dictionary.sorted { $0.0 < $1.0 }
                                
                                for (key, value) in sortedByKeyDictionary {
                                    
                                    
                                    self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
                                }
                                
                            }
                            
                            if self.selectedFilterIndex == 2{
                                
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
                        
                        }else{
                            
                            self.noMoreData = true
                            
                            //Set the collection filter back to previous value if web call fails
                            print("Pagination Error or no more data")
                            
                        }
                        
                    })
                }
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
          if let _ = scrollView as? UITableView {
            
            if !decelerate { loadImagesForOnscreenRows() }
            
          }
        
    }
    
    var lastContentOffset: CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let _ = scrollView as? UITableView {
           
            //Complete hack for now. Get back to this later
            self.collectionView.frame = CGRect(x:self.collectionView.frame.origin.x,
                                               y: (self.navigationController?.navigationBar.frame.size.height)! + statusBarCorrect,
                                               width:self.collectionView.frame.width,
                                               height:self.collectionView.frame.height
            )
            
            self.lastContentOffset = scrollView.contentOffset.y
        }
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        if let _ = scrollView as? UITableView {
            
            //Complete hack for now. Get back to this later
            self.collectionView.frame = CGRect(x:self.collectionView.frame.origin.x,
                                               y: (self.navigationController?.navigationBar.frame.size.height)! + statusBarCorrect,
                                               width:self.collectionView.frame.width,
                                               height:self.collectionView.frame.height
            )
            
            self.lastContentOffset = scrollView.contentOffset.y
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var burger : BurgerPreview
        
        if selectedFilterIndex == 14 || selectedFilterIndex == 13 || selectedFilterIndex == 2{
            
            burger = burgerSortedArray[indexPath.section].sectionObjects[indexPath.row]
            
        }else{
            
            burger = burgers[indexPath.row]
        }
    
        burgerThumbnail = burger.photo
        selectedBurger = burger
        
        if(burger.sightings > 1){
          
            self.performSegue(withIdentifier: "multipleSightingSegue", sender: self)
            
        }else{
            
             self.performSegue(withIdentifier: "burgerSegue", sender: self)
        }
        
       
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        return 80.0
        
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
         if (segue.identifier == "burgerSegue") {
    
            let burgerViewController = segue.destination as! BurgerVC
            
            if burgerThumbnail.size.width == 0.0 {
                
                burgerViewController.burgerThumbnail = UIImage(named:"baconBeast")
                
            }else{
                
                burgerViewController.burgerThumbnail = burgerThumbnail
            }
            
            burgerViewController.burger = selectedBurger
            
            
         }else if(segue.identifier == "multipleSightingSegue"){
            
            let burgerViewController = segue.destination as! BurgerDashboardVC
            
            if burgerThumbnail.size.width == 0.0 {
                
                burgerViewController.burgerThumbnail = UIImage(named:"baconBeast")
                
            }else{
                
                burgerViewController.burgerThumbnail = burgerThumbnail
            }
            
            burgerViewController.burger = selectedBurger
            
         }else{
                        
            let navVC = segue.destination as? UINavigationController
            
            let burgerViewController = navVC?.viewControllers.first as! SearchBurgerVC
            
            burgerViewController.burgers = burgers
            
        }
    
    }

}

extension CatalogueVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let filterNames = filters[indexPath.row]
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCatalogueCell", for: indexPath) as? FilterCatalogueCollectionViewCell  else{
            
            fatalError("The dequeued cell is not an instance of FilterCatalogueCell.")
        }

        cell.filterName.text = filterNames
        
        if selectedFilterIndex == indexPath.row {
           
            cell.backgroundColor = UIColor(red: 222/255,
                                           green: 173/255,
                                           blue: 107/255,
                                           alpha: 1)
            
            cell.filterName.textColor = UIColor.white
            
        }else{
            
            cell.backgroundColor = UIColor.clear
            cell.filterName.textColor = UIColor.gray
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let size: CGSize = filters[indexPath.row].size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)])
        return CGSize(width: size.width + 25.0, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        
        selectedFilterIndex = indexPath.row
        
        ImageManager.sharedInstance.clearCache();
        
        collectionView.scrollToItem(at: IndexPath(row: selectedFilterIndex, section: 0), at: .left, animated: true) //.centeredHorizontally
        
        if self.burgers.count == 0{
            
            self.burgers = BurgerPreview.generatePlaceholderBurgers() as! [BurgerPreview]
        
            self.tableView.reloadData()
        }
        
        if selectedFilterIndex == 14 || selectedFilterIndex == 13 || selectedFilterIndex == 2{
            
            self.burgerSortedArray.removeAll()
            
            let dictionary = ["": self.burgers]
            
            let sortedByKeyDictionary = dictionary.sorted { $0.0 < $1.0 }
        
            for (key, value) in sortedByKeyDictionary {
                
                print(value[0].kitchen)
                
                self.burgerSortedArray.append(BurgerSort(sectionName: key, sectionObjects: value))
            }
        
            self.tableView.reloadData()
        
        }
        
        collectionView.reloadData()
    
        self.hideErrorView()
        
        if selectedFilterIndex == 14 || selectedFilterIndex == 13 || selectedFilterIndex == 2{
            
            
            if  self.burgerSortedArray.count > 0 {
            
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                           at: UITableViewScrollPosition.top,
                                           animated: false)
                
            }
            
        }else{
            
            if self.burgers.count > 0 {
                
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                           at: UITableViewScrollPosition.top,
                                           animated: false)
                
            }
            
        }
        
        self.requestCatalogueBurgerData(page:1, filter:self.selectedFilterIndex)
    
    }
}

extension UIScrollView {
    
    var scrolledToTop: Bool {
        let topEdge = 0 - contentInset.top
        return contentOffset.y <= topEdge
    }
    
    var scrolledToBottom: Bool {
        let bottomEdge = contentSize.height + contentInset.bottom - bounds.height
        return contentOffset.y >= bottomEdge
    }
    
}
