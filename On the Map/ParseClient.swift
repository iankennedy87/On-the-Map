//
//  ParseClient.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/23/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class ParseClient : SharedClient {
    
    var session = NSURLSession.sharedSession()
    var uniqueKey : Int?
    var firstName : String?
    var lastName : String?
    
    private func getStudentLocations(parameters: [String:AnyObject], method: String, completionHandlerForGetStudentLocations: completionHandlerClosure) -> Void
    
    {
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))

        request.addValue(Constants.ApplicationID, forHTTPHeaderField: HTTPHeaderFields.ApplicationID)
        request.addValue(Constants.APIKey, forHTTPHeaderField: HTTPHeaderFields.APIKey)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var alert : UIAlertController? = nil
            
            let sendError = self.getSendError("getStudentLocations", completionHandler: completionHandlerForGetStudentLocations)
            
            guard (error == nil) else { // Handle error…
                alert = UIAlertController(title: "Download failed", message: "Error occurred while downloading student information", preferredStyle: .Alert)
                sendError(error: "Error while getting student locations: \(response)", alert: alert)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode
            guard statusCode >= 200 && statusCode <= 299 else {
                alert = UIAlertController(title: nil, message: "Download failed", preferredStyle: .Alert)
                sendError(error: "Your request returned a status code other than 2xx!: \(response)", alert: alert)
                return
            }
            
            guard let data = data else {
                sendError(error: "No data was returned by the request!", alert: nil)
                return
            }

            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGetStudentLocations)

        }
        
        task.resume()
        
    }
    
    func populateStudentLocationsArray(completionHandlerForPopulateStudentLocationsArray: (success: Bool, error: NSError?, alert: UIAlertController?) -> Void) {
        var parameters: [String:AnyObject] = [ParameterKeys.Limit : 100]
        parameters[ParameterKeys.Order] = "-updatedAt"
        
        getStudentLocations(parameters, method: "/classes/StudentLocation") { (results, error, alert) -> Void in
            
            guard (error == nil) else {
                print("Error populating student locations: \(error)")
                completionHandlerForPopulateStudentLocationsArray(success: false, error: error, alert: alert)
                return
            }
            

            guard let studentLocations = results["results"] as? [[String:AnyObject]] else {
                print("response from student locations: \(results)")
                return
            }

            
            
            for location in studentLocations {
                let studentInformation : StudentInformation = StudentInformation(studentInfoDict: location)
                AppData.sharedInstance().studentInformationArray.append(studentInformation)

            }
            completionHandlerForPopulateStudentLocationsArray(success: true, error: nil, alert: nil)
        }
    }
    
    func postStudentLocation(parameters: [String:AnyObject], completionHandlerForPostStudentLocation: completionHandlerClosure) -> Void {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        let jsonBody = "{\"uniqueKey\": \"\(parameters[JSONBodyKeys.UniqueKey]!)\", \"firstName\": \"\(parameters[JSONBodyKeys.FirstName]!)\", \"lastName\": \"\(parameters[JSONBodyKeys.LastName]!)\",\"mapString\": \"\(parameters[JSONBodyKeys.MapString]!)\", \"mediaURL\": \"\(parameters[JSONBodyKeys.MediaURL]!)\",\"latitude\": \(parameters[JSONBodyKeys.Latitude]!), \"longitude\": \(parameters[JSONBodyKeys.Longitude]!)}"
        print("JSON Body: \(jsonBody)")
        request.HTTPMethod = "POST"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: HTTPHeaderFields.ApplicationID)
        request.addValue(Constants.APIKey, forHTTPHeaderField: HTTPHeaderFields.APIKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error ) -> Void in
            var alert : UIAlertController? = nil
            
            let sendError = self.getSendError("postStudentLocation", completionHandler: completionHandlerForPostStudentLocation)
            
            guard (error == nil) else {
                alert = UIAlertController(title: nil, message: "Failed to post student location", preferredStyle: .Alert)
                sendError(error: "Error encountered while posting student location", alert: alert)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode
            
            guard statusCode >= 200 && statusCode <= 299 else {
                alert = UIAlertController(title: nil, message: "Failed to post student location", preferredStyle: .Alert)
                sendError(error: "Your request returned a status code other than 2xx!: \(response)", alert: alert)
                return
            }
            self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForPostStudentLocation)
        }
        
        task.resume()
    }
    
    private func parseURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = ParseClient.Constants.ApiScheme
        components.host = ParseClient.Constants.ApiHost
        components.path = ParseClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}