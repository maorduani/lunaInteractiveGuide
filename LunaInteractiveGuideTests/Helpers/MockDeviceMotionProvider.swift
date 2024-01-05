//
//  MockDeviceMotionProvider.swift
//  LunaInteractiveGuideTests
//
//  Created by Maor Duani on 12/07/2023.
//

import Foundation
import Combine
@testable import LunaInteractiveGuide

class MockDeviceMotionProvider: DeviceMotionProviding {
    
    var devicePositionPublisher: AnyPublisher<LunaInteractiveGuide.DevicePosition, Never> {
        devicePosition
            .eraseToAnyPublisher()
    }
    
    let devicePosition = PassthroughSubject<DevicePosition, Never>()
        
    func start() {}
    func stop() {}
}
