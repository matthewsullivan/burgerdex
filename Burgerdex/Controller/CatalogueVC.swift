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
    var burgers = [BurgerPreview]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Catalogue"
        
        guard let burgerOne = BurgerPreview.init(name: "The Highway Man",kitchen: "Goody's Diner", catalogueNumber: 23,photoUrl: "highwayMan",burgerID: 23)else {
            fatalError("Unable to instantiate burgerOne")
        }
        
        guard let burgerTwo = BurgerPreview.init(name: "Macho Nacho",kitchen: "Goody's Diner", catalogueNumber: 24,photoUrl: "machoNacho",burgerID: 24)else {
            fatalError("Unable to instantiate burgerTwo")
        }
        
        guard let burgerThree = BurgerPreview.init(name: "Figgy Piggy",kitchen: "Goody's Diner", catalogueNumber: 25,photoUrl: "figgyPiggy",burgerID: 25)else {
            fatalError("Unable to instantiate burgerThree")
        }
        
        guard let burgerFour = BurgerPreview.init(name: "The Bacon Beast",kitchen: "Burger Delight", catalogueNumber: 19,photoUrl: "baconBeast", burgerID: 19)else {
            fatalError("Unable to instantiate burgerFour")
        }
        
        guard let burgerFive = BurgerPreview.init(name: "The Copperworks Burger",kitchen: "Copperworks", catalogueNumber: 17,photoUrl: "copperworks", burgerID: 17)else {
            fatalError("Unable to instantiate burgerFive")
        }
        
        burgers += [burgerOne, burgerTwo, burgerThree, burgerFour, burgerFive]
        
        burgers.sort(by: { $0.catalogueNumber < $1.catalogueNumber })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.burgerImage.image = UIImage(named: burger.photoUrl)
        cell.burgerID = 23
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let burger = burgers[indexPath.row]
        
        selectedBurger = burger
        
        self.performSegue(withIdentifier: "burgerSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0;
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        let burgerViewController = segue.destination as! BurgerVC
        
        burgerViewController.burger = selectedBurger
    }


}

