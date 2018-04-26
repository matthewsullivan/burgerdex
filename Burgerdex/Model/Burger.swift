//
//  Burger.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-03.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit
/*
    If the version number directory is different than the current version of the app, this indicates that the old service folder is fine to use with the current app version we are on. This stops us from having to create multiple directories on the server for any small bug fix or enhancement. As well as if we didn't update the service code.
 */
private let versionNumber = "1.2.0"
private let kBurgerPreview = "https://www.app.burgerdex.ca/services/ios/" + versionNumber + "/allBurgers.php"
private let kSearchBurger = "https://www.app.burgerdex.ca/services/ios/" + versionNumber + "/searchBurgers.php"
private let kBurgerDetail = "https://www.app.burgerdex.ca/services/ios/" + versionNumber + "/burgerDetail.php"
private let kSubmitBurger = "https://www.burgerdex.ca/services/submitBurger.php"
private let kBaseImagePath = "https://burgerdex.ca/"

//Only using protocol and : BurgerObject on multiple classes due to using multiple different object types in a table view.
//Instead of class BurgerPreview : BurgerObject { syntax, use class BurgerPreview { elsewhere
protocol BurgerObject {
    
}

class BurgerPreview : BurgerObject {

    var displayTag: String
    var displayText: String
    var name: String
    var kitchen: String
    var location: String
    var year: String
    var catalogueNumber: Int
    var burgerID: Int
    var photoUrl: String
    var thumbUrl: String
    var photo: UIImage
    
    init?(displayTag: String,
          displayText: String,
          name: String,
          kitchen: String,
          location: String,
          year: String,
          catalogueNumber: Int,
          photoUrl: String,
          thumbUrl: String,
          photo: UIImage,
          burgerID: Int) {
        
        if displayTag.isEmpty ||
           displayText.isEmpty ||
           name.isEmpty ||
           kitchen.isEmpty ||
           catalogueNumber < 0 ||
           burgerID < 0 ||
           location.isEmpty  ||
           year.isEmpty{
            
            return nil
        }
        
        //Initialize stored properties.
        self.displayTag = displayTag
        self.displayText = displayText
        self.name = name
        self.kitchen = kitchen
        self.location = location
        self.year = year
        self.catalogueNumber = catalogueNumber
        self.burgerID = burgerID
        self.photoUrl = photoUrl
        self.thumbUrl = thumbUrl
        self.photo = photo
        
        
    }
    
    class func generatePlaceholderBurgers() ->Array<Any>{
        
        var patties = [BurgerPreview]()
        
        for _ in 1...10 {
            
            guard let burgerPlaceholder = BurgerPreview.init(displayTag:"No.",
                                                          displayText:"19",
                                                          name:"Bacon Beast",
                                                        kitchen: "Burger Delight",
                                                        location: "Clarington",
                                                        year: "2017",
                                                catalogueNumber: 0,
                                                       photoUrl: "baconBeast",
                                                       thumbUrl: "baconBeast",
                                                          photo:UIImage(),
                                                       burgerID: 0)else{
                                                    
                                                    fatalError("Unable to instantiate burgerPreview")
            }
            
            patties += [burgerPlaceholder]
            
        }
        
        return patties
        
    }
    
    
    class func fetchBurgerPreviews(page: Int, filter: Int, session: URLSession,  completion:@escaping (_ resultPatties:Array<Any>)->Void){
        
        //Start by invalidating on going long tasks
        session.invalidateAndCancel()
        
        var patties = [BurgerPreview]()
        
        var burgerPreviewSuccess = [0,patties] as [Any]

        let url = kBurgerPreview
        var postRequest = URLRequest(url: URL(string:url)!,
                            cachePolicy: .reloadIgnoringCacheData,
                        timeoutInterval: 60.0)
        
        let parameters: [String: Any] = ["page": String(page), "filter": String(filter)]
        
        print(parameters)
        
        do {
            
            let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options:[])
            
