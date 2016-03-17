//
//  BlooToothManager.swift
//  BlooTooth
//
//  Created by Shawn Veader on 8/7/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: - BlooToothNotifications Enum
enum BlooToothNotifications: String {
    case PeripheralsUpdated = "PeripheralsUpdated"
    case PeripheralConnected = "PeripheralConnected"
    case PeripheralDisconnected = "PeripheralDisconnected"
    case PeripheralDataChanged = "PeripheralDataChanged"
    case PeripheralServicesUpdated = "PeripheralServicesUpdated"
    case ServiceCharacteristicsUpdated = "PeripheralCharacteristicsUpdated"
    case CharacteristicDescriptorsUpdated = "CharacteristicDescriptorsUpdated"
    case PeripheralInvestigationFinished = "PeripheralInvestigationFinished"
    case CharacteristicDataUpdated = "CharacteristicDataUpdated"
}

// extend CBService, CBCharacteristic and CBDescriptor
extension CBAttribute {

    func friendlyName() -> String? {
        // arduino 101 examples
        let gyroService = "7C27A67C-8E46-4AE6-8BC0-8A0865E7293F"
        let gyroXChar = "FF125EA1-E5B1-4323-9913-957826EB5059"
        let gyroYChar = "24676112-6E73-4159-90E1-147288DD11DD"
        let gyroZChar = "593DCD1B-749B-4697-8DC3-709EED98887B"

        switch self.UUID.UUIDString {
        case gyroService:
            return "Gyro"
        case gyroXChar:
            return "Gyro X"
        case gyroYChar:
            return "Gyro Y"
        case gyroZChar:
            return "Gyro Z"
        default:
            var outputString: String = ""
            print(self, separator: "", terminator: "", toStream: &outputString)
            let pieces = outputString.componentsSeparatedByString(", ")
            let uuidPieces = pieces.filter({ $0.hasPrefix("UUID") })
            if uuidPieces.count > 0 {
                let thisUUID = uuidPieces[0]
                let pieces = thisUUID.componentsSeparatedByString(" = ")
                return pieces[1].stringByReplacingOccurrencesOfString(">", withString: "")
            }
            return ""
        }
    }
}

