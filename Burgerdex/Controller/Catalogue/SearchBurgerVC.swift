//
//  SearchBurgerVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-04-24.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class SearchBurgerVC: UITableViewController {
    
    var burgers = [BurgerPreview]()

    @IBAction func closeSearchBtn(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Search Burgers"
        
       
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return burgers.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CatalogueTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CatalogueTableViewCell
        
        var burger : BurgerPreview
        
        burger = burgers[indexPath.row]

        
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return nil
    }
    

    func updateImageForCell(_ cell: UITableViewCell,
                            inTableView tableView: UITableView,
                            withImageURL: String,
                            andImageView: UIImageView,
                            atIndexPath indexPath: IndexPath) {
        
        let imageView = andImageView
        
        imageView.image = kLazyLoadPlaceholderImage
        
        var burger : BurgerPreview
    
        burger = burgers[indexPath.row]

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var burger : BurgerPreview
    
        burger = burgers[indexPath.row]
        
        print(burger)
  
        /*
        burgerThumbnail = burger.photo
        selectedBurger = burger
        
        self.performSegue(withIdentifier: "burgerSegue", sender: self)
        */
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        return 80.0
        
    }

}
