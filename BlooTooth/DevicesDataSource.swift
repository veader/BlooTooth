//
//  DevicesDataSource.swift
//  BlooTooth
//
//  Created by Shawn Veader on 8/7/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit
import Foundation

class DevicesDataSource : NSObject, UITableViewDataSource {
    var blootoothDevices = [BlooToothDevice]()

    func updateDevices(devices: [BlooToothDevice]) {
        self.blootoothDevices = devices
    }

    // MARK: UITableViewDataSource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blootoothDevices.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let device = self.blootoothDevices[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("btDevice") ?? UITableViewCell()
        var titleString = device.name ?? "Unknown" // device.description
        if device.rssi != nil {
            titleString.appendContentsOf(" (\(device.rssi!) db)")
        }
        cell.textLabel?.text = titleString
        cell.detailTextLabel?.text = device.identifier.UUIDString
        return cell
    }
    
    func deviceAtIndex(index: Int) -> BlooToothDevice {
        return self.blootoothDevices[index]
    }
}