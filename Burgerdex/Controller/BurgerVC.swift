//
//  BurgerVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-03.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//
import UIKit

class BurgerVC: UITableViewController {
    
    var burger: BurgerPreview!
    
    var burgerAttr = [Array<BurgerObject>]()
    var badges = [Badge]()
    var fusionBurgers = [BurgerPreview]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = burger.name
        
        let burgerHeaderView = BurgerHeaderView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        
        self.tableView.tableHeaderView  = burgerHeaderView
        
        burgerHeaderView.burgerImage.image = UIImage(named: burger.photoUrl)
        
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        guard let burgerInfo = Burger.init(name: burger.name,
                                         kitchen: burger.kitchen,
                                         catalogueNumber: burger.catalogueNumber,
                                         descript: "Best burger in Clarington, hands down. The bacon on this burger is the best bacon I have ever eaten. You have to try this burger.\n\n$17 CAD because of poutine combo.",
                                         burgerID: burger.burgerID,
                                         photoUrl: burger.photoUrl,
                                         location: "Clarington",
                                         rating: "9.2",
                                         price: "CAD $17.00",
                                         ingredients: "BBQ Sauce,Fresh (never frozen delivered that day) double patty,Bacon,Cheese,standard toppings of your choice.",
                                         fusion: true,
                                         veggie: true,
                                         spicy: false,
                                         extinct: false,
                                         seasonal: true,
                                         hasChallenge: true,
                                         hasMods: true,
                                         dateCaptured: "Oct 18, 2017")else {
                                        
            fatalError("Unable to instantiate burger")
        }
        
        guard let burgerOne = BurgerPreview.init(name: "The Bacon Beast",kitchen: "Burger Delight", catalogueNumber: 19,photoUrl: "baconBeast", burgerID: 19)else {
            fatalError("Unable to instantiate burgerFour")
        }
        
        guard let burgerTwo = BurgerPreview.init(name: "The Copperworks Burger",kitchen: "Copperworks", catalogueNumber: 17,photoUrl: "copperworks", burgerID: 17)else {
            fatalError("Unable to instantiate burgerFive")
        }
        
        fusionBurgers += [burgerOne, burgerTwo]
        
        burgerAttr.append([burgerInfo as Burger])
        burgerAttr.append(fusionBurgers)
        
        guard let ratingBadge = Badge.init(ratingTitle: burgerInfo.rating,
                                           badgeTitle: "rating",
                                           badgeIcon: UIImage(named: "rating")!
                                           )else {
                                            
                                        fatalError("Unable to instantiate rating badge")
        }
        
        badges += [ratingBadge]
        
        if burgerInfo.fusion {
            
            guard let fusionBadge = Badge.init(ratingTitle: "",
                                               badgeTitle: "fusion",
                                               badgeIcon: UIImage(named: "fusion")!
                )else {
                    
                    fatalError("Unable to instantiate fusion badge")
            }
            
             badges += [fusionBadge]
        }
        
        if burgerInfo.veggie {
            
            guard let veggieBadge = Badge.init(ratingTitle: "",
                                               badgeTitle: "veggie",
                                               badgeIcon: UIImage(named: "veggie")!
                )else {
                    
                    fatalError("Unable to instantiate veggie badge")
            }
            
            badges += [veggieBadge]
        }
        
        if burgerInfo.spicy {
            
            guard let spicyBadge = Badge.init(ratingTitle: "",
                                               badgeTitle: "spicy",
                                               badgeIcon: UIImage(named: "spicy")!
                )else {
                    
                    fatalError("Unable to instantiate spicy badge")
            }
            
            badges += [spicyBadge]
        }
        
        if burgerInfo.extinct {
            
            guard let extinctBadge = Badge.init(ratingTitle: "",
                                              badgeTitle: "extinct",
                                              badgeIcon: UIImage(named: "extinct")!
                )else {
                    
                    fatalError("Unable to instantiate extinct badge")
            }
            
            badges += [extinctBadge]
        }
        