            postRequest.httpBody = jsonParams
    
            
        } catch { print("Error: unable to add parameters to POST request.")}
        
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: postRequest, completionHandler: { (data, response, error) -> Void in
            
            if error != nil { print("POST Request: Communication error: \(error!)") }
            
            if data != nil {
                
                do {
                   
                    if let burgerResults = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    
                        DispatchQueue.main.async(execute: {
                        
                            if let burgers = burgerResults["burgers"] as? [[String: Any]] {
                                
                                for burger in burgers {
                                    
                                    let displayTag = burger["displayTag"] as? String
                                    let displayText = burger["displayText"] as? String
                                    let name = burger["name"] as? String
                                    let kitchen = burger["kitchen"] as? String
                                    let location = burger["locations"] as? String
                                    let year = burger["year"] as? String
                                    let imagePath = burger["image"] as? String
                                    let thumbPath = burger["thumb"] as? String
                                    let catalogueNumber = burger["id"] as? Int
                                    let imageOrigin = kBaseImagePath
                                    let pattyImagePath = imageOrigin + imagePath!
                                    let pattyThumbImagePath = imageOrigin + thumbPath!
                                    
                                    guard let burgerPreview = BurgerPreview.init(displayTag: displayTag!,
                                                                                 displayText: displayText!,
                                                                                 name: name!,
                                                                                 kitchen: kitchen!,
                                                                                 location: location!,
                                                                                 year: year!,
                                                                                 catalogueNumber: catalogueNumber!,
                                                                                 photoUrl: pattyImagePath,
                                                                                 thumbUrl : pattyThumbImagePath,
                                                                                 photo:UIImage(),
                                                                                 burgerID: catalogueNumber!)else{
                                        fatalError("Unable to instantiate burgerPreview")
                                    }
                                    
                                    patties += [burgerPreview]
                                }
                                
                                 burgerPreviewSuccess[0] = 1
                                 burgerPreviewSuccess[1] = patties
                                
                                completion(burgerPreviewSuccess)
                            }
                            
                        } as @convention(block) () -> Void)
                    }
        
                } catch {
                    
                    print("Error deserializing JSON: \(error)")
                    
                    burgerPreviewSuccess[0] = 0
                    burgerPreviewSuccess[1] = patties
                    DispatchQueue.main.async(execute: {
                        completion(burgerPreviewSuccess)
                        
                    })
                    
                }
            
            } else {
                
                DispatchQueue.main.async(execute: {
                    print("Received empty response.")
                    
                    burgerPreviewSuccess[0] = 0
                    burgerPreviewSuccess[1] = patties
                    
                    completion(burgerPreviewSuccess)
                    
                })
            }
            
        }).resume()
        
    }
    
    class func searchForBurgers(searchString: String, session: URLSession,  completion:@escaping (_ resultPatties:Array<Any>)->Void){
        
        //Start by invalidating on going long tasks
        session.invalidateAndCancel()
        
        var patties = [BurgerPreview]()
        
        var burgerPreviewSuccess = [0,patties] as [Any]
        
        let url = kSearchBurger
        var postRequest = URLRequest(url: URL(string:url)!,
                                     cachePolicy: .reloadIgnoringCacheData,
                                     timeoutInterval: 60.0)
        
        let parameters: [String: Any] = ["searchString": String(searchString)]
        
        print(parameters)
        
        do {
            
            let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options:[])
            
            postRequest.httpBody = jsonParams
            
            
        } catch { print("Error: unable to add parameters to POST request.")}
        
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: postRequest, completionHandler: { (data, response, error) -> Void in
            
            if error != nil { print("POST Request: Communication error: \(error!)") }
            
            if data != nil {
                
                do {
                    
                    if let burgerResults = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        
                        DispatchQueue.main.async(execute: {
                            
                            if let burgers = burgerResults["burgers"] as? [[String: Any]] {
                                
                                for burger in burgers {
                                    
                                    let displayTag = burger["displayTag"] as? String
                                    let displayText = burger["displayText"] as? String
                                    let name = burger["name"] as? String
                                    let kitchen = burger["kitchen"] as? String
                                    let location = burger["locations"] as? String
                                    let year = burger["year"] as? String
                                    let imagePath = burger["image"] as? String
                                    let thumbPath = burger["thumb"] as? String
                                    let catalogueNumber = burger["id"] as? Int
                                    let imageOrigin = kBaseImagePath
                                    let pattyImagePath = imageOrigin + imagePath!
                                    let pattyThumbImagePath = imageOrigin + thumbPath!
                                    
                                    guard let burgerPreview = BurgerPreview.init(displayTag: displayTag!,
                                                                                 displayText: displayText!,
                                                                                 name: name!,
                                                                                 kitchen: kitchen!,
                                                                                 location: location!,
                                                                                 year: year!,
                                                                                 catalogueNumber: catalogueNumber!,
                                                                                 photoUrl: pattyImagePath,
                                                                                 thumbUrl : pattyThumbImagePath,
                                                                                 photo:UIImage(),
                                                                                 burgerID: catalogueNumber!)else{
                                                                                    fatalError("Unable to instantiate burgerPreview")
                                    }
                                    
                                    patties += [burgerPreview]
                                }
                                
                                burgerPreviewSuccess[0] = 1
                                burgerPreviewSuccess[1] = patties
                                
                                completion(burgerPreviewSuccess)
                            }
                            
                            } as @convention(block) () -> Void)
                    }
                    
                } catch {
                    
                    print("Error deserializing JSON: \(error)")
                    
                    burgerPreviewSuccess[0] = 0
                    burgerPreviewSuccess[1] = patties
                    DispatchQueue.main.async(execute: {
                        completion(burgerPreviewSuccess)
                        
                    })
                    
                }
                
            } else {
                
                DispatchQueue.main.async(execute: {
                    print("Received empty response.")
                    
                    burgerPreviewSuccess[0] = 0
                    burgerPreviewSuccess[1] = patties
                    
                    completion(burgerPreviewSuccess)
                    
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
    var fused: [Dictionary<String, AnyObject>]
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
         fused: [Dictionary<String, AnyObject>],
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
        self.fused = fused
        self.veggie = veggie
        self.spicy = spicy
        self.extinct = extinct
        self.seasonal = seasonal
        self.hasChallenge = hasChallenge
        self.hasMods = hasMods
        self.dateCaptured = dateCaptured
        
    }
    
    class func generateBurgerPlaceholderInformation() ->Burger{
        
        guard let burgerPlaceholder = Burger.init(name: "Bacon Beast",
                                           kitchen: "Burger Delight",
                                           catalogueNumber: 0,
                                           descript: "Best burger in Clarington, hands down. The bacon on this burger is the best bacon I have ever eaten. You have to try this burger.\n\n \n\n$17 CAD because of poutine combo.",
                                           burgerID: 0,
                                           location: "Clarington",
                                           rating: "9.2",
                                           price: "CAD $17.00",
                                           ingredients: "BBQ Sauce \n\n Fresh (never frozen, delivered that day) double patty \n\n Bacon \n\n Cheese \n\n standard toppings of your choice.",
                                           fusion: false,
                                           fused: [],
                                           veggie: false,
                                           spicy: false,
                                           extinct: false,
                                           seasonal: false,
                                           hasChallenge: false,
                                           hasMods: false,
                                           dateCaptured: "2017-10-18 08:08:59") else {
                                            
                                            fatalError("Unable to instantiate burger")
        }
        
        return burgerPlaceholder
        
    }
    
    class func fetchBurgerDetails(burgerID: Int, completion:@escaping (_ pattyInformation:Array<Any>)->Void){
        
        let url = kBurgerDetail
        
        var postRequest = URLRequest(url: URL(string:url)!,
                                     cachePolicy: .reloadIgnoringCacheData,
                                     timeoutInterval: 60.0)
        
        let parameters: [String: Any] = ["id": String(burgerID)]
        
        do {
            
            let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options:[])
            
            postRequest.httpBody = jsonParams
            
            
        } catch { print("Error: unable to add parameters to POST request.")}
        
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: postRequest, completionHandler: { (data, response, error) -> Void in
            
            print(postRequest)
            
            if error != nil { print("POST Request: Communication error: \(error!)") }
            
            var patty = [Burger]()
            
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
                                    let fused = burger["fused"] as? [Dictionary<String, AnyObject>]
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
                                                                       fused: fused!,
                                                                       veggie: veggie!,
                                                                       spicy: spicy!,
                                                                       extinct: extinct!,
                                                                       seasonal: seasonal!,
                                                                       hasChallenge: hasChallenge!,
                                                                       hasMods: hasMods!,
                                                                       dateCaptured: dateCaptured!)else {
                                                                        
                                                                        fatalError("Unable to instantiate burger")
                                    }
                                    
                                    patty.append(burgerInfo)
                                    
                                    completion(patty)
                                }
                                
                               
                            }
                            
                            } as @convention(block) () -> Void)
                    }
                    
                } catch {
                    
                    print("Error deserializing JSON: \(error)")
                    
                    completion(patty)
                }
                
            } else {
                DispatchQueue.main.async(execute: {
                    
                    print("Received empty response.")
                    
                    completion(patty)
                })
            }
        }).resume()
        
    }
}

