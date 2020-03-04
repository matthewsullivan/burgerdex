//
//  UploadTableViewCell.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-04.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class UploadTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var regionNameTextField: TweeBorderedTextField!
    @IBOutlet weak var burgerNameTextField: TweeBorderedTextField!
    @IBOutlet weak var priceTextField: TweeBorderedTextField!
    @IBOutlet weak var kitchenNameTextField: TweeBorderedTextField!
    @IBOutlet weak var burgerDescriptionTextView: UITextView!
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var ratingNumberLabel: UILabel!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var ingredientCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: FlowLayout!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addIngredientButton: UIButton!
    @IBOutlet weak var newIngredientTextField: TweeBorderedTextField!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        self.collectionView.delegate = dataSourceDelegate
        self.collectionView.dataSource = dataSourceDelegate
        self.collectionView.tag = row
        self.collectionView.setContentOffset(collectionView.contentOffset, animated:false)
        self.collectionView.reloadData()
        
        self.ingredientCollectionView.delegate = dataSourceDelegate
        self.ingredientCollectionView.dataSource = dataSourceDelegate
        self.ingredientCollectionView.tag = row
        self.ingredientCollectionView.setContentOffset(ingredientCollectionView.contentOffset, animated:false)
        self.ingredientCollectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { self.collectionView.contentOffset.x = newValue }
        get { return self.collectionView.contentOffset.x }
    }
}
