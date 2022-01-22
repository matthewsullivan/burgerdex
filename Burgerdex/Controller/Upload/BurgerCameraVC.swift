//
//  BurgerCameraVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-02-02.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//
import UIKit
import Photos

protocol UploadBurgerDelegate {
    func performBurgerInformationSegue(photo : UIImage)
}

class BurgerCameraVC: UIViewController {
    let cameraController = CameraController()
    
    var delegate: UploadBurgerDelegate?
    
    @IBOutlet weak var burgerImage: UIImageView!
    @IBOutlet fileprivate var captureButton: UIButton!
    @IBOutlet fileprivate var capturePreviewView: UIView!
    @IBOutlet weak var cancelBurgerPhotoBtn: UIBarButtonItem!
    @IBOutlet weak var savePhotoBtn: UIBarButtonItem!
    @IBOutlet fileprivate var toggleFlashButton: UIButton!
    
    @IBAction func cancelBurgerCapture(_ sender: Any) {
        if self.cancelBurgerPhotoBtn.tag == 1{
            dismiss(animated: true, completion: nil)
        } else {
            self.burgerImage.isHidden = true
            self.savePhotoBtn.isEnabled = false
            self.cancelBurgerPhotoBtn.title = "Cancel"
            
            cancelBurgerPhotoBtn.tag = 1
        }
    }

    @IBAction func saveBurgerPhoto(_ sender: Any) {
        try? PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.creationRequestForAsset(from: self.burgerImage.image!)
        }
        
        delegate?.performBurgerInformationSegue(photo : self.burgerImage.image!)
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func configureCameraController() {
            cameraController.prepare {(error) in
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        
        UINavigationBar.appearance().prefersLargeTitles = false
        
        let barButtonItemAppearance = UIBarButtonItem.appearance()

        barButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        styleCaptureButton()
        configureCameraController()
        
        savePhotoBtn.isEnabled = false
        self.burgerImage.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UINavigationBar.appearance().prefersLargeTitles = true
        
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BurgerCameraVC {
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash Off Icon"), for: .normal)
        } else {
            cameraController.flashMode = .on
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash On Icon"), for: .normal)
        }
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else { return }
            
            self.burgerImage.image = image
            self.burgerImage.isHidden = false
            self.savePhotoBtn.isEnabled = true
            self.cancelBurgerPhotoBtn.title = "Retake"
            self.cancelBurgerPhotoBtn.tag = 0
        }
    }
}

