//
//  DevicesTableViewController.swift
//  BlooTooth
//
//  Created by Shawn Veader on 8/7/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesTableViewController: UITableViewController {
    let devicesDataSource = DevicesDataSource()
    
    @IBOutlet weak var scanButton : UIBarButtonItem!
    @IBOutlet weak var stopButton : UIBarButtonItem!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self.devicesDataSource

        stopScan()

        self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralsUpdated:", name: BlooToothNotifications.PeripheralsUpdated.rawValue, object: nil)
        self.tableView.reloadData() // in case any of the devices found more info after connecting...
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UI Interaction Methods
    @IBAction func startBlooToothScan(sender: UIButton?) {
        BlooToothManager.sharedInstance.startScan()
        self.stopButton.enabled = true
        self.scanButton.enabled = false

        NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: "stopScan", userInfo: nil, repeats: false)
    }
    
    @IBAction func stopBlooToothScan(sender: UIButton) {
        stopScan()
    }
    
    func stopScan() {
        BlooToothManager.sharedInstance.stopScan()
        self.stopButton.enabled = false
        self.scanButton.enabled = true
    }

    // MARK: - Notification Response Methods
    @objc func peripheralsUpdated(notification: NSNotification) {
        let peripherals = notification.object as! [CBPeripheral]
        self.devicesDataSource.updateDevices(peripherals)
        self.tableView.reloadData()
        // NOTE: If we wanted to do smart updates, we should probably hand the DS the data and
        //       have it return a list of changed index paths...
        // TODO: reset button back to refresh icon.
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "btDeviceSegue" {
            let cell = sender as! UITableViewCell
            if let indexPath = self.tableView.indexPathForCell(cell) {
                let dest = segue.destinationViewController as! DeviceDetailsViewController
                let peripheral = self.devicesDataSource.deviceAtIndex(indexPath.row)
                dest.peripheral = peripheral
                stopScan() // just in case
            }
        } else {
            print("Unknown segue: \(segue.identifier)")
        }
    }

}
