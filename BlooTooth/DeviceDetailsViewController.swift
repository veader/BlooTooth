//
//  DeviceDetailsViewController.swift
//  BlooTooth
//
//  Created by Shawn Veader on 9/21/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceDetailsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var identifierLabel: UILabel?
    @IBOutlet weak var stateLabel: UILabel?
    @IBOutlet weak var rssiLabel: UILabel?
    @IBOutlet weak var servicesLabel: UILabel?

    var peripheral: CBPeripheral? {
        didSet {
            setupDeviceLabels()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupDeviceLabels()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralConnected:", name: BlooToothNotifications.PeripheralConnected.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralDisconnected:", name: BlooToothNotifications.PeripheralDisconnected.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralServicesUpdated:", name: BlooToothNotifications.PeripheralServicesUpdated.rawValue, object: nil)

        if let p = self.peripheral {
            BlooToothManager.sharedInstance.connectToPeripheral(p)
        } else {
            // TODO: warn here
            print("No peripheral passed to device details VC")
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(BlooToothManager.sharedInstance)
        if let p = self.peripheral {
            BlooToothManager.sharedInstance.disconnectFromPeripheral(p)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupDeviceLabels() {
        if let p = self.peripheral {
            self.nameLabel?.text = p.name ?? "Unknown"
            self.identifierLabel?.text = p.identifier.UUIDString

            switch p.state {
            case .Disconnected:
                self.stateLabel?.text = "Disconnected"
            case .Disconnecting:
                self.stateLabel?.text = "Disconnecting"
            case .Connected:
                self.stateLabel?.text = "Connected"
            case .Connecting:
                self.stateLabel?.text = "Connecting"
            }

            // only update the services if we are connected - disconnected erases the list :(
            if p.state == CBPeripheralState.Connected {
                var servicesString = "No services known"
                if let services = p.services {
                    servicesString = "\(services.count) service(s) found"
//                    for service: CBService in services {
//                        servicesString.appendContentsOf("\(service)")
//                    }
                }
                self.servicesLabel?.text = servicesString
            }

            self.rssiLabel?.text = "?? (db)"

//            if d.rssi != nil {
//                self.rssiLabel?.text = "\(d.rssi!) db"
//            } else {
//                self.rssiLabel?.text = "Unknown"
//            }
        } else {
            // TODO: pop up something with an alert
            self.nameLabel?.text = ""
            self.identifierLabel?.text = ""
            self.servicesLabel?.text = ""
            self.rssiLabel?.text = ""
        }
    }

    // MARK: - Notification Response Methods
    @objc func peripheralConnected(notification: NSNotification) {
        let p = notification.object as! CBPeripheral
        if p == self.peripheral {
            setupDeviceLabels()
            BlooToothManager.sharedInstance.discoverServicesForPeripheral(p)
        }
    }

    @objc func peripheralDisconnected(notification: NSNotification) {
        let p = notification.object as! CBPeripheral
        if p == self.peripheral {
            setupDeviceLabels()
        }
    }

    @objc func peripheralServicesUpdated(notification: NSNotification) {
        let p = notification.object as! CBPeripheral
        if p == self.peripheral {
            setupDeviceLabels()
        }
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
