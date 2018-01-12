//
//  Burger.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-03.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit

//Only using protocol and : BurgerObject on multiple classes due to using multiple different object types in a table view.
//Instead of class BurgerPreview : BurgerObject { syntax, use class BurgerPreview { elsewhere
protocol BurgerObject {
    
}

class BurgerPreview : BurgerObject {

    var name: String
    var kitchen: String
    var catalogueNumber: Int
    var burgerID: Int
    var photoUrl: String
    var photo: Data
    
    init?(name: String, kitchen: String, catalogueNumber: Int, photoUrl: String, photo: Data, burgerID: Int) {
        
        if name.isEmpty || kitchen.isEmpty || catalogueNumber < 0 || burgerID < 0 {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.kitchen = kitchen
        self.catalogueNumber = catalogueNumber
        self.burgerID = burgerID
        self.photoUrl = photoUrl
        self.photo = photo
        
    }
    
    class func fetchBurgerPreviews(page: Int, filter: Int, completion:@escaping (_ resultPatties:Array<Any>)->Void){
        
        var patties = [BurgerPreview]()
    
        //create the url with NSURL
        //https://www.app.burgerdex.ca/services/allBurgers.php
        //https://www.app.burgerdex.ca/services/burgerDetail.php?id=
        
        let postURL = URL(string: "https://www.app.burgerdex.ca/services/allBurgers.php")!
        
        var postRequest = URLRequest(url: postURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60.0)
        
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let parameters: [String: Any] = ["page": String(page), "filter": String(filter)]
        
        do {
            let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options: [])
            postRequest.httpBody = jsonParams
            
        } catch { print("Error: unable to add parameters to POST request.")}
        
        URLSession.shared.dataTask(with: postRequest, completionHandler: { (data, response, error) -> Void in
            
            if error != nil { print("POST Request: Communication error: \(error!)") }
            
            if data != nil {
                
                do {
                   
                    if let burgerResults = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
        
                        DispatchQueue.main.async(execute: {
                        
                            if let burgers = burgerResults["burgers"] as? [[String: Any]] {
                                
                                for burger in burgers {
                                    
                                    let name = burger["name"] as? String
                                    let kitchen = burger["kitchen"] as? String
                                    let imagePath = burger["image"] as? String
                                    let catalogueNumber = burger["id"] as? Int
                                    let imageOrigin = "https://burgerdex.ca/"
                                    
                                    let pattyImagePath = imageOrigin + imagePath!
                                    
                                    guard let burgerPreview = BurgerPreview.init(name: name!,
                                                                                 kitchen: kitchen!,
                                                                                 catalogueNumber: catalogueNumber!,
                                                                                 photoUrl: pattyImagePath,
                                                                                 photo:Data(),
                                                                                 burgerID: catalogueNumber!)else{
                                        fatalError("Unable to instantiate burgerPreview")
                                    }
                                    
                                    patties += [burgerPreview]
                                }
                                completion(patties)
                            }
                            
                        } as @convention(block) () -> Void)
                    }
        
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
            
            } else {
                DispatchQueue.main.async(execute: {
                    print("Received empty response.")
                })
            }
        }).resume()
        
    }
}

class Burger : BurgerObject{
    
    var name: String
    var kitchen: String
    var catalogueNumber: Int
    var descript: String
    var burgerID: Int
    var location: String
    var rating: String
    var price: String
    var ingredients: String
    var fusion: Bool
    var veggie: Bool
    var spicy: Bool
    var extinct: Bool
    var seasonal: Bool
    var hasChallenge: Bool
    var hasMods: Bool
    var dateCaptured: String
    
