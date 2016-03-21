//
//  LocationTableViewController.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/23/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController {
    
    var studentLocations: [StudentInformation] {
        return AppData.sharedInstance().studentInformationArray

    }
    
    var test = "this is the test var"
    
    @IBOutlet var locationsTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData:", name: "refresh", object: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.locationsTableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell")!
        let location = studentLocations[indexPath.row]
        
        // Set the name and image
        cell.textLabel?.text = location.fullName
        cell.imageView?.image = UIImage(named: "Pin")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = studentLocations[indexPath.row]

        guard let url = NSURL(string: cell.mediaURL) else {
            print("Not a valid URL")
            return
        }
        
        performUIUpdatesOnMain { () -> Void in
            UIApplication.sharedApplication().openURL(url)

        }
        
        
    }
    
    func refreshData(notification: NSNotification) {
        performUIUpdatesOnMain { () -> Void in
        self.locationsTableView.reloadData()
        }
    }
}
