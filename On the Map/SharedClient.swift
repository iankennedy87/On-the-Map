//
//  SharedClient.swift
//  On the Map
//
//  Created by Ian Kennedy on 3/5/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class SharedClient: NSObject {
    
    typealias completionHandlerClosure = ((result: AnyObject!, error: NSError?, alert: UIAlertController?) -> Void)
    typealias sendErrorClosure = ((error: String, alert: UIAlertController?) -> Void)
    
    internal func getSendError(domain: String, completionHandler: completionHandlerClosure) -> ((error: String, alert: UIAlertController?) -> Void) {
        
        func sendError(error: String, alert: UIAlertController?) -> Void {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandler(result: nil, error: NSError(domain: domain, code: 1, userInfo: userInfo), alert: alert)
            
        }
        return sendError
    }
    
    internal func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: completionHandlerClosure) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo), alert: nil)
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil, alert: nil)
    }
    
}