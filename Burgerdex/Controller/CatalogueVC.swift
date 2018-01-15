//
//  CatalogueVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-02.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class CatalogueVC: UIViewController{
    
    private let kLazyLoadCollectionCellImage = 1
    
    @IBOutlet weak var tableView: UITableView!
    var selectedBurger: BurgerPreview!
    var burgerThumbnail: UIImage!
    var burgers = [BurgerPreview]()
    var filters = [String]()
    var selectedFilterIndex = Int()
    var images: [String] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        self.title = "Catalogue"
        
        layoutCatalogueTableView()
        
    }
    
    func layoutCatalogueTableView(){
        
        filters += ["Featured",
                    "No",
                    "Discovered",
                    "Rating",
                    "Vegetarian",
                    "Spicy",
                    "Seasonal",
                    "Extinct",
                    "Challenge",
                    "Price-Hi",
                    "Price-Low",
                    "Fusion",
                    "Modded",
                    "Location",
                    "Kitchen"]
        
        self.collectionView.reloadData()
        
        requestCatalogueBurgerData(page:1, filter:2)
        
    }
    
    func requestCatalogueBurgerData(page:Int, filter:Int){
        
        self.burgers = BurgerPreview.generatePlaceholderBurgers() as! [BurgerPreview]
        self.tableView.allowsSelection = false
        
        self.tableView.reloadData()
        
        TableLoader.addLoaderTo(self.tableView)
        
        BurgerPreview.fetchBurgerPreviews(page: page, filter: filter,completion: { (data) in
            
            self.burgers.removeAll()
            
            self.burgers = data as! [BurgerPreview]
            
            TableLoader.removeLoaderFrom(self.tableView)
            
            self.tableView.reloadData()
        
            self.tableView.allowsSelection = true
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        let burgerViewController = segue.destination as! BurgerVC
        
        if burgerThumbnail != nil {
            
            burgerViewController.burgerThumbnail = burgerThumbnail
            
        }else{
            
            burgerViewController.burgerThumbnail = UIImage(named:"baconBeast")
        }
        
        burgerViewController.burger = selectedBurger
    }


}

extension CatalogueVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        guard let tableViewCell = view as? FilterCatalogueCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: section)
        
        //print("GOT HERE")
        
        //tableViewCell.collectionView.delegate?.collectionView!(tableViewCell.collectionView, didSelectItemAt: [0,1])
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return burgers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("reload")
        
        let cellIdentifier = "CatalogueTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CatalogueTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CatalogueTableViewCell.")
        }
        
        let burger = burgers[indexPath.row]
        
        cell.burgerName.text = burger.name
        cell.kitchenName.text = burger.kitchen
        cell.catalogueNumberLabel.text = "No."
        cell.catalogueNumberNumber.text = String(burger.catalogueNumber)
        cell.burgerID = burger.burgerID
        
        if burger.catalogueNumber != 0{
            
            updateImageForCell(cell,
                               inTableView: tableView,
                               withImageURL: burger.photoUrl,
                               andImageView: cell.burgerImage!,
                               atIndexPath: indexPath)
            
        }
        
        return cell
    }
    
    func updateImageForCell(_ cell: UITableViewCell,
                            inTableView tableView: UITableView,
                            withImageURL: String,
                            andImageView: UIImageView,
                            atIndexPath indexPath: IndexPath) {
        
        let imageView = andImageView
        
        imageView.image = kLazyLoadPlaceholderImage
        
        let burger = burgers[indexPath.row]
        
        let imageURL = burger.photoUrl
        
        ImageManager.sharedInstance.downloadImageFromURL(imageURL) { (success, image) -> Void in
            
            if success && image != nil {
                
                if (tableView.indexPath(for: cell) as NSIndexPath?)?.row == (indexPath as NSIndexPath).row {
                    
                    imageView.image = image
                    //Convert photo back to UIImage and use this instead
                    burger.photo = imageView.image!
                    
                }
            }
        }
    }
    
    func loadImagesForOnscreenRows() {
        
        if burgers.count > 0 {
            
            let visiblePaths = tableView.indexPathsForVisibleRows ?? [IndexPath]()
            
            for indexPath in visiblePaths {
                
                let burger = burgers[indexPath.row]
                
                let cell = tableView(self.tableView, cellForRowAt: indexPath) as! CatalogueTableViewCell
                
                updateImageForCell(cell, inTableView: tableView,
                                   withImageURL: burger.photoUrl,
                                   andImageView: cell.burgerImage!,
                                   atIndexPath: indexPath)
            }
        }
    }
    
    // MARK: - When decelerated or ended dragging, we must update visible rows
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if let _ = scrollView as? UITableView {
            
            loadImagesForOnscreenRows()
            
        }
    }
    /*
     override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
     if !decelerate { loadImagesForOnscreenRows() }
     }
     */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let burger = burgers[indexPath.row]
        
        burgerThumbnail = burger.photo
        selectedBurger = burger
        
        self.performSegue(withIdentifier: "burgerSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        return 80.0
        
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
            
            cell.backgroundColor = UIColor(red: 249/255, green: 208/255, blue: 93/255, alpha: 1)
            
        }else{
            
            cell.backgroundColor = UIColor.clear
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
        
        collectionView.scrollToItem(at: IndexPath(row: selectedFilterIndex, section: 0), at: .centeredHorizontally, animated: true)
        
        collectionView.reloadData()
        
        requestCatalogueBurgerData(page:1, filter:selectedFilterIndex)
        
    }
}



