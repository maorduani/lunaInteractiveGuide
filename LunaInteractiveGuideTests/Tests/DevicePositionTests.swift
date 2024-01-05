//
//  DevicePositionTests.swift
//  LunaInteractiveGuideTests
//
//  Created by Maor Duani on 12/07/2023.
//

import XCTest
@testable import LunaInteractiveGuide

final class DevicePositionTests: XCTestCase {
  
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testInRangeWhen80Degrees() {
        let model = DevicePosition.inRange
        XCTAssertTrue(model.isInRange)
    }
    
    func testNotInRangeWhen40Degrees() {
        let model = DevicePosition.notInRange
        XCTAssertFalse(model.isInRange)
    }
    
    func testNotInRangeWhenAccelerationIs1() {
        let degrees = 70.0
        let model = DevicePosition(verticalDegrees: degrees, xAcceleration: 1)
        XCTAssertFalse(model.isInRange)
    }
    
    func testNotPositionedCorrectlyWhenAccelerationIs1() {
        let degrees = 70.0
        let model = DevicePosition(verticalDegrees: degrees, xAcceleration: 1)
        XCTAssertFalse(model.isPositionedCorrectly)
    }
    
    func testNotPositionedCorrectlyWhenDegreesMinus() {
        let degrees = -70.0
        let model = DevicePosition(verticalDegrees: degrees, xAcceleration: 0)
        XCTAssertFalse(model.isPositionedCorrectly)
    }
        
    func testOffsetPercentage1When180Degrees() {
        let degrees = 180.0
        let model = DevicePosition(verticalDegrees: degrees, xAcceleration: 0)
        XCTAssertEqual(model.offsetPercentage, 1)
    }
}
