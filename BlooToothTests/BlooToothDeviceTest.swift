//
//  BlooToothDeviceTest.swift
//  BlooTooth
//
//  Created by Shawn Veader on 9/29/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BlooTooth

struct BTTestPeripheral {
    var name: String?
    var identifier: NSUUID?
}

extension CBPeripheral {
    func setName(name: String?) {
        self.setValue(name, forKey: "name")
    }

    func setIdentifier(identifier: NSUUID?) {
        self.setValue(identifier, forKey: "identifier")
    }
}

class BlooToothDeviceTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testDescriptionMethod() {
        let identifier = NSUUID.init()

        let device = BlooToothDevice(name: "Foo", identifier: identifier, peripheral: nil, rssi: nil)
        XCTAssertEqual(device.description, "Foo - \(identifier.UUIDString)")
    }

    /*
    func xtestNameAndIdentifierChangesWhenTouched() {
        let identifier = NSUUID.init()
        let identifier2 = NSUUID.init()

//        let peripheral = CBPeripheral()
//
//
//        var device = BlooToothDevice(name: "Foo", identifier: identifier, peripheral: peripheral, rssi: nil)
//        XCTAssertEqual(device.description, "Foo - \(identifier.UUIDString)")
//
//        device.touch()
//        XCTAssertEqual(device.description, "Bar - \(identifier2.UUIDString)")
    }
*/

    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    */
}