class BlooToothManager : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    static let sharedInstance = BlooToothManager()

    let centralManager : CBCentralManager
    var peripherals : [CBPeripheral]
    var peripheralRSSIMap : [String : NSNumber]
    var peripheralsUnderInvestigation : [String : Int]

    // MARK: - Initialization
    convenience override init() {
        self.init(manager: CBCentralManager())
    }

    init(manager: CBCentralManager) {
        self.centralManager = manager
        self.peripherals = [CBPeripheral]()
        self.peripheralRSSIMap = [String: NSNumber]()
        self.peripheralsUnderInvestigation = [String: Int]()
        super.init()
        self.centralManager.delegate = self
    }

    // MARK: - Helper Methods
    func serviceNameFromUUID(uuid: String) -> String {
        var nameString: String = uuid
        if let serviceEnum = BlueToothKnownServices(rawValue: uuid) {
            if let serviceName = BlueToothKnownServicesLookup[serviceEnum] {
                nameString = serviceName
            }
        }
        return nameString
    }

    func notifyWithObject(notificationName: BlooToothNotifications, object: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName.rawValue, object: object)
    }

    func incrementInvestigationCallsForPeripheral(peripheral: CBPeripheral) {
        let uuid = peripheral.identifier.UUIDString
        let callCount = self.peripheralsUnderInvestigation[uuid] ?? 0
        self.peripheralsUnderInvestigation[uuid] = callCount + 1
        // print("After INC: \(self.peripheralsUnderInvestigation[uuid])")
    }

    func decrementInvestigationCallsForPeripheral(peripheral: CBPeripheral) {
        let uuid = peripheral.identifier.UUIDString
        let callCount = self.peripheralsUnderInvestigation[uuid] ?? 1
        self.peripheralsUnderInvestigation[uuid] = callCount - 1

        if callCount == 0 {
            notifyWithObject(.PeripheralInvestigationFinished, object: peripheral)
        }
        // print("After DEC: \(self.peripheralsUnderInvestigation[uuid])")
    }

    // MARK: - Scan Methods
    func startScan() {
        print("BT: starting scan...")
        self.peripherals = [CBPeripheral]() // clear out old peripherals
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

    func investigatePeripheral(peripheral: CBPeripheral) {
        print("BT: Investigating Peripheral: \(peripheral)")
        // 1. start at the top and get services
        //    a. for each service
        //        i.  look for included services (go back to a)
        //        ii. look for characteristics
        //            1. look for descriptors

        peripheral.delegate = self
        incrementInvestigationCallsForPeripheral(peripheral)
        discoverServicesForPeripheral(peripheral)
    }

    func discoverServicesForPeripheral(peripheral: CBPeripheral) {
        print("BT: Discovering services for peripheral")
        peripheral.delegate = self
        incrementInvestigationCallsForPeripheral(peripheral)
        peripheral.discoverServices(nil)
    }

    func discoverIncludedServicesForService(peripheral: CBPeripheral, service: CBService) {
        print("BT: Discovering included services for service")
        peripheral.delegate = self
        if let services = service.includedServices {
            for service in services {
                incrementInvestigationCallsForPeripheral(peripheral)
                peripheral.discoverIncludedServices(nil, forService: service)
            }
        }
    }

    func discoverCharacteristicsForServices(peripheral: CBPeripheral, services: [CBService]) {
        print("BT: Discovering characteristics of services")
        peripheral.delegate = self
        for service in services {
            incrementInvestigationCallsForPeripheral(peripheral)
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }

    func readValuesForCharacteristic(peripheral: CBPeripheral, characteristics: [CBCharacteristic]) {
        print("BT: Reading values of characteristics")
        peripheral.delegate = self
        for char in characteristics {
            if char.properties.contains(.Read) {
                incrementInvestigationCallsForPeripheral(peripheral)
                peripheral.readValueForCharacteristic(char)
            }
        }
    }

    func subscribeToUpdatesForCharacteristic(characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        peripheral.setNotifyValue(true, forCharacteristic: characteristic)
    }

    func unsubscribeToUpdatesForCharacteristic(characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        // guard characteristic.isNotifying == true else { return }
        peripheral.setNotifyValue(false, forCharacteristic: characteristic)
    }

    func discoverDescriptorsForCharacteristics(peripheral: CBPeripheral, characteristics: [CBCharacteristic]) {
        print("BT: Discovering desriptors for characteristics")
        peripheral.delegate = self
        for char in characteristics {
            incrementInvestigationCallsForPeripheral(peripheral)
            peripheral.discoverDescriptorsForCharacteristic(char)
        }
    }

    func readValuesForDescriptors(peripheral: CBPeripheral, descriptors: [CBDescriptor]) {
        print("BT: Reading values of descriptors")
        peripheral.delegate = self
        for desc in descriptors {
            incrementInvestigationCallsForPeripheral(peripheral)
            peripheral.readValueForDescriptor(desc)
        }
    }

    func rssiForPeripheralWithUUID(uuid : NSUUID) -> NSNumber? {
        return self.peripheralRSSIMap[uuid.UUIDString]
    }

    // MARK: - CBCentralManagerDelegate Methods
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("didConnectPeripheral:")
        print(peripheral)
        notifyWithObject(.PeripheralConnected, object: peripheral)
        investigatePeripheral(peripheral)
        decrementInvestigationCallsForPeripheral(peripheral)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didDisconnectPeripheral:error:")
        print(peripheral)
        print(error)
        print(error?.description)
        // TODO: clean up any investigation artifacts
        notifyWithObject(.PeripheralDisconnected, object: peripheral)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("didDiscoverPeripheral:")

        if !self.peripherals.contains(peripheral) {
            print("Adding... \(peripheral)")
            print(advertisementData)
            self.peripherals.append(peripheral)
            self.peripheralRSSIMap[peripheral.identifier.UUIDString] = RSSI
        }
        notifyWithObject(.PeripheralsUpdated, object: self.peripherals)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didFailToConnectPeripheral:")
        print(peripheral)
        print(error)
        // TODO: clean up any investigation artifacts
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
        print("peripheral:didDiscoverCharacteristicsForService:")
        notifyWithObject(.ServiceCharacteristicsUpdated, object: service)

        if let characteristics = service.characteristics {
            discoverDescriptorsForCharacteristics(peripheral, characteristics: characteristics)
            readValuesForCharacteristic(peripheral, characteristics: characteristics)
        }
        decrementInvestigationCallsForPeripheral(peripheral)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("peripheral:didDiscoverDescriptorsForCharacteristic:")
        notifyWithObject(.CharacteristicDescriptorsUpdated, object: characteristic)

        if let desciptors = characteristic.descriptors {
            readValuesForDescriptors(peripheral, descriptors: desciptors)
        }
        decrementInvestigationCallsForPeripheral(peripheral)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
        print("peripheral:didDiscoverIncludedServicesForService:")
        if let services = service.includedServices {
            // TODO: do we look for included services of this included service? (how far does it go?)
            discoverCharacteristicsForServices(peripheral, services: services)
        }
        decrementInvestigationCallsForPeripheral(peripheral)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("peripheral:didDiscoverServices:")
        notifyWithObject(.PeripheralServicesUpdated, object: peripheral)
        if let services = peripheral.services {
            discoverCharacteristicsForServices(peripheral, services: services)
            for service in services {
                discoverIncludedServicesForService(peripheral, service: service)
            }
        }
        decrementInvestigationCallsForPeripheral(peripheral)
    }
    
    func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("peripheral:didModifyServices:")
        notifyWithObject(.PeripheralServicesUpdated, object: peripheral)
    }
    
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        print("peripheral:didReadRSSI:")
        self.peripheralRSSIMap[peripheral.identifier.UUIDString] = RSSI
        notifyWithObject(.PeripheralDataChanged, object: peripheral)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("peripheral:didUpdateNotificationStateForCharacteristic:")
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("peripheral:didUpdateValueForCharacteristic:")
        print(characteristic)
        notifyWithObject(.CharacteristicDataUpdated, object: characteristic)
        decrementInvestigationCallsForPeripheral(peripheral)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        print("peripheral:didUpdateValueForDescriptor:")
        print(descriptor)
        // TODO: notify, etc
        decrementInvestigationCallsForPeripheral(peripheral)
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("peripheral:didWriteValueForCharacteristic:")
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        print("peripheral:didWriteValueForDescriptor:")
    }
    
    func peripheralDidUpdateName(peripheral: CBPeripheral) {
        print("peripheralDidUpdateName:")
        print(peripheral)
        notifyWithObject(.PeripheralDataChanged, object: self.peripherals)
    }
    
    func peripheralDidUpdateRSSI(peripheral: CBPeripheral, error: NSError?) {
        print("peripheralDidUpdateRSSI:")
        notifyWithObject(.PeripheralDataChanged, object: self.peripherals)
    }
}