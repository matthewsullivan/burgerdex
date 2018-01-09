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
    
    var burgerAttr = [Burger]()
    var badges = [Badge]()
    
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
                                         ingredients: "BBQ Sauce,Fresh (never frozen delivered that day) double patty, Bacon,Cheese, standard toppings of your choice.",
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
    
        burgerAttr += [burgerInfo]
        
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
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return burgerAttr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "BurgerInfoCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BurgerTableViewCell  else{
            fatalError("The dequeued cell is not an instance of BurgerTableViewCell.")
        }
        
        let burger = burgerAttr[indexPath.row]
   
        cell.discoveryDate.text = burger.name
        cell.price.text = burger.price
        cell.region.text = burger.location
        cell.descript.text = burger.descript
                
        let ingredients = burger.ingredients.replacingOccurrences(of: ",", with: "\n\n")
        
        cell.ingredients.text = ingredients
 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  cell = tableView.dequeueReusableCell(withIdentifier: "BurgerHeaderCell") as! BurgerHeaderTableViewCell
        
        cell.burgerName.text = burger.name
        cell.kitchenName.text = burger.kitchen
        cell.catalogueNumberLabel.text = "No."
        cell.catalogueNumberNumber.text = String(burger.catalogueNumber)
        
        
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let _ = scrollView as? UITableView {
            
            let headerView = self.tableView.tableHeaderView as! BurgerHeaderView
            
            headerView.scrollViewDidScroll(scrollView: scrollView)
        }

    }
    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 400.0;
    }
    */
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80.0
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
