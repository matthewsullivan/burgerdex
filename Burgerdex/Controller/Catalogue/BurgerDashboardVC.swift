//
//  BurgerDashboardVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-03.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//
import UIKit

class BurgerDashboardVC: UITableViewController {
    private let kLazyLoadCollectionCellImage = 1

    var badges = [Badge]()
    var burger: BurgerPreview!
    var burgerAttr = [Array<BurgerObject>]()
    var burgerThumbnail : UIImage!
    var carousel: ZKCarousel! = ZKCarousel()
    var scrollSize: CGFloat = 0.0
    var selectedBurger: BurgerPreview!
    var sightingsBurgers = [BurgerPreview]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollSize = view.frame.size.width;
        
        layoutBurgerView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                   at: UITableView.ScrollPosition.top,
                                   animated: false)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {return burgerAttr.count}
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = scrollView as? UITableView {
            updateCarouselViewHeight()
            
            var offset = scrollView.contentOffset.y / 40
            
            if offset > 1 {
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
        if indexPath.section == 0 {
            let burger = burgerAttr[indexPath.section][indexPath.row] as! Burger
            let cellIdentifier = "BurgerInfoCell"
            let ingredients = "• " + burger.ingredients.replacingOccurrences(of: ",", with: "\n\n• ")
            let locationTitle = burger.locationCount > 1 ? " locations" : " location"
            let sightingsTotal : Int = burger.sightings.count
            let totalSightings = String(sightingsTotal)
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BurgerDashboardTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of BurgerTableViewCell.")
            }
            
            cell.averagePrice.text = burger.averagePrice
            cell.sightings.text = "Catalogued " + totalSightings + " times"
            cell.locations.text = String(burger.locationCount) + locationTitle + " documented"
            cell.ingredients.text = ingredients
            
            return cell
        } else {
            let burger = burgerAttr[indexPath.section][indexPath.row] as! BurgerPreview
            let cellIdentifier = "CatalogueTableViewCell"
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CatalogueTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of CatalogueTableViewCell.")
            }
            
            cell.burgerName.text = burger.name
            cell.kitchenName.text = burger.kitchen
            cell.catalogueNumberLabel.text = burger.displayTag
            cell.catalogueNumberNumber.text = burger.displayText
            
            cell.burgerID = burger.burgerID
            
            updateImageForCell(cell,
                               inTableView: tableView,
                               withImageURL: burger.photoUrl,
                               andImageView: cell.burgerImage!,
                               atIndexPath: indexPath)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            let patty = burgerAttr[indexPath.section][indexPath.row] as! BurgerPreview
            
            selectedBurger = patty
            
            self.performSegue(withIdentifier: "sightingBurgerDetails", sender: self)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {return section == 1 ? 0.0 : 80.0}
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return indexPath.section == 1 ? 80 : tableView.rowHeight}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return burgerAttr[section].count}
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BurgerHeaderCell") as! BurgerDashboardHeaderTableViewCell
            
            cell.burgerName.text = burger.name
            cell.kitchenName.text = burger.kitchen
            cell.catalogueNumberLabel.text = "No."
            cell.catalogueNumberNumber.text = String(burger.catalogueNumber)
            
            return cell
        }
            
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? BurgerDashboardTableViewCell else { return }
           
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    }

    func layoutBurgerView(){
        badges.removeAll()
        burgerAttr.removeAll()
        sightingsBurgers.removeAll()
        
        let burgerHeaderView = BurgerHeaderView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        var burgerInfo = Burger.generateBurgerPlaceholderInformation()
        
        burgerHeaderView.burgerImage.image =  burgerThumbnail
        
        self.tableView.tableHeaderView  = burgerHeaderView
        
        blurEffectView.frame = burgerHeaderView.burgerImage.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.9
        
        burgerHeaderView.burgerImage.addSubview(blurEffectView)
        
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableView.automaticDimension
        
        self.burgerAttr.append([burgerInfo as BurgerObject])
        
        self.tableView.allowsSelection = false
        self.tableView.isScrollEnabled = false
        self.tableView.reloadData()
        
        TableLoader.addLoaderTo(self.tableView)
        
        Burger.fetchBurgerDetails(burgerID: burger.recordID,completion: { (data) in
            if data.count > 0{
                burgerInfo = data[0] as! Burger
                
                if burgerInfo.sightings.count > 0 {
                    var imageCount = 1
                    
                    for burger in burgerInfo.sightings {
                        let displayTag = burger["displayTag"] as? String
                        let displayText = burger["displayText"] as? String
                        let name = burger["name"] as? String
                        let kitchen = burger["kitchen"] as? String
                        let location = burger["locations"] as? String
                        let year = burger["year"] as? String
                        let imagePath = burger["image"] as? String
                        let thumbPath = burger["thumb"] as? String
                        var catalogueNumber = burger["id"] as? Int
                        var recordNumber = burger["recordId"] as? Int
                        let totalSightings = burger["sightings"] as? Int
                        let imageOrigin = "https://burgerdex.ca/"
                        
                        let quote = burger["description"] as? String
                        let descript = "\u{22}" + quote! + "\u{22}"
                        
                        let pattyImagePath = imageOrigin + imagePath!
                        let thumbPattyPath = imageOrigin + thumbPath!
                        
                        if catalogueNumber == nil {catalogueNumber = 0}
                        if recordNumber == nil {recordNumber = 0}
                        
                        guard let burgerPreview = BurgerPreview.init(displayTag: displayTag!,
                                                                     displayText: displayText!,
                                                                     name: name!,
                                                                     kitchen: kitchen!,
                                                                     location: location!,
                                                                     year: year!,
                                                                     catalogueNumber: catalogueNumber!,
                                                                     photoUrl: pattyImagePath,
                                                                     thumbUrl: thumbPattyPath,
                                                                     photo: UIImage(),
                                                                     burgerID: catalogueNumber!,
                                                                     recordID: recordNumber!,
                                                                     sightings: totalSightings!)
                        else {
                            fatalError("Unable to instantiate burgerPreview")
                        }
                        
                        self.sightingsBurgers += [burgerPreview]
                        
                        let url = URL(string: burgerPreview.photoUrl)
                        
                        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if error != nil {
                                return
                            }
                            
                            DispatchQueue.main.async(execute: {
                                UIView.animate(withDuration: 0.5, animations: {
                                    blurEffectView.alpha = 0.0
                                }, completion: { _ in
                                    let title = burgerPreview.displayTag + " " + burgerPreview.displayText
                                    let slide = ZKCarouselSlide(image: UIImage(data: data!)!, title:title, description: descript)
                                    
                                    self.carousel.slides.append(slide)
                                    
                                    if imageCount == burgerInfo.sightings.count{
                                        self.carousel.slides.reverse()
                                        self.setupCarousel()
                                    }
                                    
                                    imageCount = imageCount + 1
                                })
                            })
                        }).resume()
                    }
                }
                
                self.tableView.allowsSelection = true
                self.tableView.isScrollEnabled = true
                
                TableLoader.removeLoaderFrom(self.tableView)
                
                self.burgerAttr[0] = [burgerInfo as BurgerObject]
                self.burgerAttr.append(self.sightingsBurgers)
                
                guard let ratingBadge = Badge.init(ratingTitle: burgerInfo.rating,
                                                   badgeTitle: "rating",
                                                   badgeIcon: UIImage(named: "rating")!)
                else {
                    fatalError("Unable to instantiate rating badge")
                }
                
                self.badges += [ratingBadge]
                
                if (burgerInfo.fusion) {
                    guard let fusionBadge = Badge.init(ratingTitle: "",
                                                       badgeTitle: "fusion",
                                                       badgeIcon: UIImage(named: "fusion")!)
                    else {
                        fatalError("Unable to instantiate fusion badge")
                    }
                    
                    self.badges += [fusionBadge]
                }
                
                if (burgerInfo.veggie) {
                    guard let veggieBadge = Badge.init(ratingTitle: "",
                                                       badgeTitle: "veggie",
                                                       badgeIcon: UIImage(named: "veggie")!)
                    else {
                        fatalError("Unable to instantiate veggie badge")
                    }
                    
                    self.badges += [veggieBadge]
                }
                
                if (burgerInfo.spicy) {
                    guard let spicyBadge = Badge.init(ratingTitle: "",
                                                      badgeTitle: "spicy",
                                                      badgeIcon: UIImage(named: "spicy")!)
                    else {
                        fatalError("Unable to instantiate spicy badge")
                    }
                    
                    self.badges += [spicyBadge]
                }
                
                if (burgerInfo.extinct) {
                    guard let extinctBadge = Badge.init(ratingTitle: "",
                                                        badgeTitle: "extinct",
                                                        badgeIcon: UIImage(named: "available")!)
                    else {
                        fatalError("Unable to instantiate extinct badge")
                    }
                    
                    self.badges += [extinctBadge]
                }
                
                if (burgerInfo.seasonal) {
                    guard let seasonalBadge = Badge.init(ratingTitle: "",
                                                         badgeTitle: "limited",
                                                         badgeIcon: UIImage(named: "seasonal")!)
                    else {
                        fatalError("Unable to instantiate seasonal badge")
                    }
                    
                    self.badges += [seasonalBadge]
                }
                
                if (burgerInfo.hasChallenge) {
                    guard let hasChallengeBadge = Badge.init(ratingTitle: "",
                                                             badgeTitle: "challenge",
                                                             badgeIcon: UIImage(named: "hasChallenge")!)
                    else {
                        fatalError("Unable to instantiate hasChallenge badge")
                    }
                    
                    self.badges += [hasChallengeBadge]
                }
                
                if (burgerInfo.hasMods) {
                    guard let hasModsBadge = Badge.init(ratingTitle: "",
                                                        badgeTitle: "mods",
                                                        badgeIcon: UIImage(named: "hasMods")!)
                    else {
                        fatalError("Unable to instantiate hasChallege badge")
                    }
                    
                    self.badges += [hasModsBadge]
                }
                
                guard let sightingsBadge = Badge.init(ratingTitle: String(burgerInfo.sightings.count),
                                                      badgeTitle: "sightings",
                                                      badgeIcon: UIImage(named: "sightings")!)
                else {
                    fatalError("Unable to instantiate fusion badge")
                }
                
                self.badges += [sightingsBadge]
                
                var locationTitle = "location"
                
                if (burgerInfo.locationCount > 1) {
                    locationTitle = "locations"
                }
                
                guard let locationsBadge = Badge.init(ratingTitle: String(burgerInfo.locationCount),
                                                      badgeTitle: locationTitle,
                                                      badgeIcon: UIImage(named: "locations")!)
                else {
                    fatalError("Unable to instantiate fusion badge")
                }
                
                self.badges += [locationsBadge]
                
                self.tableView.reloadData()
            }
        })
    }
    
    func setupCarousel(){
        let burgerHeaderView = self.tableView.tableHeaderView as! BurgerHeaderView
        
        self.carousel.frame = burgerHeaderView.burgerImage.frame
        self.carousel.contentMode = .scaleAspectFill
        self.carousel.pageControl.numberOfPages = self.carousel.slides.count
        self.carousel.alpha = 0.0
        
        burgerHeaderView.containerView.addSubview(self.carousel)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.carousel.alpha = 1.0
        }, completion: { _ in
            burgerHeaderView.burgerImage.removeFromSuperview()
        })
    }
    
    func updateCarouselViewHeight(){
        var headerRect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0)
        
        if (tableView.contentOffset.y < 200) {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y + 200
        }
        
        self.carousel.collectionView.collectionViewLayout.invalidateLayout()
        self.carousel.frame = headerRect
    }
    
    func updateImageForCell(_ cell: UITableViewCell,
                            inTableView tableView: UITableView,
                            withImageURL: String,
                            andImageView: UIImageView,
                            atIndexPath indexPath: IndexPath) {
        let burger = burgerAttr[indexPath.section][indexPath.row] as! BurgerPreview
        let imageView = andImageView
        let imageURL = burger.photoUrl
        
        imageView.image = kLazyLoadPlaceholderImage
        
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

extension BurgerDashboardVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let burgerBadge = badges[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCell", for: indexPath) as? BurgerBadgeCollectionViewCell
        else {
            fatalError("The dequeued cell is not an instance of BurgerTableViewCell.")
        }
        
        cell.ratingLabel.text = burgerBadge.ratingTitle
        cell.badgeTitle.text = burgerBadge.badgeTitle
        cell.badgeImage.image = burgerBadge.badgeIcon
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {return badges.count}
}
