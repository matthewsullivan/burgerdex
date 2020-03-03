//
//  BurgerDashboardHeaderTableViewCell.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-04.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class BurgerDashboardHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var burgerName: UILabel!
    @IBOutlet weak var kitchenName: UILabel!
    @IBOutlet weak var catalogueNumberLabel: UILabel!
    @IBOutlet weak var catalogueNumberNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
