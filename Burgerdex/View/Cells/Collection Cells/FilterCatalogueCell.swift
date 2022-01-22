//
//  FilterCatalogueCell.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-10.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//
import UIKit

class FilterCatalogueCell: UITableViewCell {
    var collectionViewOffset: CGFloat {
        set { self.collectionView.contentOffset.x = newValue }
        get { return self.collectionView.contentOffset.x }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        self.collectionView.delegate = dataSourceDelegate
        self.collectionView.dataSource = dataSourceDelegate
        self.collectionView.tag = row
        self.collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        self.collectionView.reloadData()
    }
}
