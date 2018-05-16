//
//  BurgerHeaderView.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-03.
//  Copyright © 2018 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class BurgerHeaderView: UIView {
    
    var heightLayoutConstraint = NSLayoutConstraint()
    var bottomLayoutConstraint = NSLayoutConstraint()
    
    var containerView = UIView()
    var containerLayoutConstraint = NSLayoutConstraint()
    var burgerImage = UIImageView()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        // The container view is needed to extend the visible area for the image view
        // to include that below the navigation bar. If this container view isn't present
        // the image view would be clipped at the navigation bar's bottom and the parallax
        // effect would not work correctly
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["containerView" : containerView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[containerView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["containerView" : containerView]))
        containerLayoutConstraint = NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0)
        self.addConstraint(containerLayoutConstraint)
        burgerImage = UIImageView.init()
        burgerImage.translatesAutoresizingMaskIntoConstraints = false
        burgerImage.backgroundColor = UIColor.white
        burgerImage.clipsToBounds = true
        burgerImage.contentMode = .scaleAspectFill
        burgerImage.image = UIImage(named: "baconBeast")
        containerView.addSubview(burgerImage)
        
        
        let layerHeight = frame.size.height
        let layerWidth = frame.size.width * 3
        
        // Create Path
        let bezierPath = UIBezierPath()
        
        //  Points
        let pointA = CGPoint(x: 0, y: layerHeight)
        let pointB = CGPoint(x: layerWidth, y: layerHeight - 30)
        let pointC = CGPoint(x: layerWidth, y: layerHeight + 1)
        let pointD = CGPoint(x: 0, y: layerHeight + 1)
        
        // Draw the path
        bezierPath.move(to: pointA)
        bezierPath.addLine(to: pointB)
        bezierPath.addLine(to: pointC)
        bezierPath.addLine(to: pointD)
        bezierPath.close()
        
        // Mask to Path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        layer.mask = shapeLayer
        
        shapeLayer.fillColor = UIColor.white.cgColor
        containerView.layer.addSublayer(shapeLayer)
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView" : burgerImage]))
        bottomLayoutConstraint = NSLayoutConstraint(item: burgerImage, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        containerView.addConstraint(bottomLayoutConstraint)
        heightLayoutConstraint = NSLayoutConstraint(item: burgerImage, attribute: .height, relatedBy: .equal, toItem: containerView, attribute: .height, multiplier: 1.0, constant: 0.0)
        containerView.addConstraint(heightLayoutConstraint)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        containerLayoutConstraint.constant = scrollView.contentInset.top
        
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        
        containerView.clipsToBounds = offsetY <= 0
        
        bottomLayoutConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2
        
        heightLayoutConstraint.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
    }

}
