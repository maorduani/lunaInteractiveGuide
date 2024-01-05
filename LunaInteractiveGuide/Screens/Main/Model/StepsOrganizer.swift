//
//  StepsOrchestrator.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 10/07/2023.
//

import Foundation
import Combine

class StepsOrganizer: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    private let motionProvider: DeviceMotionProviding
    private var faceDetected = false
    @Published private(set) var currentStep: CurrentStep
    private var motionDegrees: CurrentValueSubject<DevicePosition, Never>?
    @Published var devicePositionViewModel: DevicePositionViewModel?
    
    init(motionProvider: DeviceMotionProviding = DeviceMotionProvider(), currentStep: CurrentStep = .welcome) {
        self.motionProvider = motionProvider
        self.currentStep = currentStep
        subscribeToMotionUpdates()
    }
    
    func moveToNextStep() {
        switch currentStep {
        case .welcome:
            motionProvider.start()
            currentStep = .devicePositioning
        case .devicePositioning:
            devicePositionViewModel = nil
            currentStep = .faceDetection
        case .faceDetection:
            if !faceDetected {
                faceDetected = true
            } else {
                currentStep = .completed
                motionProvider.stop()
            }
        default: break
        }
    }
    
    private func subscribeToMotionUpdates() {
        motionProvider.devicePositionPublisher
            .sink { [weak self] in
                self?.handleUpdated($0)
            }
            .store(in: &cancellables)
    }
    
    private func handleUpdated(_ model: DevicePosition) {
        if motionDegrees == nil {
            motionDegrees = CurrentValueSubject(model)
        } else {
            motionDegrees?.send(model)
        }
        guard shouldPresentScreen(for: model) else { return }
        currentStep = .devicePositioning
        devicePositionViewModel = DevicePositionViewModel(model: motionDegrees!)
    }
    
    private func shouldPresentScreen(for devicePosition: DevicePosition) -> Bool {
        let ableToShow = devicePositionViewModel == nil
        let stepWithStateFitCondition = !devicePosition.isInRange && currentStep == .faceDetection && !faceDetected
        let shouldDisplay = stepWithStateFitCondition || currentStep == .devicePositioning
        return ableToShow && shouldDisplay
    }
}
