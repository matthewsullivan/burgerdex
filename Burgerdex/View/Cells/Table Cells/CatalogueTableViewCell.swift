//
//  CatalogueTableViewCell.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-02.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class CatalogueTableViewCell: UITableViewCell {
    
    @IBOutlet weak var catalogueNumberContainer: UIView!
    @IBOutlet weak var burgerName: UILabel!
    @IBOutlet weak var kitchenName: UILabel!
    @IBOutlet weak var catalogueNumberLabel: UILabel!
    @IBOutlet weak var catalogueNumberNumber: UILabel!
    @IBOutlet weak var burgerImage: UIImageView!
    
    
    var burgerID: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let mask = CAGradientLayer()
        mask.startPoint = CGPoint(x: 0, y: 0.5)
        mask.endPoint = CGPoint(x:1.0, y:0.5)
        let whiteColor = UIColor.white
        mask.colors = [whiteColor.withAlphaComponent(0.0).cgColor,whiteColor.withAlphaComponent(1.0),whiteColor.withAlphaComponent(1.0).cgColor]
        mask.locations = [NSNumber(value: 0.0),NSNumber(value: 0.2),NSNumber(value: 1.0)]
        mask.frame = burgerImage.bounds
        burgerImage.layer.mask = mask
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
