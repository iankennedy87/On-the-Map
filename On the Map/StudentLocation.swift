//
//  StudentLocation.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/25/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import MapKit

class StudentLocation: NSObject, MKAnnotation {
    let title: String?
    let link: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, link: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.link = link
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return link
    }
}