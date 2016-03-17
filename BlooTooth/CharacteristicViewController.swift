//
//  CharacteristicViewController.swift
//  BlooTooth
//
//  Created by Shawn Veader on 2/22/16.
//  Copyright © 2016 V8 Logic. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicViewController: UIViewController {

    let checkMark = "☑"
    let xCheckMark = "☒"

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var notifyingLabel: UILabel!
    @IBOutlet weak var stringValueLabel: UILabel!
    @IBOutlet weak var intValueLabel: UILabel!
    @IBOutlet weak var binaryValueLabel: UILabel!
    @IBOutlet weak var hexValueLabel: UILabel!

    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Characteristic"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateCharLabels()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "characteristicDataUpdated:", name: BlooToothNotifications.CharacteristicDataUpdated.rawValue, object: nil)

        guard let c = self.characteristic else { print("No characteristic passed to characteristic details VC"); return }
        if let p = self.peripheral {
            BlooToothManager.sharedInstance.subscribeToUpdatesForCharacteristic(c, peripheral: p)
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

    func updateCharLabels() {
        if let c = self.characteristic {
            self.nameLabel.text = "Name: \(c.friendlyName()!)"
            self.uuidLabel.text = "UUID: \(c.UUID.UUIDString)"
            self.notifyingLabel.text = "Notifying: \(c.isNotifying == true ? checkMark : xCheckMark)"

            if let data = c.value {
                let str = String(data: data, encoding: NSUTF8StringEncoding)

                var intValue: Int16 = 0
                data.getBytes(&intValue, length: sizeof(Int16))
                let binaryString = String(intValue, radix: 2)
                let hexString = String(intValue, radix: 16).uppercaseString

                self.stringValueLabel.text = "String: \(str)"
                self.intValueLabel.text = "Int: \(intValue)"
                self.binaryValueLabel.text = "Binary: \(binaryString)"
                self.hexValueLabel.text = "Hex: \(hexString)"
            } else {
                blankValueLabels()
            }
        } else {
            self.nameLabel.text = "Name: Unknown"
            self.uuidLabel.text = "UUID:"
            self.notifyingLabel.text = "Notifying: ?"
            blankValueLabels()
        }
    }

    func blankValueLabels() {
        self.stringValueLabel.text = "String: "
        self.intValueLabel.text = "Int: "
        self.binaryValueLabel.text = "Binary: "
        self.hexValueLabel.text = "Hex: "
    }

    @objc func characteristicDataUpdated(notification: NSNotification) {
        guard let char: CBCharacteristic = notification.object as? CBCharacteristic else { print("No characteristic given"); return }
        if let c = self.characteristic {
            if char.UUID == c.UUID {
                self.characteristic = char
                updateCharLabels()
            }
        }
    }
}