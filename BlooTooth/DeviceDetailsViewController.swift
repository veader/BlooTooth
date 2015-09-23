//
//  DeviceDetailsViewController.swift
//  BlooTooth
//
//  Created by Shawn Veader on 9/21/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceDetailsViewController: UIViewController, BlooToothManagerDelegate {

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var identifierLabel: UILabel?
    @IBOutlet weak var stateLabel: UILabel?
    @IBOutlet weak var rssiLabel: UILabel?
    @IBOutlet weak var servicesLabel: UILabel?


    var device: BlooToothDevice? {
        didSet {
            setupDeviceLabels()
        }
    }

    var deviceManager: BlooToothManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupDeviceLabels()

        if self.device != nil && self.deviceManager != nil {
            self.deviceManager?.delegate = self
            self.deviceManager?.connectToDevice(self.device!)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let d = self.device {
            self.deviceManager?.disconnectFromDevice(d)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupDeviceLabels() {
        if let d = device {
            if d.name != nil {
                self.nameLabel?.text = d.name
            } else {
                self.nameLabel?.text = "Unknown"
            }

            if let p = d.peripheral {
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
                    var servicesString = ""
                    if let services = p.services {
                        for service: CBService in services {
                            servicesString.appendContentsOf("\(service)")
                        }
                    }
                    self.servicesLabel?.text = servicesString
                }
            }
            if d.rssi != nil {
                self.rssiLabel?.text = "\(d.rssi!) db"
            } else {
                self.rssiLabel?.text = "Unknown"
            }

        }
    }

    // MARK: - BlooToothManagerDelegate Methods
    func managerDidUpdateDevices(devices : [BlooToothDevice]) { }

    func managerDidConnectToDevice(device: BlooToothDevice) {
        if self.device == device {
            setupDeviceLabels()
            self.deviceManager?.discoverServicesForDevice(device)
        }
    }

    func managerDidDiscoverServiceForDevice(device: BlooToothDevice) {
        if self.device == device {
            setupDeviceLabels()
        }
    }

    func managerDidDisconnectFromDevice(device: BlooToothDevice) {
        if self.device == device {
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
