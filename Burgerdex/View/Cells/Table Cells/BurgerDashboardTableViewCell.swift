//
//  BurgerDashboardTableViewCell.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-04.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class BurgerDashboardTableViewCell: UITableViewCell {

    @IBOutlet weak var averagePrice: UILabel!
    @IBOutlet weak var sightings: UILabel!
    @IBOutlet weak var locations: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ingredients: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        print("SET UP COLLECTION")
        
        self.collectionView.delegate = dataSourceDelegate
        self.collectionView.dataSource = dataSourceDelegate
        self.collectionView.tag = row
        self.collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        self.collectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { self.collectionView.contentOffset.x = newValue }
        get { return self.collectionView.contentOffset.x }
    }

}
