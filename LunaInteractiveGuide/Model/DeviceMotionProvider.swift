//
//  DevicePositionManager.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 09/07/2023.
//

import Foundation
import CoreMotion
import Combine

protocol DeviceMotionProviding {
    var devicePositionPublisher: AnyPublisher<DevicePosition, Never> { get }
    
    func start()
    func stop()
}

class DeviceMotionProvider: DeviceMotionProviding {
    
    private var cancellables = Set<AnyCancellable>()
    private let motionManager = CMMotionManager()
    private let updateInterval: Double = 0.2
    private let pitchDegrees = PassthroughSubject<Double, Never>()
    private let xAcceleration = PassthroughSubject<Double, Never>()
    
    var devicePositionPublisher: AnyPublisher<DevicePosition, Never> {
        Publishers.Zip(pitchDegrees, xAcceleration)
            .map { pitch, accelaration in
                return DevicePosition(verticalDegrees: pitch, xAcceleration: accelaration)
            }
            .eraseToAnyPublisher()
    }
    
    func start() {
        if motionManager.isDeviceMotionAvailable,
           !motionManager.isDeviceMotionActive {
            motionManager.deviceMotionUpdateInterval = updateInterval
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                self?.hanleMotionUpdate(motion)
            }
            
            motionManager.accelerometerUpdateInterval = updateInterval
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data , error in
                guard let data else { return }
                self?.xAcceleration.send(data.acceleration.x)
            }
        }
    }
    
    func stop() {
        if motionManager.isDeviceMotionAvailable,
           motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    private func hanleMotionUpdate(_ motion: CMDeviceMotion?) {
        guard let motion else { return }
        let quaternion = motion.attitude.quaternion
        let pitchRadians = atan2(2 * (quaternion.x * quaternion.w + quaternion.y * quaternion.z),
                                 1 - 2 * quaternion.x * quaternion.x - 2 * quaternion.z * quaternion.z)
        let degrees = degreesFrom(pitchRadians).rounded()
        pitchDegrees.send(degrees)
    }
    
    private func degreesFrom(_ radians: Double) -> Double {
        return radians * 180 / .pi
    }
}
