//
//  SearchBurgerVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-04-26.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//
import UIKit

class SearchBurgerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    let sharedSession = URLSession.shared
    
    var burgers = [BurgerPreview]()
    var burgerThumbnail: UIImage!
    var lastContentOffset: CGFloat = 0
    var originalSetOfBurgers = [BurgerPreview]()
    var sbshown: Bool = false
    var selectedBurger: BurgerPreview!
    var statusBarCorrect: CGFloat = 20.0
    
    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var errorContainerView: UIView!
    @IBOutlet weak var errorHeaderLabel: UILabel!
    @IBOutlet weak var errorBodyLabel: UILabel!
    @IBOutlet weak var errorImageContainer: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func errorButtonLabel(_ sender: Any) {
        searchBar.text = ""
        
        TableLoader.removeLoaderFrom(self.tableView)
        
        self.tableView.reloadData()
        
        hideErrorView()
    }

    @IBAction func closeSearchBtn(_ sender: Any) {self.dismiss(animated: true, completion: nil)}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "burgerDetailSegue") {
            let burgerViewController = segue.destination as! BurgerVC
            
            burgerViewController.burgerThumbnail = burgerThumbnail.size.width == 0.0 ? UIImage(named:"baconBeast") : burgerThumbnail;
            burgerViewController.burger = selectedBurger
        } else {
            let burgerViewController = segue.destination as! BurgerDashboardVC
            
            burgerViewController.burgerThumbnail = burgerThumbnail.size.width == 0.0 ? UIImage(named:"baconBeast") : burgerThumbnail;
            burgerViewController.burger = selectedBurger
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchBar()
        
        self.title = "Search Burgers"
        
        originalSetOfBurgers = burgers
        
        checkPassedBurgers()
        checkForStatusBars()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPassedBurgers()
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

    func checkPassedBurgers() {burgers.count > 0 ? hideErrorView() : self.displayErrorView(errorType: 0)}
    
    func displayErrorView(errorType: Int) {
        self.errorContainerView.isHidden = false
        
        searchBar.resignFirstResponder()
        
        if (errorType == 0) {
            self.errorImageContainer.image = UIImage(named: "noFood")
            self.errorHeaderLabel.text = "SORRY"
            self.errorBodyLabel.text = "No Burger Matches.."
            self.errorButton.isHidden = false
        }
        
        if (errorType == 1) {
            self.errorImageContainer.image = UIImage(named: "noFood")
            self.errorHeaderLabel.text = "Network Error"
            self.errorBodyLabel.text = "It seems that the network connection has been lost."
            self.errorButton.isHidden = false
        }
    }
    
    func hideErrorView() {
        errorContainerView.isHidden = true
        
        TableLoader.removeLoaderFrom(self.tableView)
        
        self.tableView.allowsSelection = true
        self.tableView.isScrollEnabled = true
        
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.count == 0) {
            hideErrorView()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        TableLoader.addLoaderTo(self.tableView)
        
        self.tableView.allowsSelection = false
        self.tableView.isScrollEnabled = false
        
        BurgerPreview.searchForBurgers(searchString: searchBar.text!,
                                       session: sharedSession,
                                       completion: { (data) in
                                        if (data[0] as! Int) == 1 {
                                            if (data[1] as AnyObject).count > 0 {
                                                self.hideErrorView()
                                                
                                                self.burgers.removeAll()
                                                self.burgers = data[1] as! [BurgerPreview]
                                                
                                                searchBar.resignFirstResponder()
                                                
                                                self.tableView.allowsSelection = true
                                                self.tableView.isScrollEnabled = true
                                                
                                                self.tableView.reloadData()
                                                
                                                TableLoader.removeLoaderFrom(self.tableView)
                                            } else {
                                                self.displayErrorView(errorType: 0)
                                                
                                                self.burgers = self.originalSetOfBurgers
                                                
                                                TableLoader.removeLoaderFrom(self.tableView)
                                                
                                                self.tableView.allowsSelection = true
                                                self.tableView.isScrollEnabled = true
                                                
                                                self.tableView.reloadData()
                                                
                                                searchBar.resignFirstResponder()
                                            }
                                        } else {
                                            self.displayErrorView(errorType: 1)
                                            
                                            TableLoader.removeLoaderFrom(self.tableView)
                                            
                                            searchBar.resignFirstResponder()
                                            
                                            self.tableView.allowsSelection = true
                                            self.tableView.isScrollEnabled = true
                                        }
        })
    }
    
    func setUpSearchBar() {
        searchBar.keyboardAppearance = .dark
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchBurgerVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchBurgerVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    func updateImageForCell(_ cell: UITableViewCell,
                            inTableView tableView: UITableView,
                            withImageURL: String,
                            andImageView: UIImageView,
                            atIndexPath indexPath: IndexPath) {
        var burger : BurgerPreview

        burger = burgers[indexPath.row]
        
        let imageURL = burger.thumbUrl
        let imageView = andImageView
        
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
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        if burger.catalogueNumber != 0 {
            updateImageForCell(cell,
                               inTableView: tableView,
                               withImageURL: burger.thumbUrl,
                               andImageView: cell.burgerImage!,
                               atIndexPath: indexPath)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var burger : BurgerPreview
        
        burger = burgers[indexPath.row]
        
        burgerThumbnail = burger.photo
        selectedBurger = burger
        
        self.performSegue(withIdentifier: burger.sightings > 1 ? "searchMultipleSightingSegue" : "burgerDetailSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 80.0}
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return burgers.count}
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {return nil}
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = scrollView as? UITableView {
            self.searchBar.frame = CGRect(x:self.searchBar.frame.origin.x,
                                          y: (self.navigationController?.navigationBar.frame.size.height)! + statusBarCorrect - 1,
                                          width:self.searchBar.frame.width,
                                          height:self.searchBar.frame.height
            )
            
            self.lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let _ = scrollView as? UITableView {
            self.searchBar.frame = CGRect(x:self.searchBar.frame.origin.x,
                                          y: (self.navigationController?.navigationBar.frame.size.height)! + statusBarCorrect - 1,
                                          width:self.searchBar.frame.width,
                                          height:self.searchBar.frame.height
            )
            
            self.lastContentOffset = scrollView.contentOffset.y
        }
    }
        
    @objc func dismissKeyboard() {view.endEditing(true)}
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        
        self.tableView.contentInset = contentInset
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        var contentInset:UIEdgeInsets = self.tableView.contentInset
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue

        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        contentInset.bottom = keyboardFrame.size.height
        
        self.tableView.contentInset = contentInset
    }
}
