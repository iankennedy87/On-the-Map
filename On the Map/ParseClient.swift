//
//  ParseClient.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/23/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class ParseClient : NSObject {
    
    var session = NSURLSession.sharedSession()
    var uniqueKey : Int?
    var firstName : String?
    var lastName : String?
    
    func getStudentLocations(var parameters: [String:AnyObject], completionHandlerForGetStudentLocations: (results: AnyObject!, error: NSError?, alert: UIAlertController?) -> Void) -> Void
    
    {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: HTTPHeaderFields.ApplicationID)
        request.addValue(Constants.APIKey, forHTTPHeaderField: HTTPHeaderFields.APIKey)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var alert : UIAlertController? = nil
            
            func sendError(error: String, alert: UIAlertController?) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGetStudentLocations(results: nil, error: NSError(domain: "getStudentLocations", code: 1, userInfo: userInfo), alert: alert)
            }
            
            guard (error == nil) else { // Handle error…
                sendError("Error while getting student locations: \(response)", alert: nil)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode
            guard statusCode >= 200 && statusCode <= 299 else {
                alert = UIAlertController(title: nil, message: "Download failed", preferredStyle: .Alert)
                sendError("Your request returned a status code other than 2xx!: \(response)", alert: alert)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!", alert: nil)
                return
            }
            //print("Raw data: \(NSString(data: data, encoding: NSUTF8StringEncoding))")
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGetStudentLocations)
            //completionHandlerForGetStudentLocations(results: data, error: nil)

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
        
        completionHandlerForConvertData(result: parsedResult, error: nil, alert: nil)
    }
    
    func populateStudentLocationsArray(completionHandlerForPopulateStudentLocationsArray: (success: Bool, error: NSError?, alert: UIAlertController?) -> Void) {
        getStudentLocations([:]) { (results, error, alert) -> Void in
            
            guard (error == nil) else {
                print("Error populating student locations: \(error)")
                completionHandlerForPopulateStudentLocationsArray(success: false, error: error, alert: alert)
                return
            }
            
            //print("Results from populate student array: \(results)")
            guard let studentLocations = results["results"] as? [[String:AnyObject]] else {
                print("response from student locations: \(results)")
                return
            }
            
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            
            
            for location in studentLocations {
                let studentInformation : StudentInformation = StudentInformation(studentInfoDict: location)
                appDelegate.studentInformationArray.append(studentInformation)
            }
            completionHandlerForPopulateStudentLocationsArray(success: true, error: nil, alert: nil)
        }
    }
    
    func postStudentLocation(parameters: [String:AnyObject], completionHandlerForPostStudentLocation: (results: AnyObject!, error: NSError?, alert: UIAlertController?)-> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        let jsonBody = "{\"uniqueKey\": \"\(parameters[JSONBodyKeys.UniqueKey]!)\", \"firstName\": \"\(parameters[JSONBodyKeys.FirstName]!)\", \"lastName\": \"\(parameters[JSONBodyKeys.LastName]!)\",\"mapString\": \"\(parameters[JSONBodyKeys.MapString]!)\", \"mediaURL\": \"\(parameters[JSONBodyKeys.MediaURL]!)\",\"latitude\": \(parameters[JSONBodyKeys.Latitude]!), \"longitude\": \(parameters[JSONBodyKeys.Longitude]!)}"
        print("JSON Body: \(jsonBody)")
        request.HTTPMethod = "POST"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: HTTPHeaderFields.ApplicationID)
        request.addValue(Constants.APIKey, forHTTPHeaderField: HTTPHeaderFields.APIKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error ) -> Void in
            guard (error == nil) else {
                return
            }
            self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForPostStudentLocation)
        }
        
        task.resume()
    }

    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}