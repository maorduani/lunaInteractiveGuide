//
//  StepsOrganizerTests.swift
//  LunaInteractiveGuideTests
//
//  Created by Maor Duani on 12/07/2023.
//

import XCTest
@testable import LunaInteractiveGuide

final class StepsOrganizerTests: XCTestCase {

    func testMovingToDevicePositionAfterWelcome() {
        let organizer = StepsOrganizer()
        organizer.moveToNextStep()
        XCTAssertEqual(organizer.currentStep, .devicePositioning)
    }
    
    func testMovingToFaceDetectionAfterDevicePosition() {
        let organizer = StepsOrganizer(currentStep: .devicePositioning)
        organizer.moveToNextStep()
        XCTAssertEqual(organizer.currentStep, .faceDetection)
    }
    
    func testShowDevicePositionWhenNotInRangeOnFaceDetection() {
        let motion = MockDeviceMotionProvider()
        let organizer = StepsOrganizer(motionProvider: motion, currentStep: .faceDetection)
        motion.devicePosition.send(DevicePosition.notInRange)
        XCTAssertEqual(organizer.currentStep, .devicePositioning)
    }
    
    func testShowDevicePositionWhenNotPositionedCorrectlyOnFaceDetection() {
        let motion = MockDeviceMotionProvider()
        let organizer = StepsOrganizer(motionProvider: motion, currentStep: .faceDetection)
        motion.devicePosition.send(DevicePosition.notPositionedCorrectly)
        XCTAssertEqual(organizer.currentStep, .devicePositioning)
    }
    
    func testStayOnFaceDetectionWhenNotInRangeAfterFaceDetected() {
        let motion = MockDeviceMotionProvider()
        let organizer = StepsOrganizer(motionProvider: motion, currentStep: .faceDetection)
        organizer.moveToNextStep()
        motion.devicePosition.send(DevicePosition.notInRange)
        XCTAssertEqual(organizer.currentStep, .faceDetection)
    }
    
    func testStayOnWelcomeWhenNotInRange() {
        let motion = MockDeviceMotionProvider()
        let organizer = StepsOrganizer(motionProvider: motion)
        motion.devicePosition.send(DevicePosition.notInRange)
        XCTAssertEqual(organizer.currentStep, .welcome)
    }
    
    func testStayOnSetupCompletedScreenWhenNotInRange() {
        let motion = MockDeviceMotionProvider()
        let organizer = StepsOrganizer(motionProvider: motion, currentStep: .completed)
        motion.devicePosition.send(DevicePosition.notInRange)
        XCTAssertEqual(organizer.currentStep, .completed)
    }
    
}
