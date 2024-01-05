//
//  DevicePositionManager.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 09/07/2023.
//

import Foundation
import CoreMotion
import Combine

protocol DevicePositionSupplying: ObservableObject {
    var pitchDegrees: CGFloat? { get }
    var rollDegrees: CGFloat? { get }
    var onOutOfDegreesRange: (() -> Void)? { get }
}

class DevicePositionSupplier: DevicePositionSupplying {
    
    private var cancellables = Set<AnyCancellable>()
    private let motionManager = CMMotionManager()
    static let shared = DevicePositionSupplier()
    @Published private(set) var pitchDegrees: CGFloat?
    @Published private(set) var rollDegrees: CGFloat?
    @Published private(set) var movement: Double = .zero
    
    var onOutOfDegreesRange: (() -> Void)?
    
    private init() {
        startMotionUpdates()
        observeCurrentDegreesRange()
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
    
    private func observeCurrentDegreesRange() {
        Publishers.CombineLatest($pitchDegrees, $rollDegrees)
            .map { pitch, roll -> Bool in
                guard let pitch,
                      let roll else { return false }
                return Constants.pitchAcceptableRange.contains(pitch) && Constants.rollAcceptableRange.contains(roll)
            }
            .sink { [weak self] isInRange in
                if !isInRange {
                    self?.onOutOfDegreesRange?()
                }
            }
            .store(in: &cancellables)
    }
    
    private func hanleMotionUpdate(_ motion: CMDeviceMotion) {
        let quaternion = motion.attitude.quaternion
        let pitchRadians = atan2(2 * (quaternion.x * quaternion.w + quaternion.y * quaternion.z), 1 - 2 * quaternion.x * quaternion.x - 2 * quaternion.z * quaternion.z)
        pitchDegrees = degreesFrom(pitchRadians)
        rollDegrees = degreesFrom(motion.attitude.roll)
        movement = abs(round(motion.userAcceleration.x * 100))
    }
    
    private func degreesFrom(_ radians: Double) -> Double {
        return radians * 180 / .pi
    }
    
    struct Constants {
        static let pitchAcceptableRange: ClosedRange<CGFloat> = 70...110
        static let rollAcceptableRange: ClosedRange<CGFloat> = -5...5
        static let maxDegrees: CGFloat = 180
    }
}