class BurgerSubmit{
    
    func submitBurger(details: Dictionary<String, Any>, image: UIImage, completion:@escaping (_ requestResponse:Array<Any>)->Void){
        
        var message = [Any]()
        
        var responseCode = [0,message] as [Any]
        
        var r  = URLRequest(url: URL(string: kSubmitBurger)!)
        r.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        r.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
        r.httpBody = createBody(parameters: details  as! [String : String],
                                boundary: boundary,
                                data: UIImageJPEGRepresentation(image, 0.1)!,
                                mimeType: "image/jpg",
                                filename: "burger.jpg")
        
        URLSession.shared.dataTask(with: r as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if error != nil { print("POST Request: Comsmunication error: \(error!)") }
            
            if data != nil {
                
                do {
                    
                    if let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        
                        print(response)
                        
                        DispatchQueue.main.async(execute: {
                            
                            if let response = response["error"] as? [[String: Any]] {
                                
                                var serverMsg : String = "Success"
                                var serverCode: Int = 0
                                
                                for msg in response {
                                    
                                    message.append(msg["code"]! as! Int)
                                    message.append(msg["message"]! as! String)
                                    
                                    serverMsg = message[1] as! String
                                    serverCode = message[0] as! Int
                                    
                                }
                                
                                responseCode[0] = serverCode
                                responseCode[1] = serverMsg
                                
                                completion(responseCode)
                            }
                            
                        } as @convention(block) () -> Void)
                    }
                    
                } catch {
                    
                    print("Error deserializing JSON: \(error)")
                    
                    responseCode[0] = 1
                    responseCode[1] = message
                    DispatchQueue.main.async(execute: {
                        completion(responseCode)
                        
                    })
                    
                }
                
            } else {
                
                DispatchQueue.main.async(execute: {
                    print("Received empty response.")
                    
                    responseCode[0] = 0
                    responseCode[1] = message
                    
                    completion(responseCode)
                    
                })
            }
            
        }).resume()

    }
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"user_image\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
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
