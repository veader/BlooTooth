//
//  DeviceDetailsViewController.swift
//  BlooTooth
//
//  Created by Shawn Veader on 9/21/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct GenericCellType {
        var cellObject: AnyObject
        var cellType: BTGenericCellType
        var expanded: Bool = false
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    let cellReuseIdentifier = "btGenericCell"

    var peripheral: CBPeripheral?
    var cellObjects: [GenericCellType] = [GenericCellType]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Peripheral"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupDeviceLabels()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralConnected:", name: BlooToothNotifications.PeripheralConnected.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralDataChanged:", name: BlooToothNotifications.PeripheralDataChanged.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralDisconnected:", name: BlooToothNotifications.PeripheralDisconnected.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralFinishedInvestigation:", name: BlooToothNotifications.PeripheralServicesUpdated.rawValue, object: nil)

        guard let p = self.peripheral else { print("No peripheral passed to device details VC"); return }
        if p.state != CBPeripheralState.Connected {
            setStatusText("Connecting...")
            BlooToothManager.sharedInstance.connectToPeripheral(p)
        } else {
            setStatusText("Connected")
            loadServices()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        if let p = self.peripheral {
//            BlooToothManager.sharedInstance.disconnectFromPeripheral(p)
//        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupDeviceLabels() {
        guard let p = self.peripheral else { blankDeviceLabels(); return }

        self.nameLabel.text = p.name ?? "Unknown"
        self.identifierLabel.text = p.identifier.UUIDString

        switch p.state {
        case .Disconnected:
            self.stateLabel.text = "Disconnected"
        case .Disconnecting:
            self.stateLabel.text = "Disconnecting"
        case .Connected:
            self.stateLabel.text = "Connected"
        case .Connecting:
            self.stateLabel.text = "Connecting"
        }

        if let rssi = BlooToothManager.sharedInstance.rssiForPeripheralWithUUID(p.identifier) {
            self.rssiLabel.text = "\(rssi) (db)"
        } else {
            self.rssiLabel.text = "Unknown"
        }
    }

    func blankDeviceLabels() {
        self.nameLabel.text = ""
        self.identifierLabel.text = ""
        setStatusText("No device given?")
        self.rssiLabel.text = ""
    }

    func setStatusText(status: String) {
        self.title = status
    }

    func loadServices() {
        self.cellObjects.removeAll()

        guard let p = self.peripheral else {
            self.tableView.reloadData();
            return
        }

        if let services = p.services {
            for service in services {
                self.cellObjects.append(GenericCellType(cellObject: service, cellType: BTGenericCellType.serviceCell, expanded: false))
            }
        }
        self.tableView.reloadData()
    }

    // MARK: - Notification Response Methods
    @objc func peripheralConnected(notification: NSNotification) {
        let p = notification.object as! CBPeripheral
        guard p == self.peripheral else { return }

        loadServices()
        setupDeviceLabels()
        setStatusText("Investigating...")
    }

    @objc func peripheralDisconnected(notification: NSNotification) {
        setupDeviceLabels()
        setStatusText("Disconnected")
    }

    @objc func peripheralFinishedInvestigation(notification: NSNotification) {
        let p = notification.object as! CBPeripheral
        guard p == self.peripheral else { return }

        loadServices()
        setStatusText("Connected")
    }

    @objc func peripheralDataChanged(notification: NSNotification) {
        setupDeviceLabels()
    }

    // MARK: - UITableViewDataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellObjects.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cellItem = cellObjectForIndexPath(indexPath) else { return }
        print("Selected: \(cellItem)")

        if cellItem.expanded {
            // remove any sub-items
            switch cellItem.cellType {
            case .serviceCell:
                let service = (cellItem.cellObject as! CBService)
                removeChildRowsForService(service)
                toggleExpandAndReload(cellItem, indexPath: indexPath)
            case .characteristicCell:
                let characteristic = (cellItem.cellObject as! CBCharacteristic)
                removeChildRowsForCharacteristic(characteristic)
                toggleExpandAndReload(cellItem, indexPath: indexPath)
            case .descriptorCell:
                break
            }
        } else {
            if cellCanExpand(cellItem) == true {
                // expand next layer
                switch cellItem.cellType {
                case .serviceCell:
                    let service = (cellItem.cellObject as! CBService)
                    addChildRowsForService(service, atIndexPath: indexPath)
                    toggleExpandAndReload(cellItem, indexPath: indexPath)
                case .characteristicCell:
                    let characteristic = (cellItem.cellObject as! CBCharacteristic)
                    addChildRowsForCharacteristic(characteristic, atIndexPath: indexPath)
                    toggleExpandAndReload(cellItem, indexPath: indexPath)
                case .descriptorCell:
                    break
                }
            } else {
                self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        }
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cellItem = cellObjectForIndexPath(indexPath) else { return }
        print("Deselected: \(cellItem)")
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)
        var cell: BlooToothGenericCell?

        if dequeuedCell != nil {
            cell = (dequeuedCell as! BlooToothGenericCell)
        } else {
            print("WARNING: No cell was dequeued")
        }

        if let c = cell {
            if let cellItem = cellObjectForIndexPath(indexPath) {
                switch cellItem.cellType {
                case .serviceCell:
                    c.service = (cellItem.cellObject as! CBService)
                    c.setIndentLevel(1)
                case .characteristicCell:
                    c.characteristic = (cellItem.cellObject as! CBCharacteristic)
                    c.setIndentLevel(2)
                case .descriptorCell:
                    c.descriptor = (cellItem.cellObject as! CBDescriptor)
                    c.setIndentLevel(3)
                }
                c.cellExpanded = cellItem.expanded
            }
        }
        return cell!
    }

    // MARK: - Table Logic Helper Methods
    func cellObjectForIndexPath(indexPath: NSIndexPath) -> GenericCellType? {
        guard self.cellObjects.count >= indexPath.row else { return nil }
        return self.cellObjects[indexPath.row]
    }

    func toggleExpandAndReload(cellObject: GenericCellType, indexPath: NSIndexPath) {
        self.cellObjects[indexPath.row].expanded = !cellObject.expanded
        self.tableView.reloadData()
    }

    func cellCanExpand(cellObject: GenericCellType) -> Bool {
        var canExpand = false

        switch cellObject.cellType {
        case .serviceCell:
            let service = (cellObject.cellObject as! CBService)
            if let characteristics = service.characteristics {
                if characteristics.count > 0 {
                    canExpand = true
                }
            }
            if let services = service.includedServices {
                if services.count > 0 {
                    canExpand = true
                }
            }
        case .characteristicCell:
            let characteristic = (cellObject.cellObject as! CBCharacteristic)
            if let descriptors = characteristic.descriptors {
                if descriptors.count > 0 {
                    canExpand = true
                }
            }
        case .descriptorCell:
            break
        }
        return canExpand
    }


    func indexOfCellObjectForObject(obj: AnyObject, theType: BTGenericCellType) -> Int? {
        return self.cellObjects.indexOf( {
            if $0.cellType == theType {
                switch theType {
                case .serviceCell:
                    return (obj as! CBService) == ($0.cellObject as! CBService)
                case .characteristicCell:
                    return (obj as! CBCharacteristic) == ($0.cellObject as! CBCharacteristic)
                case .descriptorCell:
                    return (obj as! CBDescriptor) == ($0.cellObject as! CBDescriptor)
                }
            } else {
                return false
            }
        } )
    }

    func addChildRowsForService(service: CBService, atIndexPath indexPath: NSIndexPath) {
        if let characteristics = service.characteristics {
            var insertIndex = indexPath.row
            for char in characteristics {
                insertIndex = insertIndex + 1
                self.cellObjects.insert(GenericCellType(cellObject: char, cellType: .characteristicCell, expanded: false), atIndex: insertIndex)
            }
        }
    }

    func addChildRowsForCharacteristic(characteristic: CBCharacteristic, atIndexPath indexPath: NSIndexPath) {
        if let descriptors = characteristic.descriptors {
            var insertIndex = indexPath.row
            for desc in descriptors {
                insertIndex = insertIndex + 1
                self.cellObjects.insert(GenericCellType(cellObject: desc, cellType: .descriptorCell, expanded: false), atIndex: insertIndex)
            }
        }
    }

    func removeChildRowsForService(service: CBService) {
        if let characteristics = service.characteristics {
            for char in characteristics {
                if let index = indexOfCellObjectForObject(char, theType: .characteristicCell) {
                    self.cellObjects.removeAtIndex(index)
                }
                removeChildRowsForCharacteristic(char)
            }
        }
    }

    func removeChildRowsForCharacteristic(characteristic: CBCharacteristic) {
        if let descriptors = characteristic.descriptors {
            for desc in descriptors {
                if let index = indexOfCellObjectForObject(desc, theType: .descriptorCell) {
                    self.cellObjects.removeAtIndex(index)
                }
            }
        }
    }
    
    // MARK: - Navigation
//    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
//        guard let ident = identifier else { return false }
//        if ident == "btCharSegue" {
//            let button = sender as! UIButton
//
//            if let indexPath = self.tableView.indexPathForCell(cell) {
//                if let cellItem = cellObjectForIndexPath(indexPath) {
//                    if cellItem.cellType == .characteristicCell {
//                        return true
//                    }
//                }
//            }
//        }
//        return false
//    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "btCharSegue" {
            let button = sender as! UIButton
            // sorry, super dirty digging up the superview tree... but ¯\_(ツ)_/¯
            let cell = button.superview?.superview as! BlooToothGenericCell
            if let indexPath = self.tableView.indexPathForCell(cell) {
                if let cellItem = cellObjectForIndexPath(indexPath) {
                    let dest = segue.destinationViewController as! CharacteristicViewController
                    dest.peripheral = self.peripheral
                    dest.characteristic = cellItem.cellObject as! CBCharacteristic
                }
            }
        } else {
            print("Unknown segue: \(segue.identifier)")
        }   
    }
}