        if burgerInfo.seasonal {
            
            guard let seasonalBadge = Badge.init(ratingTitle: "",
                                                badgeTitle: "seasonal",
                                                badgeIcon: UIImage(named: "seasonal")!
                )else {
                    
                    fatalError("Unable to instantiate seasonal badge")
            }
            
            badges += [seasonalBadge]
        }
        
        if burgerInfo.hasChallenge {
            
            guard let hasChallengeBadge = Badge.init(ratingTitle: "",
                                                 badgeTitle: "challenge",
                                                 badgeIcon: UIImage(named: "hasChallenge")!
                )else {
                    
                    fatalError("Unable to instantiate hasChallenge badge")
            }
            
            badges += [hasChallengeBadge]
        }
        
        if burgerInfo.hasMods {
            
            guard let hasModsBadge = Badge.init(ratingTitle: "",
                                                    badgeTitle: "mods",
                                                    badgeIcon: UIImage(named: "hasMods")!
                )else {
                    
                    fatalError("Unable to instantiate hasChallege badge")
            }
            
            badges += [hasModsBadge]
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? BurgerTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return burgerAttr.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return burgerAttr[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //If first row it's our burgers information. Else it's fusion burger cells.
         if indexPath.section == 0 {
            
            // Table view cells are reused and should be dequeued using a cell identifier.
            let cellIdentifier = "BurgerInfoCell"
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BurgerTableViewCell  else{
                fatalError("The dequeued cell is not an instance of BurgerTableViewCell.")
            }
            
            let burger = burgerAttr[indexPath.section][indexPath.row] as! Burger
            
            cell.discoveryDate.text = burger.name
            cell.price.text = burger.price
            cell.region.text = burger.location
            cell.descript.text = burger.descript
            
            let ingredients = "• " + burger.ingredients.replacingOccurrences(of: ",", with: "\n\n• ")
            
            cell.ingredients.text = ingredients
            
            return cell
            
         }else{
            
            // Table view cells are reused and should be dequeued using a cell identifier.
            let cellIdentifier = "CatalogueTableViewCell"
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CatalogueTableViewCell  else {
                fatalError("The dequeued cell is not an instance of CatalogueTableViewCell.")
            }
            
            let burger = burgerAttr[indexPath.section][indexPath.row] as! BurgerPreview
            
            cell.burgerName.text = burger.name
            cell.kitchenName.text = burger.kitchen
            cell.catalogueNumberLabel.text = "No."
            cell.catalogueNumberNumber.text = String(burger.catalogueNumber)
            cell.burgerImage.image = UIImage(named: burger.photoUrl)
            cell.burgerID = 23
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
         if section == 0 {
            
            let  cell = tableView.dequeueReusableCell(withIdentifier: "BurgerHeaderCell") as! BurgerHeaderTableViewCell
            
            cell.burgerName.text = burger.name
            cell.kitchenName.text = burger.kitchen
            cell.catalogueNumberLabel.text = "No."
            cell.catalogueNumberNumber.text = String(burger.catalogueNumber)
            
            return cell
            
         }else{
            
            return nil
            
        }
        
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let _ = scrollView as? UITableView {
            
            let headerView = self.tableView.tableHeaderView as! BurgerHeaderView
            
            headerView.scrollViewDidScroll(scrollView: scrollView)
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        if indexPath.section == 1 {
            
            return 80;
            
        }else{
            
            return tableView.rowHeight;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            
            return 0;
            
        }else{
            
            return 80
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension BurgerVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return badges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let burgerBadge = badges[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCell", for: indexPath) as? BurgerBadgeCollectionViewCell  else{
            
            fatalError("The dequeued cell is not an instance of BurgerTableViewCell.")
        }
        
        cell.ratingLabel.text = burgerBadge.ratingTitle
        cell.badgeTitle.text = burgerBadge.badgeTitle
        cell.badgeImage.image = burgerBadge.badgeIcon
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        
    }
}
