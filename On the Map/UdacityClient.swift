//
//  UdacityClient.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/22/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient : SharedClient {
    
    var session = NSURLSession.sharedSession()
    var sessionId: String? = nil
    var userKey: String? = nil
    var firstName: String?
    var lastName: String?
    var jsonParameters = [String: AnyObject]()

    typealias udacityCompletionHandlerClosure = ((result: AnyObject!, error: NSError?, alert: UIAlertController?) -> Void)
    
    private func createUdacitySession(username: String, password: String, completionHandlerForCreateSession: udacityCompletionHandlerClosure) -> Void {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.SessionURL)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            var alert: UIAlertController? = nil
            
            let sendError = self.getSendError("createUdacitySession", completionHandler: completionHandlerForCreateSession)
            
            guard (error == nil) else { // Handle error…

                alert = UIAlertController(title: "Login failed", message: "Could not connect. Check your network connection", preferredStyle: .Alert)
                sendError(error: "Error encountered during login: \(error)", alert: alert)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode
            
            guard statusCode >= 200 && statusCode <= 299 else {
                
                if (statusCode >= 400 && statusCode <= 499) {
                    print(response)
                    alert = UIAlertController(title: "Login failed", message: "Account not found or invalid credentials.", preferredStyle: .Alert)
                }
                
                sendError(error: "Your attempt to login returned a status code other than 2xx", alert: alert)
                return
            }
            
            guard let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) as NSData? else {
                sendError(error: "Error converting JSON to NSData object", alert: nil)
                return
            }
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForCreateSession)

        }
        
        task.resume()
        
    }
    
    private func getPublicUserData(uniqueKey: String, completionHandlerForGetPublicUserData: udacityCompletionHandlerClosure) -> Void {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(uniqueKey)")!)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            var alert: UIAlertController? = nil
            
            let sendError = self.getSendError("getPublicUserData", completionHandler: completionHandlerForGetPublicUserData)
            
            guard (error == nil) else { // Handle error...
                alert = UIAlertController(title: nil, message: "Error occurred while retrieving public user data", preferredStyle: .Alert)
                sendError(error: "Error getting public data", alert: alert)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode
            
            guard statusCode >= 200 && statusCode <= 299 else {
                
                if (statusCode >= 400 && statusCode <= 499) {
                    alert = UIAlertController(title: nil, message: "Error occurred while retrieving public user data", preferredStyle: .Alert)
                }
                
                sendError(error: "Your request returned a status code other than 2xx", alert: alert)
                return
            }
            
            guard let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) as NSData? else {
                return
            }
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: { (result, error, alert) -> Void in
                
                completionHandlerForGetPublicUserData(result: result, error: nil, alert: nil)
                
            })
        }
        task.resume()
    }
    
    func loginAndRetrieveUserData(username: String, password: String, completionHandlerForLogin: (success: Bool, error: NSError?, alert: UIAlertController?) -> Void) {

        createUdacitySession(username, password: password) { (result, error, alert) -> Void in
            
            guard (error == nil) else {
                completionHandlerForLogin(success: false, error: error, alert: alert)
                return
            }

            guard let accountInfo = result["account"] as? [String:AnyObject] else {
                print("Error getting account info")
                return
            }
            
            guard let uniqueKey = accountInfo[UserDataParameterKeys.UniqueKey] as! String? else {
                print("could not find key")
                return
            }
            
            
            
            self.userKey = uniqueKey
            self.jsonParameters[ParseClient.JSONBodyKeys.UniqueKey] = uniqueKey
            
            self.getPublicUserData(uniqueKey, completionHandlerForGetPublicUserData: { (results, error, alert) -> Void in
                
                guard (error == nil) else {
                    print("Error in get public user data")
                    return
                }
                
                guard let userData = results[UserDataParameterKeys.User] as? [String:AnyObject] else {
                    print("Couldn't find 'user' in public user data: \(results)")
                    return
                }
                
                guard let firstName = userData[UserDataParameterKeys.FirstName] as? String else {
                    print("couldn't find first name")
                    return
                }
                
                guard let lastName = userData[UserDataParameterKeys.LastName] as? String else {
                    print("couldn't find last name")
                    return
                }
                
                self.firstName = firstName
                self.lastName = lastName
                
                self.jsonParameters[ParseClient.JSONBodyKeys.FirstName] = firstName
                self.jsonParameters[ParseClient.JSONBodyKeys.LastName] = lastName

                completionHandlerForLogin(success: true, error: nil, alert: nil)
            })
            
        }
    }
    
    func logoutOfUdacitySession(completionHandlerForLogout: udacityCompletionHandlerClosure) -> Void {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            var alert: UIAlertController? = nil
            let sendError = self.getSendError("logoutOfUdacitySession", completionHandler: completionHandlerForLogout)
            
            guard (error == nil) else {
                alert = UIAlertController(title: nil, message: "Error logging out of Udacity", preferredStyle: .Alert)
                sendError(error: "Error logging out of Udacity", alert: alert)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode
            guard statusCode >= 200 && statusCode <= 299 else {

            if (statusCode >= 400 && statusCode <= 499) {
                alert = UIAlertController(title: nil, message: "Error occurred while retrieving public user data", preferredStyle: .Alert)
            }
            
                sendError(error: "Your request returned a status code other than 2xx", alert: alert)
                return
            }
        
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            completionHandlerForLogout(result: newData, error: nil, alert: nil)
        }
        task.resume()
    }

    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}