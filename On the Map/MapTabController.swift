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
        toggleRefreshButton()
        AppData.sharedInstance().studentInformationArray = []
        AppData.sharedInstance().temporaryMapAnnotations = AppData.sharedInstance().mapAnnotations
        AppData.sharedInstance().mapAnnotations = []

        NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
        
            ParseClient.sharedInstance().populateStudentLocationsArray { (success, error, alert) -> Void in
                guard success else {

                    print("refresh failed")
                    performUIUpdatesOnMain({ () -> Void in
                        self.toggleRefreshButton()
                        alert!.addAction(UIAlertAction(title: "OK", style: .Default , handler: nil))
                        self.presentViewController(alert!, animated: true, completion: nil)
                    })
                    return
                }
                
                performUIUpdatesOnMain({ () -> Void in
                    self.toggleRefreshButton()
                })
                AppData.sharedInstance().temporaryMapAnnotations = []

                NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
            }

    }
    
    func postLocation() {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func logout() {
        UdacityClient.sharedInstance().logoutOfUdacitySession { (result, error, alert) -> Void in

            guard (error == nil) else {
                print("logout failed")
                return
            }
            performUIUpdatesOnMain({ () -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })

        }
    }
    
    func toggleRefreshButton() {
        let button = navigationItem.rightBarButtonItems![0]
        if button.enabled {
            button.enabled = false
        }
        else {
            button.enabled = true
        }
    }
    
}