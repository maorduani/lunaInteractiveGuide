//
//  DevicePositionManager.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 09/07/2023.
//

import Foundation
import CoreMotion
import Combine

protocol DevicePositionSupplying {
    var totalDegrees: Double { get }
    var pitchAcceptableRange: ClosedRange<Double> { get }
    var rollAcceptableRange: ClosedRange<Double> { get }
    var pitchDegreesPublisher: AnyPublisher<Double, Never> { get }
    var rollDegreesPublisher: AnyPublisher<Double, Never> { get }
    var onDeviceOutOfRane: (() -> Void)? { get set }
}

class DevicePositionSupplierMock: DevicePositionSupplying {
    let totalDegrees: Double = 180
    let pitchAcceptableRange: ClosedRange<Double> = 70...110
    let rollAcceptableRange: ClosedRange<Double> = -5...5
    
    private let pitchDegrees: Double
    private let rollDegrees: Double
    
    init(pitchDegrees: Double = 0, rollDegrees: Double = 0) {
        self.pitchDegrees = pitchDegrees
        self.rollDegrees = rollDegrees
    }
    
    var pitchDegreesPublisher: AnyPublisher<Double, Never> {
        Just(pitchDegrees).map { $0 }
        .eraseToAnyPublisher()
    }
    
    var rollDegreesPublisher: AnyPublisher<Double, Never> {
        Just(rollDegrees).map { $0 }
        .eraseToAnyPublisher()
    }
    
    var onDeviceOutOfRane: (() -> Void)?
}

class DevicePositionProvider: DevicePositionSupplying {
    
    private var cancellables = Set<AnyCancellable>()
    private let motionManager = CMMotionManager()
    @Published private var pitchDegrees: Double?
    @Published private var rollDegrees: Double?
    private(set) var movement: Double = .zero
    
    let totalDegrees: Double = 180
    let pitchAcceptableRange: ClosedRange<Double> = 70...110
    let rollAcceptableRange: ClosedRange<Double> = -5...5
    var pitchDegreesPublisher: AnyPublisher<Double, Never> {
        $pitchDegrees.compactMap { $0 }
        .eraseToAnyPublisher()
    }
    
    var rollDegreesPublisher: AnyPublisher<Double, Never> {
        $pitchDegrees.compactMap { $0 }
        .eraseToAnyPublisher()
    }
    
    var onDeviceOutOfRane: (() -> Void)?
    
    init() {
        startMotionUpdates()
        notifiyWhenOutOfRange()
    }
    
    private func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let motion = motion else { return }
                self?.hanleMotionUpdate(motion)
            }
        }
    }
    
    private func hanleMotionUpdate(_ motion: CMDeviceMotion) {
        let quaternion = motion.attitude.quaternion
        let pitchRadians = atan2(2 * (quaternion.x * quaternion.w + quaternion.y * quaternion.z), 1 - 2 * quaternion.x * quaternion.x - 2 * quaternion.z * quaternion.z)
        pitchDegrees = degreesFrom(pitchRadians)
        rollDegrees = degreesFrom(motion.attitude.roll)
        movement = abs(round(motion.userAcceleration.x * 100))
    }
    
    private func notifiyWhenOutOfRange() {
        Publishers.CombineLatest(
            pitchDegreesPublisher,
            rollDegreesPublisher
        )
        .receive(on: RunLoop.main)
        .map {
            return ($0.0, $0.1)
        }
        .sink { [weak self] pitch, roll in
            guard let self,
                  !pitchAcceptableRange.contains(pitch),
                  !rollAcceptableRange.contains(roll) else {
                return
            }
            onDeviceOutOfRane?()
        }
        .store(in: &cancellables)
    }
    
    private func degreesFrom(_ radians: Double) -> Double {
        return radians * 180 / .pi
    }
}
