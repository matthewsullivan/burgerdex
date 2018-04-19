//
//  BurgerCameraVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-02-02.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit
import Photos

protocol UploadBurgerDelegate {
    func performBurgerInformationSegue(photo : UIImage)
}

class BurgerCameraVC: UIViewController {
    
    var delegate: UploadBurgerDelegate?
    
    @IBOutlet fileprivate var captureButton: UIButton!
    @IBOutlet fileprivate var toggleFlashButton: UIButton!
    @IBOutlet fileprivate var capturePreviewView: UIView!
    @IBOutlet weak var savePhotoBtn: UIBarButtonItem!
    @IBOutlet weak var cancelBurgerPhotoBtn: UIBarButtonItem!
    
    @IBOutlet weak var burgerImage: UIImageView!
    let cameraController = CameraController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        
        UINavigationBar.appearance().prefersLargeTitles = false
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        
        savePhotoBtn.isEnabled = false
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        styleCaptureButton()
        configureCameraController()
        
         self.burgerImage.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    
        UINavigationBar.appearance().prefersLargeTitles = true
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveBurgerPhoto(_ sender: Any) {
        
        try? PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.creationRequestForAsset(from: self.burgerImage.image!)
        }
                
        delegate?.performBurgerInformationSegue(photo : self.burgerImage.image!)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelBurgerCapture(_ sender: Any) {
        
        if self.cancelBurgerPhotoBtn.tag == 1{
            
             dismiss(animated: true, completion: nil)
            
        }else{
            
            //self.view.bringSubview(toFront: self.capturePreviewView)
            //self.view.sendSubview(toBack: self.burgerImage)
            self.burgerImage.isHidden = true
            
            self.savePhotoBtn.isEnabled = false
            
            self.cancelBurgerPhotoBtn.title = "Cancel"
            
            cancelBurgerPhotoBtn.tag = 1
        }
    
       
        
       
        
    }
}

extension BurgerCameraVC {
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash Off Icon"), for: .normal)
        }
            
        else {
            cameraController.flashMode = .on
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash On Icon"), for: .normal)
        }
    }

    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            self.burgerImage.image = image
            //self.view.bringSubview(toFront: self.burgerImage)
            
             self.burgerImage.isHidden = false
            
            self.savePhotoBtn.isEnabled = true
        
            self.cancelBurgerPhotoBtn.title = "Re-Take"
            self.cancelBurgerPhotoBtn.tag = 0
        
            /*
            

 */
        }
    }
    
}

