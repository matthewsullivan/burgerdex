//
//  UploadBurgerVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-02.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit
import Photos

class UploadBurgerVC: UIViewController, UploadBurgerDelegate {
    
    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var errorContainerView: UIView!
    @IBOutlet weak var errorHeaderLabel: UILabel!
    @IBOutlet weak var errorBodyLabel: UILabel!
    @IBOutlet weak var errorImageContainer: UIImageView!
    
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    @IBAction func cameraButtonTouch(_ sender: Any) {
        self.performSegue(withIdentifier: "burgerCameraSegue", sender: self)
    }
    
    var selectedPhoto : UIImage!
    
    var firstLoad = 0
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!

    fileprivate let kCellReuseIdentifier = "PhotoCell"
    fileprivate let kColumnCnt: Int = 3
    fileprivate let kCellSpacing: CGFloat = 2
    fileprivate var fetchResult: PHFetchResult<PHAsset>!
    fileprivate var imageManager = PHCachingImageManager()
    fileprivate var targetSize = CGSize.zero
    
    var photoAsset : PHAsset!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "New Discovery"
        
        setupCollectionViewOfCameraRollPhotos()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if(firstLoad > 0) {
            loadPhotos()

            self.collectionView.reloadData()
        }
        
        firstLoad = 1
    }
    
    func setupCollectionViewOfCameraRollPhotos(){
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch (status) {
            case PHAuthorizationStatus.notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) -> Void in
                    if status == PHAuthorizationStatus.authorized {
                        self.errorContainerView.isHidden = true
                        
                        self.initView()
                        self.loadPhotos()
                    }
                }
            
            case PHAuthorizationStatus.authorized:
                self.errorContainerView.isHidden = true
                
                initView()
                loadPhotos()
        

                break
            case PHAuthorizationStatus.restricted, PHAuthorizationStatus.denied:
                self.errorContainerView.isHidden = false
                self.displayErrorView(errorType: 0)
                
                cameraBtn.isEnabled = false
                
                break
        }
        
        self.collectionView.reloadData()
    }
    
    func displayErrorView(errorType: Int){
        self.errorContainerView.isHidden = false
        
        if errorType == 0 {
            
            self.errorImageContainer.image = UIImage(named: "noFood")
            self.errorHeaderLabel.text = "SORRY"
            self.errorBodyLabel.text = "Burgerdex requires access to your photos to upload a burger. Please go to your settings and allow access to your Camera Roll or Camera to begin the burger creation process."
            self.errorButton.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func performBurgerInformationSegue(photo : UIImage){
        selectedPhoto = photo
        
        self.performSegue(withIdentifier: "uploadBurgerInfoSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "uploadBurgerInfoSegue" {
            let burgerInformationViewController = segue.destination as! UploadBurgerInformationVC
            burgerInformationViewController.photo = selectedPhoto
        }else{
            let burgerCameraView = segue.destination as! BurgerCameraVC
            burgerCameraView.delegate = self
        }
    }
}

fileprivate extension UploadBurgerVC {
    func initView() {
        cameraBtn.isEnabled = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.collectionView.reloadData()
    
        let imgWidth = (collectionView.frame.width - (kCellSpacing * (CGFloat(kColumnCnt) - 1))) / CGFloat(kColumnCnt)
        targetSize = CGSize(width: imgWidth, height: imgWidth)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = targetSize
        layout.minimumInteritemSpacing = kCellSpacing
        layout.minimumLineSpacing = kCellSpacing
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kCellReuseIdentifier)
    }
    
    func loadPhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        fetchResult = PHAsset.fetchAssets(with: .image, options: options)
    }
}
    
extension UploadBurgerVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseIdentifier, for: indexPath)
        let photoAsset = fetchResult.object(at: indexPath.item)
        imageManager.requestImage(for: photoAsset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, info) -> Void in
            let imageView = UIImageView(image: image)
            imageView.frame.size = cell.frame.size
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            cell.contentView.addSubview(imageView)
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
}
    
extension UploadBurgerVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.imageManager.startCachingImages(for: indexPaths.map{ self.fetchResult.object(at: $0.item) }, targetSize: self.targetSize, contentMode: .aspectFill, options: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.imageManager.stopCachingImages(for: indexPaths.map{ self.fetchResult.object(at: $0.item) }, targetSize: self.targetSize, contentMode: .aspectFill, options: nil)
        }
    }
}

extension UploadBurgerVC: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return targetSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photoAsset = fetchResult.object(at: indexPath.item)
        
        self.selectedPhoto = getAssetThumbnail(asset: photoAsset)
    
        self.performSegue(withIdentifier: "uploadBurgerInfoSegue", sender: self)
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: self.view.bounds.width, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
    
        return thumbnail
    }
}

