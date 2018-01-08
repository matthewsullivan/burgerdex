//
//  Burger.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-03.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class Burger {
    

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
