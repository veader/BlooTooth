//
//  BlooToothDevice.swift
//  BlooTooth
//
//  Created by Shawn Veader on 9/22/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BlooToothDevice : Equatable, CustomStringConvertible {
    var name: String?
    var identifier: NSUUID
    var peripheral: CBPeripheral?
    var rssi: NSNumber?

    var description: String {
        var desc: String = name ?? ""
        if !desc.isEmpty {
            desc.appendContentsOf(" - ")
        }
        desc.appendContentsOf(identifier.UUIDString)
        if rssi != nil {
            desc.appendContentsOf(" - \(rssi!) db")
        }
        return desc
        // return "\(name) - \(identifier)"
        // return " ".join([name!, identifier])
    }

    mutating func touch() {
        if let p = peripheral {
            name = p.name
            identifier = p.identifier
            // rssi = p.RSSI
        }
    }
}

func ==(lhs: BlooToothDevice, rhs: BlooToothDevice) -> Bool {
    return (lhs.name == rhs.name) && (lhs.identifier == rhs.identifier)
}