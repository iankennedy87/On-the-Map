//
//  StudentInformation.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/23/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import CoreLocation

struct StudentInformation {
    var dateCreated: NSDate
    var firstName: String
    var lastName: String
    var fullName: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var coordinate: CLLocationCoordinate2D
    var mediaURL: String
    
    init(studentInfoDict: [String:AnyObject]) {
        dateCreated = StudentInformation.getDate(studentInfoDict[StudentInfoKeys.DateCreated] as! String)
        firstName = studentInfoDict[StudentInfoKeys.FirstName] as! String
        lastName = studentInfoDict[StudentInfoKeys.LastName] as! String
        fullName = firstName + " " + lastName
        latitude = studentInfoDict[StudentInfoKeys.Latitude] as! CLLocationDegrees
        longitude = studentInfoDict[StudentInfoKeys.Longitude] as! CLLocationDegrees
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mediaURL = studentInfoDict[StudentInfoKeys.MediaURL] as! String
    }
    
    static func getDate(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'kk:mm:ss.SSS'Z'"
        
        let date = dateFormatter.dateFromString(dateString)
        return date!
    }
    
}