//
//  DevicePositionViewModelTests.swift
//  DevicePositionViewModelTests
//
//  Created by Maor Duani on 08/07/2023.
//

import Combine
import XCTest
@testable import LunaInteractiveGuide

final class DevicePositionViewModelTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()

    func testInstructionsIsVisibleWhenNotInRange() {
        let viewModel = DevicePositionViewModel.notInRage
        XCTAssertTrue(viewModel.showInstructions)
    }
    
    func testShowProgressBarWhenInRange() {
        let viewModel = DevicePositionViewModel.inRange
        XCTAssertTrue(viewModel.showProgressBar)
    }
    
    func testShowContinueButtonOnlyAfterTimerFinished() {
        let viewModel = DevicePositionViewModel.inRange
        XCTAssertFalse(viewModel.showContinueButton)
        
        let expectation = expectation(description: "Show continue button bool should be true")
        
        viewModel.$showContinueButton
            .dropFirst()
            .sink { show in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        XCTWaiter().wait(for: [expectation], timeout: 4)
        XCTAssertTrue(viewModel.showContinueButton)
    }
    
    func testShowProgressBarFalseAfterTimerFinished() {
        let viewModel = DevicePositionViewModel.inRange
        XCTAssertTrue(viewModel.showProgressBar)
        
        let expectation = expectation(description: "Show progress bar bool should be false")
        
        viewModel.$showProgressBar
            .dropFirst()
            .sink { show in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertFalse(viewModel.showProgressBar)
    }
    
    func testProgressBarRemovedWhenNotInRangeOccures() {
        let subject = CurrentValueSubject<DevicePosition, Never>(DevicePosition.inRange)
        let viewModel = DevicePositionViewModel(model: subject)
        XCTAssertTrue(viewModel.showProgressBar)
        
        subject.value = DevicePosition.notInRange
        let expectation = expectation(description: "Show progress bar bool should be false")
        
        viewModel.$showProgressBar
            .dropFirst()
            .sink { show in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        XCTWaiter().wait(for: [expectation], timeout: 2)
        XCTAssertFalse(viewModel.showProgressBar)
    }
    
    func testContinueButtonRemovedWhenNotInRangeOccures() {
        let subject = CurrentValueSubject<DevicePosition, Never>(DevicePosition.inRange)
        let viewModel = DevicePositionViewModel(model: subject, timer: ImmediateReturnTimer())
        XCTAssertTrue(viewModel.showContinueButton)
        
        subject.value = DevicePosition.notInRange
        
        XCTAssertFalse(viewModel.showContinueButton)
    }
    
    func testShowDeviceNotVerticallyMessage() {
        let viewModel = DevicePositionViewModel.notPositionedCorrectly
        XCTAssertTrue(viewModel.showDeviceNotVerticalError)
    }
}
