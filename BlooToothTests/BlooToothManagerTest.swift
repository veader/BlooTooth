//
//  BlooToothManagerTest.swift
//  BlooTooth
//
//  Created by Shawn Veader on 9/30/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BlooTooth

class MockCBCentralManager: CBCentralManager {
    var expectation: XCTestExpectation?

    override func scanForPeripheralsWithServices(_serviceUUIDs: [CBUUID]?, options: [String : AnyObject]?) {
        expectation?.fulfill()
    }

    override func stopScan() {
        expectation?.fulfill()
    }
}

//class MockCBPeripheral: CBPeripheral {
//    override convenience init() {
//        self.init()
//    }
//}

class BlooToothManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testStartScan() {
        let mockManager = MockCBCentralManager()
        let expectation = expectationWithDescription("scanForPeripheralsWithServices")
        mockManager.expectation = expectation

        let btManager = BlooToothManager(manager: mockManager)
        btManager.startScan()

        waitForExpectationsWithTimeout(2.0) { (err) -> Void in
            print(err)
        }
    }

    func testStopScan() {
        let mockManager = MockCBCentralManager()
        let expectation = expectationWithDescription("stopScan")
        mockManager.expectation = expectation

        let btManager = BlooToothManager(manager: mockManager)
        btManager.stopScan()

        waitForExpectationsWithTimeout(2.0) { (err) -> Void in
            print(err)
        }
    }

//    func testConnectToPeripheral() {
//        let mockManager = MockCBCentralManager()
//        let expectation = expectationWithDescription("connectToPeripheral")
//        mockManager.expectation = expectation
//
//        let peripheral = MockCBPeripheral(isMock: true)
//
//        let btManager = BlooToothManager(manager: mockManager)
//        btManager.connectToPeripheral(peripheral)
//
//        waitForExpectationsWithTimeout(2.0) { (err) -> Void in
//            print(err)
//        }
//    }

}
