//
//  TabBarVC.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-17.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var paddingHeight = 0.0
        
        let width = CGFloat(tabBar.frame.width) / CGFloat((self.tabBar.items?.count)!)
        
        if(UIDevice.current.userInterfaceIdiom != .pad){
            var hasTopNotch: Bool {
                if #available(iOS 11.0, *) {
                    return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
                }
                return false
            }
            
            if hasTopNotch{
                paddingHeight = 34.0
                
                UITabBarItem.appearance().titlePositionAdjustment = UIOffset.init(horizontal: 0.0, vertical: 10.0)
                
                tabBar.items?[0].title = "Catalogue"
                tabBar.items?[1].title = "New Discovery"
            } else {
                UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
            }
            
        } else {
            tabBar.items?[0].title = "Catalogue"
            tabBar.items?[1].title = "New Discovery"
        }
        
        UITabBar.appearance().shadowImage = nil
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: 1)
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        UITabBar.appearance().barTintColor = UIColor(red: 56/255, green: 49/255, blue: 40/255, alpha: 1)
        
        UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(color: UIColor(red: 222/255,
                                                                                                           green: 173/255,
                                                                                                           blue: 107/255,
                                                                                                           alpha: 1),
                                                                                            size: CGSize(width: width,
                                                                                                         height:self.tabBar.frame.size.height + CGFloat(paddingHeight)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        if let value = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return value
        } else {
            return identifier
        }
    }
}



extension UIImage {
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x:0, y:0, width:size.width, height:size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
