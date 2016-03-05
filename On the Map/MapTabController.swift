//
//  MapTabController.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/26/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class MapTabController: UITabBarController {
    
    static let object = UIApplication.sharedApplication().delegate
    let appDelegate = object as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems![0].target = self
        navigationItem.rightBarButtonItems![0].action = "refreshStudentLocations"
        navigationItem.rightBarButtonItems![1].target = self
        navigationItem.rightBarButtonItems![1].action = "postLocation"
        navigationItem.leftBarButtonItem!.target = self
        navigationItem.leftBarButtonItem!.action = "logout"


    }
    
    
    func refreshStudentLocations() {
        appDelegate.studentInformationArray = []
        appDelegate.temporaryMapAnnotations = appDelegate.mapAnnotations
        appDelegate.mapAnnotations = []
        NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
        
        ParseClient.sharedInstance().populateStudentLocationsArray { (success, error, alert) -> Void in
            guard success else {
                print("refresh failed")
                return
            }
            self.appDelegate.temporaryMapAnnotations = []
            NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
        }

    }
    
    func postLocation() {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func logout() {
        UdacityClient.sharedInstance().logoutOfUdacitySession { (result, error) -> Void in
//            guard let data = result as NSData? else {
//                print("Error turning result to NSData")
//                return
//            }
            //print(NSString(data: data, encoding: NSUTF8StringEncoding))
            guard (error == nil) else {
                print("logout failed")
                return
            }
            self.dismissViewControllerAnimated(true, completion: nil)

        }
    }
    
}