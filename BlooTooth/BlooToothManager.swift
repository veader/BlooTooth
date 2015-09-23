//
//  BlooToothManager.swift
//  BlooTooth
//
//  Created by Shawn Veader on 8/7/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: BlooToothManagerDelegate Protocol Definition
protocol BlooToothManagerDelegate {
    func managerDidUpdateDevices(devices : [BlooToothDevice])
    func managerDidConnectToDevice(device: BlooToothDevice)
    func managerDidDiscoverServiceForDevice(device: BlooToothDevice)
    func managerDidDisconnectFromDevice(device: BlooToothDevice)
}


class BlooToothManager : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    let centralManager : CBCentralManager
    var delegate : BlooToothManagerDelegate?
    var devices : [BlooToothDevice]

    var connectPeripheral : CBPeripheral?

    
    // MARK: Initialization
    override init() {
        self.centralManager = CBCentralManager()
        self.devices = [BlooToothDevice]()
        super.init()
        setupCentralManagerDelegate()
    }

    init(delegate : BlooToothManagerDelegate?) {
        self.delegate = delegate
        self.centralManager = CBCentralManager()
        self.devices = [BlooToothDevice]()
        super.init()
        setupCentralManagerDelegate()
    }
    
    init(delegate : BlooToothManagerDelegate?, centralManager : CBCentralManager?) {
        self.delegate = delegate
        self.centralManager = centralManager ?? CBCentralManager()
        self.devices = [BlooToothDevice]()
        super.init()
        setupCentralManagerDelegate()
    }

    func setupCentralManagerDelegate() {
        self.centralManager.delegate = self
    }
    
    
    // MARK: Methods
    func startScan() {
        print("BT: starting scan...")
        self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func stopScan() {
        print("BT: stop scan.")
        self.centralManager.stopScan()
    }

    func deviceFromPeripheral(peripheral: CBPeripheral, rssi: NSNumber) -> BlooToothDevice {
        if var d = findDeviceForPeripheral(peripheral) {
            d.touch() // update based on peripheral
            return d
        } else {
            return BlooToothDevice(name: peripheral.name, identifier: peripheral.identifier, peripheral: peripheral, rssi: rssi)
        }
    }

    func findDeviceForPeripheral(peripheral: CBPeripheral) -> BlooToothDevice? {
        if let i = self.devices.indexOf({
            (device: BlooToothDevice) -> Bool in
            return device.peripheral == peripheral
        }) {
            return self.devices[i]
        }
        return nil
    }

    func connectToDevice(device: BlooToothDevice) {
        // TODO: what do the options do?
        if let p = device.peripheral {
            print("BT: Connecting to device \(device)")
            self.centralManager.connectPeripheral(p, options: nil)
        }
    }

    func disconnectFromDevice(device: BlooToothDevice) {
        if let p = device.peripheral {
            print("BT: Disconnecting from device \(device)")
            self.centralManager.cancelPeripheralConnection(p)
        }
    }

    func discoverServicesForDevice(device: BlooToothDevice) {
        if let p = device.peripheral {
            p.delegate = self
            p.discoverServices(nil)
        }
    }

    // MARK: CBCentralManagerDelegate Methods
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("didConnectPeripheral:")
        print(peripheral)
        var d = deviceFromPeripheral(peripheral, rssi: 0)
        d.touch()
        self.delegate?.managerDidConnectToDevice(d)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didDisconnectPeripheral:error:")
        print(peripheral)
        print(error)
        print(error?.description)
        var d = deviceFromPeripheral(peripheral, rssi: 0)
        d.touch()
        self.delegate?.managerDidDisconnectFromDevice(d)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("didDiscoverPeripheral:")

        let device = deviceFromPeripheral(peripheral, rssi: RSSI)
        print("Peripheral:")
        print(peripheral)
        print("Advertisement:")
        print(advertisementData)

        if !self.devices.contains(device) {
            NSLog("Adding \(device)...")
            devices.append(device)
        }
        self.delegate?.managerDidUpdateDevices(self.devices)
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

    // MARK: CBPeripheralDelegate Methods
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
        let d = deviceFromPeripheral(peripheral, rssi: 0)
        self.delegate?.managerDidDiscoverServiceForDevice(d)
    }
    
    func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        //
    }
    
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        //
        print("peripheral:didReadRSSI:")
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
        //
        print("peripheralDidUpdateName:")
    }
    
    func peripheralDidUpdateRSSI(peripheral: CBPeripheral, error: NSError?) {
        //
        print("peripheralDidUpdateRSSI:")
    }
}