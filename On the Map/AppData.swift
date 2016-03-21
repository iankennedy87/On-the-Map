//
//  AppData.swift
//  On the Map
//
//  Created by Ian Kennedy on 3/21/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation

class AppData: NSObject {
    var studentInformationArray = [StudentInformation]()
    var mapAnnotations = [StudentLocation]()
    var temporaryMapAnnotations : [StudentLocation] = []
    
    class func sharedInstance() -> AppData {
        struct Singleton {
            static var sharedInstance = AppData()
        }
        return Singleton.sharedInstance
    }
}
