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
    
    init?(name: String, kitchen: String, catalogueNumber: Int, photoUrl: String, burgerID: Int) {
        
        if name.isEmpty || kitchen.isEmpty || catalogueNumber < 0 || burgerID < 0 {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.kitchen = kitchen
        self.catalogueNumber = catalogueNumber
        self.burgerID = burgerID
        self.photoUrl = photoUrl
        
    }
    
}

class Burger : BurgerObject{
    
    var name: String
    var kitchen: String
    var catalogueNumber: Int
    var descript: String
    var burgerID: Int
    var photoUrl: String
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
         photoUrl: String,
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
        self.photoUrl = photoUrl
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
