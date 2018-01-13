//
//  CatalogueVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-02.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class CatalogueVC: UITableViewController {
    
    var selectedBurger: BurgerPreview!
    var burgerThumbnail: Data!
    var burgers = [BurgerPreview]()
    var filters = [String]()
    var selectedFilterIndex = Int()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        self.title = "Catalogue"
    
        BurgerPreview.fetchBurgerPreviews(page: 1, filter: 1,completion: { (data) in
            
            self.burgers = data as! [BurgerPreview]
            
            self.tableView.reloadData()
            
        })
        
        burgers.sort(by: { $0.catalogueNumber < $1.catalogueNumber })
        
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
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        guard let tableViewCell = view as? FilterCatalogueCell else { return }
    
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: section)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return burgers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
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
        
        if burger.photo.count == 0{
            
            let url = URL(string: burger.photoUrl)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async(execute: {
                    
                    burger.photo = data!
                    cell.burgerImage.image  = UIImage(data: data!)
                })
                
            }).resume()
            
        }else{
            
            cell.burgerImage.image  = UIImage(data: burger.photo)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  cell = tableView.dequeueReusableCell(withIdentifier: "FilterCatalogueCell") as! FilterCatalogueCell
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let burger = burgers[indexPath.row]
        
        burgerThumbnail = burger.photo
        selectedBurger = burger
        
        self.performSegue(withIdentifier: "burgerSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        return 80.0;
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        return 60
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        let burgerViewController = segue.destination as! BurgerVC
        
        burgerViewController.burgerThumbnail = UIImage(data:burgerThumbnail)
        burgerViewController.burger = selectedBurger
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
        
    }
    
}

