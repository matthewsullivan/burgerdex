//
//  FilterCatalogueHeaderCell.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-15.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class FilterCatalogueHeaderCell: UITableViewHeaderFooterView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
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
