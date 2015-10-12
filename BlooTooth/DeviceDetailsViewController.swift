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

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var services: [CBService]? = [CBService]()
    var selectedService: CBService?

    var peripheral: CBPeripheral?

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
            self.statusLabel.text = "Connecting..."
            BlooToothManager.sharedInstance.connectToPeripheral(p)
        } else {
            self.statusLabel.text = "Connected"
            self.services = p.services
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
        self.statusLabel.text = "No device given?"
        self.rssiLabel.text = ""
    }

    // MARK: - Notification Response Methods
    @objc func peripheralConnected(notification: NSNotification) {
        let p = notification.object as! CBPeripheral
        guard p == self.peripheral else { return }
        setupDeviceLabels()
        self.statusLabel.text = "Investigating Device..."
    }

    @objc func peripheralDisconnected(notification: NSNotification) {
        setupDeviceLabels()
    }

    @objc func peripheralFinishedInvestigation(notification: NSNotification) {
        let p = notification.object as! CBPeripheral
        guard p == self.peripheral else { return }
        self.services = p.services
        self.tableView.reloadData()
        self.statusLabel.text = "Connected"
    }

    @objc func peripheralDataChanged(notification: NSNotification) {
        setupDeviceLabels()
    }

    // MARK: - UITableViewDataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Services"
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = self.services {
            return s.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("btServiceCell") ?? UITableViewCell()

        if let service = serviceForIndex(indexPath.row) {
            cell.textLabel?.text = BlooToothManager.sharedInstance.serviceNameFromUUID(service.UUID.UUIDString)
            cell.detailTextLabel?.text = service.UUID.UUIDString
        }
        return cell
    }

    func serviceForIndex(index: Int) -> CBService? {
        if let s = self.services {
            if s.count >= index {
                return s[index]
            }
        }
        return nil
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { print("No segue identifier!?!"); return }

        if identifier == "btServiceSegue" {
            let cell = sender as! UITableViewCell
            if let indexPath = self.tableView.indexPathForCell(cell) {
                if let service = serviceForIndex(indexPath.row) {
                    print("Selected \(service)")
                    self.selectedService = service
                }

                let destController = segue.destinationViewController as! ServiceDetailsViewController
                destController.service = self.selectedService
            }
        }
    }

}
