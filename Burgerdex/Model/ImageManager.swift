//
//  Burger.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-03.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//
import UIKit

private let _singletonInstance = ImageManager()
private let kLazyLoadMaxCacheImageSize = 20

let kLazyLoadPlaceholderImage = UIImage(named: "baconBeast")!

class ImageManager: NSObject {
    static var sharedInstance: ImageManager { return _singletonInstance }

    var imageCache = [String: UIImage]()
    
    func clearCache() {
        imageCache.removeAll()
    }
    
    func cacheImage(_ image: UIImage, forURL url: String) {
        if imageCache.count > kLazyLoadMaxCacheImageSize {
            imageCache.remove(at: imageCache.startIndex)
        }
        
        imageCache[url] = image
    }
    
    func cachedImageForURL(_ url: String) -> UIImage? {
        return imageCache[url]
    }

    func downloadImageFromURL(_ urlString: String, completion: ((_ success: Bool, _ image: UIImage?) -> Void)?) {
        if let cachedImage = cachedImageForURL(urlString) {
            DispatchQueue.main.async(execute: {
                completion?(true, cachedImage)
            })
        } else if let url = URL(string: urlString) {
            let session = URLSession.shared
            let downloadTask = session.downloadTask(with: url, completionHandler: { (retrievedURL, response, error) -> Void in
                var found = false
                if retrievedURL != nil {
                    if let data = try? Data(contentsOf: retrievedURL!) {
                        if let image = UIImage(data: data) {
                            found = true
                            
                            self.cacheImage(image, forURL: url.absoluteString)
                            
                            DispatchQueue.main.async(execute: {
                                completion?(true, image)
                            })
                        }
                    }
                }
                if (!found) {
                    DispatchQueue.main.async(execute: {
                        completion?(false, nil)
                        
                    })
                }
            })
            downloadTask.resume()
        } else {
            completion?(false, nil)
        }
    }
}
