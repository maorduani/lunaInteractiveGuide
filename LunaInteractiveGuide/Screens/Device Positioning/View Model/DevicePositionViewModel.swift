//
//  DevicePositionViewModel.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 11/07/2023.
//

import Foundation
import Combine

class DevicePositionViewModel: ObservableObject, Identifiable {
    
    private var modelSubscription: AnyCancellable?
    private let timer: CountingDownTimer
    let id = UUID()
    private var offsetPercentage: CGFloat = 0
    private(set) var isInRange = false
    @Published var showProgressBar = false
    @Published var showContinueButton = false
    @Published var showInstructions = false
    @Published var showDeviceNotVerticalError = false
    
    init(model: CurrentValueSubject<DevicePosition, Never>, timer: CountingDownTimer = CountDownTimer(seconds: 3)) {
        self.timer = timer
        self.modelSubscription = model.sink { [weak self] in
            self?.updateProperties(by: $0)
        }
    }
        
    /// Values between -0.5 to 0.5, so 0.75 will actually be 0.25
    /// Represent distance from the center point, but include if
    /// above or biond it
    var offsetFromCenter: CGFloat {
        return offsetPercentage - 0.5
    }
    
    /// Value between 0 to 0.5 only, so it creates a mirror image
    /// for values in a way that 80 degrees is the same as 100 and
    /// 0.4 the same as 0.6 (value wise)
    var circularHalfPercent: CGFloat {
        if offsetPercentage > 0.5 {
            return 1 - offsetPercentage
        }
        return offsetPercentage
    }
}

// MARK: - Private 
extension DevicePositionViewModel {
    
    private func updateProperties(by model: DevicePosition) {
        isInRange = model.isInRange
        offsetPercentage = model.offsetPercentage
        if model.isPositionedCorrectly {
            if isInRange {
                onInRange()
            } else {
                onOutOfRange()
            }
            showDeviceNotVerticalError = false
        } else {
            showDeviceNotVerticalError = true
            onOutOfRange()
        }
    }
        
    private var shouldStartTimer: Bool {
        return !showContinueButton && !showProgressBar
    }
    
    private func onInRange() {
        if shouldStartTimer {
            timer.start { [weak self] in
                self?.showContinueButton = true
                self?.showProgressBar = false
            }
            showProgressBar = true
        }
        showInstructions = false
    }
    
    private func onOutOfRange() {
        isInRange = false
        timer.cancel()
        showInstructions = !showDeviceNotVerticalError
        showProgressBar = false
        showContinueButton = false
    }
}
