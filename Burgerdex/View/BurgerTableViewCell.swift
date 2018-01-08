//
//  BurgerTableViewCell.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-04.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class BurgerTableViewCell: UITableViewCell {

    @IBOutlet weak var discoveryDate: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var region: UILabel!
    @IBOutlet weak var descrip: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
