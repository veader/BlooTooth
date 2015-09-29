//
//  BlooToothManager.swift
//  BlooTooth
//
//  Created by Shawn Veader on 8/7/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BlooToothKnownServices: String {
    case ServiceDeviceInfo = "180A"
    case ServiceBattery = "180F"
}

// MARK: - BlooToothNotifications Enum
enum BlooToothNotifications: String {
    case PeripheralsUpdated = "PeripheralsUpdated"
    case PeripheralConnected = "PeripheralConnected"
    case PeripheralDisconnected = "PeripheralDisconnected"
    case PeripheralDataChanged = "PeripheralDataChanged"
    case PeripheralServicesUpdated = "PeripheralServicesUpdated"
}

// MARK: - CBPeripheral Extension
extension CBPeripheral {
}


class BlooToothManager : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    static let sharedInstance = BlooToothManager()

    let centralManager : CBCentralManager
    var peripherals : [CBPeripheral]

    // MARK: - Initialization
    override init() {
        self.centralManager = CBCentralManager()
        self.peripherals = [CBPeripheral]()
        super.init()
        self.centralManager.delegate = self
    }

    // MARK: - Scan Methods
    func startScan() {
        print("BT: starting scan...")
        self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func stopScan() {
        print("BT: stop scan.")
        self.centralManager.stopScan()
    }

    // MARK: - Connection Methods
    func connectToPeripheral(peripheral: CBPeripheral) {
        // TODO: what do the options do?
        print("BT: Connecting to peripheral \(peripheral)")
        self.centralManager.connectPeripheral(peripheral, options: nil)
    }

    func disconnectFromPeripheral(peripheral: CBPeripheral) {
        print("BT: Disconnecting from peripheral \(peripheral)")
        self.centralManager.cancelPeripheralConnection(peripheral)
    }

    func discoverServicesForPeripheral(peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    // MARK: - CBCentralManagerDelegate Methods
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("didConnectPeripheral:")
        print(peripheral)
        NSNotificationCenter.defaultCenter().postNotificationName(BlooToothNotifications.PeripheralConnected.rawValue, object: peripheral)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didDisconnectPeripheral:error:")
        print(peripheral)
        print(error)
        print(error?.description)
        NSNotificationCenter.defaultCenter().postNotificationName(BlooToothNotifications.PeripheralDisconnected.rawValue, object: peripheral)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("didDiscoverPeripheral:")

        if !self.peripherals.contains(peripheral) {
            print("Adding... \(peripheral)")
            print(advertisementData)
            self.peripherals.append(peripheral)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(BlooToothNotifications.PeripheralsUpdated.rawValue, object: self.peripherals)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didFailToConnectPeripheral:")
        print(peripheral)
        print(error)
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        print("willRestoreState:")
        print(dict)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("centralManagerDidUpdateState:")
        print(central)
    }

    // MARK: - CBPeripheralDelegate Methods
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        //
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        //
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
        //
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("peripheral:didDiscoverServices:")
        NSNotificationCenter.defaultCenter().postNotificationName(BlooToothNotifications.PeripheralServicesUpdated.rawValue, object: peripheral)
    }
    
    func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("peripheral:didModifyServices:")
        NSNotificationCenter.defaultCenter().postNotificationName(BlooToothNotifications.PeripheralServicesUpdated.rawValue, object: peripheral)
    }
    
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        print("peripheral:didReadRSSI:")
        NSNotificationCenter.defaultCenter().postNotificationName(BlooToothNotifications.PeripheralDataChanged.rawValue, object: peripheral)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        //
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        //
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        //
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        //
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        //
    }
    
    func peripheralDidUpdateName(peripheral: CBPeripheral) {
        print("peripheralDidUpdateName:")
        NSNotificationCenter.defaultCenter().postNotificationName(BlooToothNotifications.PeripheralDataChanged.rawValue, object: self.peripherals)
    }
    
    func peripheralDidUpdateRSSI(peripheral: CBPeripheral, error: NSError?) {
        print("peripheralDidUpdateRSSI:")
        NSNotificationCenter.defaultCenter().postNotificationName(BlooToothNotifications.PeripheralDataChanged.rawValue, object: self.peripherals)
    }
}