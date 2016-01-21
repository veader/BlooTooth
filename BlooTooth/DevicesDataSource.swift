//
//  DevicesDataSource.swift
//  BlooTooth
//
//  Created by Shawn Veader on 8/7/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesDataSource : NSObject, UITableViewDataSource {
    var blootoothDevices = [CBPeripheral]()

    override init() {
        super.init()
        // go ahead and grab what the manager may have
        updateDevices(BlooToothManager.sharedInstance.peripherals)
    }

    func updateDevices(peripherals: [CBPeripheral]) {
        self.blootoothDevices = peripherals
    }

    // MARK: - UITableViewDataSource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blootoothDevices.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let peripheral = self.blootoothDevices[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("btDevice") ?? UITableViewCell()
        let titleString = peripheral.name ?? "Unknown" // device.description
        cell.textLabel?.text = titleString
        cell.detailTextLabel?.text = peripheral.identifier.UUIDString
        return cell
    }
    
    func deviceAtIndex(index: Int) -> CBPeripheral {
        return self.blootoothDevices[index]
    }
}