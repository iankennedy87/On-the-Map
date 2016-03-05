//
//  UdacityClient.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/22/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient : NSObject {
    
    var session = NSURLSession.sharedSession()
    var sessionId: String? = nil
    var userKey: String? = nil
    var firstName: String?
    var lastName: String?
    var jsonParameters = [String: AnyObject]()

    
    func createUdacitySession(username: String, password: String, completionHandlerForCreateSession: (result: AnyObject!, error: NSError?, alert: UIAlertController?) -> Void) -> Void {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.SessionURL)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var alert: UIAlertController? = nil
            func sendError(error: String, alert: UIAlertController?) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForCreateSession(result: nil, error: NSError(domain: "createUdacitySession", code: 1, userInfo: userInfo), alert: alert)
            }
            
            guard (error == nil) else { // Handle error…
                //var alert: UIAlertController? = nil
                if (error!.code == -1001) {
                    alert = UIAlertController(title: "Login failed", message: "The request timed out. Check your network connection", preferredStyle: .Alert)
                }
                sendError("Error encountered during login: \(error)", alert: alert)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode
            
            guard statusCode >= 200 && statusCode <= 299 else {
                
                if (statusCode >= 400 && statusCode <= 499) {
                    alert = UIAlertController(title: "Login failed", message: "Account not found or invalid credentials.", preferredStyle: .Alert)
                }
                
                sendError("Your request returned a status code other than 2xx", alert: alert)
                return
            }
            
            guard let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) as NSData? else {
                sendError("Error converting JSON to NSData object", alert: nil)
                return
            }
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForCreateSession)
            //completionHandlerForLogin(result: newData, error: nil)
            //print(NSString(data: newData, encoding: NSUTF8StringEncoding))

        }
        
        task.resume()
        
    }
    
    func loginAndRetrieveUserData(username: String, password: String, completionHandlerForLogin: (success: Bool, error: NSError?, alert: UIAlertController?) -> Void) {
        createUdacitySession(username, password: password) { (result, error, alert) -> Void in
            
            guard (error == nil) else {
                print("Error occurred during login")
                completionHandlerForLogin(success: false, error: error, alert: alert)
                return
            }
            //print("Result from completion handler: \(result!["account"]!)")

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
    
    func getPublicUserData(uniqueKey: String, completionHandlerForGetPublicUserData: (results: AnyObject!, error: NSError?, alert: UIAlertController?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(uniqueKey)")!)

        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else { // Handle error...
                print("error getting public data")
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            //print("User Data: \(NSString(data: newData, encoding: NSUTF8StringEncoding))")
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: { (result, error, alert) -> Void in
                guard (error == nil) else {
                    return
                }
                //print("Result from getPublicUserData: \(result)")
                completionHandlerForGetPublicUserData(results: result, error: nil, alert: nil)
            })
        }
        task.resume()
    }
    
    func logoutOfUdacitySession(completionHandlerForLogout: (result: NSData, error: NSError?) -> Void) -> Void {
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
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            completionHandlerForLogout(result: newData, error: nil)
        }
        task.resume()
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?, alert: UIAlertController?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo), alert: nil)
        }
        //print("Login result: \(parsedResult)")
        completionHandlerForConvertData(result: parsedResult, error: nil, alert: nil)
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}