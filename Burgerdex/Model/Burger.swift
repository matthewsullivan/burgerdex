//
//  Burger.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-03.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//

import UIKit

private let versionNumber = "1.5.0"

private let kBaseImagePath = "https://burgerdex.ca/"
private let kBurgerDetail = "https://www.app.burgerdex.ca/services/ios/" + versionNumber + "/burgerDetail.php"
private let kBurgerPreview = "https://www.app.burgerdex.ca/services/ios/" + versionNumber + "/allBurgers.php"
private let kSearchBurger = "https://www.app.burgerdex.ca/services/ios/" + versionNumber + "/searchBurgers.php"
private let kSubmitBurger = "https://www.burgerdex.ca/services/submitBurger.php"

protocol BurgerObject {}

class BurgerPreview : BurgerObject {
    var displayTag: String
    var displayText: String
    var name: String
    var kitchen: String
    var location: String
    var year: String
    var catalogueNumber: Int
    var burgerID: Int
    var recordID: Int
    var sightings: Int
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
          burgerID: Int,
          recordID: Int,
          sightings: Int) {
        
        if displayTag.isEmpty ||
           displayText.isEmpty ||
           name.isEmpty ||
           kitchen.isEmpty ||
           catalogueNumber < 0 ||
           burgerID < 0 ||
           location.isEmpty  ||
           year.isEmpty {
            return nil
        }
        
        self.displayTag = displayTag
        self.displayText = displayText
        self.name = name
        self.kitchen = kitchen
        self.location = location
        self.year = year
        self.catalogueNumber = catalogueNumber
        self.burgerID = burgerID
        self.recordID = recordID
        self.sightings = sightings
        self.photoUrl = photoUrl
        self.thumbUrl = thumbUrl
        self.photo = photo
    }
    
    class func generatePlaceholderBurgers() ->Array<Any> {
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
                                                             burgerID: 0,
                                                             recordID: 0,
                                                             sightings: 1)
            else {
                    fatalError("Unable to instantiate burgerPreview")
            }
            
            patties += [burgerPlaceholder]
        }
        
        return patties
    }
    
    class func fetchBurgerPreviews(page: Int,
                                   filter: Int,
                                   session: URLSession,
                                   completion:@escaping (_ resultPatties:Array<Any>)->Void) {
        session.invalidateAndCancel()
        
        let url = kBurgerPreview
        let parameters: [String: Any] = ["page": String(page), "filter": String(filter)]
        
        var patties = [BurgerPreview]()
        var burgerPreviewSuccess = [0,patties] as [Any]
        var postRequest = URLRequest(url: URL(string:url)!,
                            cachePolicy: .reloadIgnoringCacheData,
                        timeoutInterval: 60.0)
        
        do {
            let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options:[])
            postRequest.httpBody = jsonParams
        } catch {
            return
        }

        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: postRequest, completionHandler: { (data, response, error) -> Void in
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
                                    let recordNumber = burger["recordId"] as? Int
                                    let totalSightings = burger["sightings"] as? Int
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
                                                                                 burgerID: catalogueNumber!,
                                                                                 recordID:recordNumber!,
                                                                                 sightings: totalSightings!)
                                    else {
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
                    burgerPreviewSuccess[0] = 0
                    burgerPreviewSuccess[1] = patties
                    DispatchQueue.main.async(execute: {
                        completion(burgerPreviewSuccess)
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
                    burgerPreviewSuccess[0] = 0
                    burgerPreviewSuccess[1] = patties
                    
                    completion(burgerPreviewSuccess)
                })
            }
        }).resume()
    }
    
    class func searchForBurgers(searchString: String,
                                session: URLSession,
                                completion:@escaping (_ resultPatties:Array<Any>)->Void) {
        session.invalidateAndCancel()
        
        let url = kSearchBurger
        let parameters: [String: Any] = ["searchString": String(searchString)]
        
        var patties = [BurgerPreview]()
        var burgerPreviewSuccess = [0,patties] as [Any]
        var postRequest = URLRequest(url: URL(string:url)!,
                                     cachePolicy: .reloadIgnoringCacheData,
                                     timeoutInterval: 60.0)
        
        do {
            let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options:[])
            postRequest.httpBody = jsonParams
        } catch {
            return
        }

        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: postRequest, completionHandler: { (data, response, error) -> Void in
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
                                    let recordNumber = burger["recordId"] as? Int
                                    let totalSightings = burger["sightings"] as? Int
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
                                                                                 burgerID: catalogueNumber!,
                                                                                 recordID: recordNumber!,
                                                                                 sightings: totalSightings!)
                                    else {
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
                    burgerPreviewSuccess[0] = 0
                    burgerPreviewSuccess[1] = patties
                    DispatchQueue.main.async(execute: {
                        completion(burgerPreviewSuccess)
                        
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
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
    var averagePrice: String
    var ingredients: String
    var fusion: Bool
    var fused: [Dictionary<String, AnyObject>]
    var sightings: [Dictionary<String, AnyObject>]
    var locationCount: Int
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
  averagePrice: String,
         ingredients: String,
         fusion: Bool,
         fused: [Dictionary<String, AnyObject>],
         sightings: [Dictionary<String, AnyObject>],
     locationCount: Int,
         veggie: Bool,
         spicy: Bool,
         extinct: Bool,
         seasonal: Bool,
         hasChallenge: Bool,
         hasMods: Bool,
         dateCaptured: String) {

        self.name = name
        self.kitchen = kitchen
        self.catalogueNumber = catalogueNumber
        self.descript = descript
        self.burgerID = burgerID
        self.location = location
        self.rating = rating
        self.price = price
        self.averagePrice = averagePrice
        self.ingredients = ingredients
        self.fusion = fusion
        self.sightings = sightings
        self.locationCount = locationCount
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
                                           averagePrice: "$17.00",
                                           ingredients: "BBQ Sauce \n\n Fresh (never frozen, delivered that day) double patty \n\n Bacon \n\n Cheese \n\n standard toppings of your choice.",
                                           fusion: false,
                                           fused: [],
                                           sightings: [],
                                           locationCount: 1,
                                           veggie: false,
                                           spicy: false,
                                           extinct: false,
                                           seasonal: false,
                                           hasChallenge: false,
                                           hasMods: false,
                                           dateCaptured: "2017-10-18 08:08:59")
        else {
            fatalError("Unable to instantiate burger")
        }
        
        return burgerPlaceholder
    }
    
    class func fetchBurgerDetails(burgerID: Int, completion:@escaping (_ pattyInformation:Array<Any>)->Void) {
        let url = kBurgerDetail
        let parameters: [String: Any] = ["id": String(burgerID)]
        
        var postRequest = URLRequest(url: URL(string:url)!,
                                     cachePolicy: .reloadIgnoringCacheData,
                                     timeoutInterval: 60.0)
        
        do {
            let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options:[])
            postRequest.httpBody = jsonParams
        } catch {
            return
        }

        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: postRequest, completionHandler: { (data, response, error) -> Void in
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
                                    let averagePrice = burger["averagePrice"] as? String
                                    let ingredients = burger["ingredients"] as? String
                                    let dateCaptured = burger["dated"] as? String
                                    let catalogueNumber = burger["id"] as? Int
                                    let fusion = burger["fusion"] as? Bool
                                    let fused = burger["fused"] as? [Dictionary<String, AnyObject>]
                                    let sightings = burger["sightings"] as? [Dictionary<String, AnyObject>]
                                    let locationCount = burger["locationCount"] as? Int
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
                                                                       averagePrice: averagePrice!,
                                                                       ingredients: ingredients!,
                                                                       fusion: fusion!,
                                                                       fused: fused!,
                                                                       sightings: sightings!,
                                                                       locationCount: locationCount!,
                                                                       veggie: veggie!,
                                                                       spicy: spicy!,
                                                                       extinct: extinct!,
                                                                       seasonal: seasonal!,
                                                                       hasChallenge: hasChallenge!,
                                                                       hasMods: hasMods!,
                                                                       dateCaptured: dateCaptured!)
                                    else {
                                        fatalError("Unable to instantiate burger")
                                    }
                                    
                                    patty.append(burgerInfo)
                                    
                                    completion(patty)
                                }
                            }
                        } as @convention(block) () -> Void)
                    }
                } catch {
                    completion(patty)
                }
            } else {
                DispatchQueue.main.async(execute: {
                    completion(patty)
                    
                    self.fetchBurgerDetails(burgerID: burgerID,completion: { (data) in
                        completion(patty)
                    })
                })
            }
        }).resume()
    }
}

