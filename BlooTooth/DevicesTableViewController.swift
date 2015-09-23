//
//  DevicesTableViewController.swift
//  BlooTooth
//
//  Created by Shawn Veader on 8/7/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit

class DevicesTableViewController: UITableViewController, BlooToothManagerDelegate {
    let blootooth = BlooToothManager()
    let devicesDataSource = DevicesDataSource()
    
    @IBOutlet weak var scanButton : UIBarButtonItem?
    @IBOutlet weak var stopButton : UIBarButtonItem?
    
    var selectedIndex: NSIndexPath?

    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.blootooth.delegate = self
        self.tableView.dataSource = self.devicesDataSource
        
        self.stopButton?.enabled = false

        startBlooToothScan(nil)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.blootooth.delegate = self // so we can take the delegate back
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UI Interaction Methods
    @IBAction func startBlooToothScan(sender: UIButton?) {
        self.blootooth.startScan()
        self.scanButton?.enabled = false
        self.stopButton?.enabled = true
        
        NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "stopScan", userInfo: nil, repeats: false)
    }
    
    @IBAction func stopBlooToothScan(sender: UIButton) {
        stopScan()
    }
    
    func stopScan() {
        self.blootooth.stopScan()
        self.stopButton?.enabled = false
        self.scanButton?.enabled = true
    }

    // MARK: BlooToothManager Delegate Methods
    func managerDidUpdateDevices(devices : [BlooToothDevice]) {
        self.devicesDataSource.updateDevices(devices)
        self.tableView.reloadData()
        // NOTE: If we wanted to do smart updates, we should probably hand the DS the data and 
        //       have it return a list of changed index paths...
        // TODO: reset button back to refresh icon.
    }

    func managerDidConnectToDevice(device: BlooToothDevice) { }
    func managerDidDiscoverServiceForDevice(device: BlooToothDevice) { }
    func managerDidDisconnectFromDevice(device: BlooToothDevice) { }


    // MARK: UITableView Delegate Methods
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        self.selectedIndex = indexPath
        return indexPath
    }
    override func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        self.selectedIndex = nil
        return indexPath
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "btDeviceSegue" {
            if self.selectedIndex != nil {
                let dest = segue.destinationViewController as! DeviceDetailsViewController
                let device = self.devicesDataSource.deviceAtIndex((self.selectedIndex?.row)!)
                dest.device = device
                dest.deviceManager = self.blootooth
            }
            stopScan() // just in case
        } else {
            print("Unknown segue: \(segue.identifier)")
        }
    }

}
