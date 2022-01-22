//
//  Account.swift
//  Burgerdex
//
//  Created by Matthew Sullivan on 2018-01-03.
//  Copyright © 2020 Dev & Barrel Inc. All rights reserved.
//
import UIKit

private let kUploadToken = "https://www.app.burgerdex.ca/services/ios/apns/send_token.php"
private let versionNumber = "1.2.0"

class Account  {
    class func insertToken(token: String, session: URLSession,completion:@escaping (_ resultPatties:Array<Any>)->Void) {
        session.invalidateAndCancel()
        
        let url = kUploadToken
        let parameters: [String: Any] = ["action": "insert-token", "token": String(token)]
        
        var postRequest = URLRequest(url: URL(string:url)!,
                                     cachePolicy: .reloadIgnoringCacheData,
                                     timeoutInterval: 60.0)
        var tokenResponseData = [0,"Error"] as [Any]
        
        do {
            let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options:[])

            postRequest.httpBody = jsonParams
        } catch {
            return
        }
        
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: postRequest, completionHandler: { (data, response, error) -> Void in
            if data != nil {
                do {
                    if let tokenResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        DispatchQueue.main.async(execute: {
                            let successCode = tokenResponse["success"] as! Int
                            
                            if  successCode == 0 {
                                tokenResponseData[0] = 0
                                
                                completion(tokenResponseData)
                            } else {
                                tokenResponseData[0] = 1
                                
                                completion(tokenResponseData)
                            }
                        } as @convention(block) () -> Void)
                    }
                } catch {
                    tokenResponseData[0] = 0
                    
                    DispatchQueue.main.async(execute: {
                        completion(tokenResponseData)
                    })
                }
            } else {
                tokenResponseData[0] = 1
                
                DispatchQueue.main.async(execute: {
                    completion(tokenResponseData)
                })
            }
        }).resume()
    }
}