    init?(name: String,
         kitchen: String,
         catalogueNumber: Int,
         descript: String,
         burgerID: Int,
         location: String,
         rating: String,
         price: String,
         ingredients: String,
         fusion: Bool,
         veggie: Bool,
         spicy: Bool,
         extinct: Bool,
         seasonal: Bool,
         hasChallenge: Bool,
         hasMods: Bool,
         dateCaptured: String) {
        
        
        
        // Initialize stored properties.
        self.name = name
        self.kitchen = kitchen
        self.catalogueNumber = catalogueNumber
        self.descript = descript
        self.burgerID = burgerID
        self.location = location
        self.rating = rating
        self.price = price
        self.ingredients = ingredients
        self.fusion = fusion
        self.veggie = veggie
        self.spicy = spicy
        self.extinct = extinct
        self.seasonal = seasonal
        self.hasChallenge = hasChallenge
        self.hasMods = hasMods
        self.dateCaptured = dateCaptured
        
    }
    
    class func fetchBurgerDetails(burgerID: Int, completion:@escaping (_ pattyInformation:Burger)->Void){
        
        let url = "https://www.app.burgerdex.ca/services/burgerDetail.php?id="

        let path = url + String(burgerID)
       
        let postURL = URL(string: path)!
        
        var postRequest = URLRequest(url: postURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60.0)
        
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let parameters: [String: Any] = ["id": String(burgerID)]
        
        do {
            let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            postRequest.httpBody = jsonParams
            
        } catch { print("Error: unable to add parameters to POST request.")}
        
        URLSession.shared.dataTask(with: postRequest, completionHandler: { (data, response, error) -> Void in
            
            print(postRequest)
            
            if error != nil { print("POST Request: Communication error: \(error!)") }
            
            if data != nil {
                
                do {
                    
                    if let burgerResults = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        
                        DispatchQueue.main.async(execute: {
                            
                            if let burgers = burgerResults["burger"] as? [[String: Any]] {
                                
                                for burger in burgers {
                                    
                                    let name = burger["name"] as? String
                                    let kitchen = burger["kitchen"] as? String
                                    let descript = burger["description"] as? String
                                    let locations = burger["locations"] as? String
                                    let rating = burger["rating"] as? String
                                    let price = burger["price"] as? String
                                    let ingredients = burger["ingredients"] as? String
                                    let dateCaptured = burger["dated"] as? String
                                    let catalogueNumber = burger["id"] as? Int
                                    let fusion = burger["fusion"] as? Bool
                                    let veggie = burger["veggie"] as? Bool
                                    let spicy = burger["spicy"] as? Bool
                                    let extinct = burger["extinct"] as? Bool
                                    let seasonal = burger["seasonal"] as? Bool
                                    let hasChallenge = burger["hasChallenge"] as? Bool
                                    let hasMods = burger["hasMods"] as? Bool
                                    
                                    guard let burgerInfo = Burger.init(name: name!,
                                                                       kitchen: kitchen!,
                                                                       catalogueNumber: catalogueNumber!,
                                                                       descript: descript!,
                                                                       burgerID: catalogueNumber!,
                                                                       location: locations!,
                                                                       rating: rating!,
                                                                       price: price!,
                                                                       ingredients: ingredients!,
                                                                       fusion: fusion!,
                                                                       veggie: veggie!,
                                                                       spicy: spicy!,
                                                                       extinct: extinct!,
                                                                       seasonal: seasonal!,
                                                                       hasChallenge: hasChallenge!,
                                                                       hasMods: hasMods!,
                                                                       dateCaptured: dateCaptured!)else {
                                                                        
                                                                        fatalError("Unable to instantiate burger")
                                    }
                                    
                                     completion(burgerInfo)
                                }
                                
                               
                            }
                            
                            } as @convention(block) () -> Void)
                    }
                    
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                
            } else {
                DispatchQueue.main.async(execute: {
                    print("Received empty response.")
                })
            }
        }).resume()
        
    }
    
}

class Badge : BurgerObject{
    
    var ratingTitle: String
    var badgeTitle: String
    var badgeIcon: UIImage
    
    init?(ratingTitle: String,
          badgeTitle: String,
          badgeIcon: UIImage) {
        
        // Initialize stored properties.
        self.ratingTitle = ratingTitle
        self.badgeTitle = badgeTitle
        self.badgeIcon = badgeIcon
        
    }
    
}
