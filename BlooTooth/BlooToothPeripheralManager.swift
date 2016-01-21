//
//  BlooToothPeripheralManager.swift
//  BlooTooth
//
//  Created by Shawn Veader on 10/8/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import Foundation
import CoreBluetooth


class BlooToothPeripheralManager : NSObject, CBPeripheralManagerDelegate {
    static let sharedInstance = BlooToothPeripheralManager()

    let peripheralManager : CBPeripheralManager

    // MARK: - Initialization
    override init() {
        self.peripheralManager = CBPeripheralManager()
        super.init()
        self.peripheralManager.delegate = self
    }

    func setupServices() {
        // self.peripheralManager.addService(service: CBMutableService)
        // self.peripheralManager.removeAllServices()
        // self.peripheralManager.removeService(service: CBMutableService)
    }

    func startAdvertising() {
        // self.peripheralManager.startAdvertising(advertisementData: [String : AnyObject]?)
        //  CBAdvertisementDataLocalNameKey and CBAdvertisementDataServiceUUIDsKey

        // self.peripheralManager.stopAdvertising()
    }

    func sendData(message: String) {
        // length of message vs maximumUpdateValueLength of the given central will mean chunking needs to happen
        // self.peripheralManager.updateValue(<#T##value: NSData##NSData#>, forCharacteristic: <#T##CBMutableCharacteristic#>, onSubscribedCentrals: <#T##[CBCentral]?#>)
        // send "EOM" after complete
    }

    // MARK: - CBPeripheralManagerDelegate Methods
    func peripheralManagerDidUpdateState(_peripheral: CBPeripheralManager) {
        print("peripheralManagerDidUpdateState:")
    }


    func peripheralManager(_peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject]) {
        print("peripheralManager:willRestoreState:")
    }

    func peripheralManager(_peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        print("peripheralManager:didAddService:")
    }

    func peripheralManagerDidStartAdvertising(_peripheral: CBPeripheralManager, error: NSError?) {
        print("peripheralManagerDidStartAdvertising:")
    }

    func peripheralManager(_peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print("peripheralManager:central:didSubscribeToCharacteristic:")
    }

    func peripheralManager(_peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        print("peripheralManager:central:didUnsubscribeFromCharacteristic:")
    }

    func peripheralManagerIsReadyToUpdateSubscribers(_peripheral: CBPeripheralManager) {
        print("peripheralManagerIsReadyToUpdateSubscribers:")
    }

    func peripheralManager(_peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        print("peripheralManager:didReceiveReadRequest:")
    }

    func peripheralManager(_peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        print("peripheralManager:didReceiveWriteRequests:")
    }

}