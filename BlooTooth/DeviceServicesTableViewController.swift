//
//  DeviceServicesTableViewController.swift
//  BlooTooth
//
//  Created by Shawn Veader on 8/11/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit

class DeviceServicesTableViewController: UITableViewController {
    var device: BlooToothDevice?

    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        // print("viewWillAppear:")
        if device != nil {
            self.title = device?.description
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // print("viewDidAppear:")
        if device != nil {
            self.title = device?.description
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableView Delegate Methods
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
    
    // Configure the cell...
    
    return cell
    }
    */
    
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}
