//
//  UploadBurgerVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-02.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit
import Photos

class UploadBurgerVC: UIViewController {
    
    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var errorContainerView: UIView!
    @IBOutlet weak var errorHeaderLabel: UILabel!
    @IBOutlet weak var errorBodyLabel: UILabel!
    @IBOutlet weak var errorImageContainer: UIImageView!
    @IBAction func errorButtonLabel(_ sender: Any) {
        
        //self.requestCatalogueBurgerData(page:1, filter:self.selectedFilterIndex)
        
        //got to settings here to allow camera access
        
        if let url = URL(string:UIApplicationOpenSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: { success in
                    print("Open app settings success: \(success)")
                })
            }
        }
        
        print("settings")
        
    }
    
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
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "New Discovery"
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch (status) {
        case PHAuthorizationStatus.notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) -> Void in
                if status == PHAuthorizationStatus.authorized {
                    //self.openImagePickerButton.isEnabled = true
                    self.errorContainerView.isHidden = true
                    
                    self.initView()
                    self.loadPhotos()
                }
            }
        case PHAuthorizationStatus.authorized:
            
            self.errorContainerView.isHidden = true
            
            initView()
            loadPhotos()
            
            break // remove this maybe?
            //openImagePickerButton.isEnabled = true
        case PHAuthorizationStatus.restricted, PHAuthorizationStatus.denied:
            
             self.errorContainerView.isHidden = false
             self.displayErrorView(errorType: 0)
            
            break
        }
        
    }
    
    func displayErrorView(errorType: Int){
        
        self.errorContainerView.isHidden = false
        //Error Type 0 = Filter match
        //Error Type 1 = Network Connection
        
        if errorType == 0 {
            
            self.errorImageContainer.image = UIImage(named: "noFood")
            self.errorHeaderLabel.text = "SORRY"
            self.errorBodyLabel.text = "Burgerdex requires access to your photo's to upload a burger. Please go to your settings and allow access to begin the burger creation process."
            self.errorButton.isHidden = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

    
fileprivate extension UploadBurgerVC {
    fileprivate func initView() {
        
        print("got here init")
        let imgWidth = (collectionView.frame.width - (kCellSpacing * (CGFloat(kColumnCnt) - 1))) / CGFloat(kColumnCnt)
        targetSize = CGSize(width: imgWidth, height: imgWidth)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = targetSize
        layout.minimumInteritemSpacing = kCellSpacing
        layout.minimumLineSpacing = kCellSpacing
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kCellReuseIdentifier)
    }
    
    fileprivate func loadPhotos() {
        
        print("got here loadPhotos")
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
        
        print(photoAsset.description)
        
        self.performSegue(withIdentifier: "uploadBurgerInfoSegue", sender: self)
        
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let burgerInformationViewController = segue.destination as! UploadBurgerInformationVC
        
        burgerInformationViewController.photo = photoAsset
        
    }
    
}