class BurgerSubmit{
    func submitBurger(details: Dictionary<String, Any>,
                      image: UIImage,
                      completion:@escaping (_ requestResponse:Array<Any>)->Void) {
        let boundary = "Boundary-\(UUID().uuidString)"

        var message = [Any]()
        var responseCode = [0,message] as [Any]
        var r  = URLRequest(url: URL(string: kSubmitBurger)!)

        r.httpMethod = "POST"
        r.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        r.httpBody = createBody(parameters: details  as! [String : String],
                                boundary: boundary,
                                data: image.jpegData(compressionQuality: 0.1)!,
                                mimeType: "image/jpg",
                                filename: "burger.jpg")
        
        URLSession.shared.dataTask(with: r as URLRequest, completionHandler: { (data, response, error) -> Void in
            if data != nil {
                do {
                    if let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        DispatchQueue.main.async(execute: {
                            if let response = response["error"] as? [[String: Any]] {
                                var serverCode: Int = 0
                                var serverMsg : String = "Success"
                                
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
                    responseCode[0] = 1
                    responseCode[1] = message

                    DispatchQueue.main.async(execute: {
                        completion(responseCode)
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
                    responseCode[0] = 1
                    responseCode[1] = "Burger upload failed."
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

        self.ratingTitle = ratingTitle
        self.badgeTitle = badgeTitle
        self.badgeIcon = badgeIcon
    }
}
