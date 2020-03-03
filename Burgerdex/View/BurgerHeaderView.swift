//
//  BurgerHeaderView.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-03.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class BurgerHeaderView: UIView {
    var bottomLayoutConstraint = NSLayoutConstraint()
    var containerLayoutConstraint = NSLayoutConstraint()
    var heightLayoutConstraint = NSLayoutConstraint()
    
    var burgerImage = UIImageView()
    var containerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(containerView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|",
                                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                           metrics: nil,
                                                           views: ["containerView" : containerView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[containerView]|",
                                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                           metrics: nil,
                                                           views: ["containerView" : containerView]))
        
        containerLayoutConstraint = NSLayoutConstraint(item: containerView,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: self,
                                                       attribute: .height,
                                                       multiplier: 1.0,
                                                       constant: 0.0)
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
        
        let bezierPath = UIBezierPath()
        
        let pointA = CGPoint(x: 0, y: layerHeight)
        let pointB = CGPoint(x: layerWidth, y: layerHeight - 30)
        let pointC = CGPoint(x: layerWidth, y: layerHeight + 1)
        let pointD = CGPoint(x: 0, y: layerHeight + 1)
        
        bezierPath.move(to: pointA)
        bezierPath.addLine(to: pointB)
        bezierPath.addLine(to: pointC)
        bezierPath.addLine(to: pointD)
        bezierPath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        
        layer.mask = shapeLayer
        shapeLayer.fillColor = UIColor.white.cgColor
        
        containerView.layer.addSublayer(shapeLayer)
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|",
                                                                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                    metrics: nil,
                                                                    views: ["imageView" : burgerImage]))
        
        bottomLayoutConstraint = NSLayoutConstraint(item: burgerImage,
                                                    attribute: .bottom,
                                                    relatedBy: .equal,
                                                    toItem: containerView,
                                                    attribute: .bottom,
                                                    multiplier: 1.0,
                                                    constant: 0.0)
        heightLayoutConstraint = NSLayoutConstraint(item: burgerImage,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: containerView,
                                                    attribute: .height,
                                                    multiplier: 1.0,
                                                    constant: 0.0)
        
        containerView.addConstraint(bottomLayoutConstraint)
        containerView.addConstraint(heightLayoutConstraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        
        containerView.clipsToBounds = offsetY <= 0
        
        bottomLayoutConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2
        containerLayoutConstraint.constant = scrollView.contentInset.top
        heightLayoutConstraint.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
    }
}
