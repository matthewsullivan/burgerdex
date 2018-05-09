//
//  NotificationViewController.swift
//  NotificationView
//
//  Created by Matthew Sullivan on 2018-04-23.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var catalogueNumberLabel: UILabel!
    @IBOutlet weak var catalogueNumberNumber: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let size = view.bounds.size
        
        preferredContentSize = CGSize(width: size.width, height: size.height / 2)
    }
    
    func didReceive(_ notification: UNNotification) {
        
        if let notificationData = notification.request.content.userInfo["data"] as? [String: Any] {
            
            // Grab the attachment
            if let urlString = notificationData["attachment-url"], let fileUrl = URL(string: urlString as! String) {
                
                let imageData = NSData(contentsOf: fileUrl)
                let image = UIImage(data: imageData! as Data)!
                
                imageView.image = image
              
            }
 
            if let catalogueLabelString = notificationData["attachment-label"]{
                
                catalogueNumberLabel.text = catalogueLabelString as? String
               
            }else{
                
                catalogueNumberLabel.text = "No."
                
            }
            
            if let catalogueLabelNumber = notificationData["attachment-number"]{
                
                catalogueNumberNumber.text = catalogueLabelNumber as? String
                
                
            }else{
                
                catalogueNumberLabel.text = ""
                catalogueNumberNumber.text = ""
               
            }
        }
    }
}
