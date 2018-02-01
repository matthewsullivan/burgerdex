//
//  UploadHeaderTableViewCell.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-04.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class UploadHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var burgerName: UILabel!
    @IBOutlet weak var kitchenName: UILabel!
    @IBOutlet weak var progressContainerView: ActivityIndicator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //progressContainerView.startLoading()
        //let colour = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: 1.0)
        
        let colour =  UIColor(red: 222/255, green: 173/255, blue: 107/255, alpha: 1)
        progressContainerView.strokeColor = colour
        //progressContainerView.lineWidth = 2
        //let progress: Float = progressContainerView.progress + 0.1043
        progressContainerView.progress = 9.00
        //progressContainerView.strokeColor = UIColor.red
        //progressContainerView.completeLoading(success: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

/*
 
 @IBAction func startAction(sender: AnyObject) {
 activityView.startLoading()
 
 }
 
 @IBAction func progressAction(sender: AnyObject) {
 let progress: Float = activityView.progress + 0.1043
 activityView.progress = progress
 }
 
 @IBAction func successAction(sender: AnyObject) {
 activityView.startLoading()
 activityView.completeLoading(true)
 }
 
 @IBAction func unsucessAct(sender: AnyObject) {
 activityView.startLoading()
 activityView.strokeColor = UIColor.redColor()
 activityView.completeLoading(false)
 }
 @IBAction func changeColorAct(sender: AnyObject) {
 tapCount++
 
 if (tapCount == 1){
 activityView.strokeColor = UIColor.redColor()
 }
 else
 if (tapCount == 2) {
 activityView.strokeColor = UIColor.blackColor()
 }
 else
 if (tapCount == 3) {
 tapCount = 0
 activityView.strokeColor = UIColor.purpleColor()
 
 }
 
 
 
 
 }
 
 */
