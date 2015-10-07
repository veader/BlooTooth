//
//  ServiceDetailsViewController.swift
//  BlooTooth
//
//  Created by Shawn Veader on 10/5/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServiceDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var identifierLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var tableView: UITableView?

    var service: CBService?
    var characteristics: [CBCharacteristic]? = [CBCharacteristic]()
    var selectedCharacteristic: CBCharacteristic?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Service"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        setupServiceLabels()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceCharacteristicsUpdated:", name: BlooToothNotifications.ServiceCharacteristicsUpdated.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "characteristicDescriptorsUpdated:", name: BlooToothNotifications.CharacteristicDescriptorsUpdated.rawValue, object: nil)

        if let s = self.service {
            self.statusLabel?.text = "Discovering Characteristics..."
            BlooToothManager.sharedInstance.discoverCharacteristicsForService(s.peripheral, service: s)
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

    func setupServiceLabels() {
        if let s = self.service {
            self.nameLabel?.text = BlooToothManager.sharedInstance.serviceNameFromUUID(s.UUID.UUIDString)
            self.identifierLabel?.text = s.UUID.UUIDString
        }
    }

    @objc func serviceCharacteristicsUpdated(notification: NSNotification) {
        let s = notification.object as! CBService
        if s == self.service {
            self.characteristics = self.service?.characteristics
            self.tableView?.reloadData()
            self.statusLabel?.text = "Discovering Descriptors..."
            BlooToothManager.sharedInstance.discoverCharacteristicDescriptorsForService(s.peripheral, characteristics: self.service!.characteristics!)
        }
    }

    @objc func characteristicDescriptorsUpdated(notification: NSNotification) {
        let c = notification.object as! CBCharacteristic
        if c == self.selectedCharacteristic {
            self.statusLabel?.text = ""
        }
    }

    // MARK: - UITableViewDataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Characteristics"
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let c = self.characteristics {
            return c.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("btCharacteristicCell") ?? UITableViewCell()

        if let characteristic = characteristicForIndex(indexPath.row) {
            var nameString: String = characteristic.description
//            switch service.UUID.UUIDString {
//            case BlooToothKnownServices.ServiceBattery.rawValue:
//                nameString = "Battery"
//            case BlooToothKnownServices.ServiceDeviceInfo.rawValue:
//                nameString = "Device Information"
//            default:
//                nameString = service.UUID.UUIDString
//            }
            cell.textLabel?.text = nameString
            cell.detailTextLabel?.text = characteristic.UUID.UUIDString
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let characteristic = characteristicForIndex(indexPath.row) {
            print("Selected \(characteristic)")
            self.selectedCharacteristic = characteristic
            BlooToothManager.sharedInstance.discoverCharacteristicsForService(self.service!.peripheral, service: self.service!)
        }
    }

    func characteristicForIndex(index: Int) -> CBCharacteristic? {
        if let c = self.characteristics {
            if c.count >= index {
                return c[index]
            }
        }
        return nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
