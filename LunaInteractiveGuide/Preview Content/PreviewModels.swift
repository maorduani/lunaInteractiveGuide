//
//  PreviewModels.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 10/07/2023.
//

import Foundation
import Combine

extension DevicePosition {
    static var notInRange: DevicePosition {
        return DevicePosition(verticalDegrees: 40, xAcceleration: 0)
    }
    
    static var inRange: DevicePosition {
        return DevicePosition(verticalDegrees: 90, xAcceleration: 0)
    }
    
    static var notPositionedCorrectly: DevicePosition {
        return DevicePosition(verticalDegrees: 90, xAcceleration: 1)
    }
}

extension DevicePositionViewModel {
    
    static var notInRage: DevicePositionViewModel {
        return DevicePositionViewModel(model: CurrentValueSubject<DevicePosition, Never>(DevicePosition.notInRange))
    }
    
    static var inRange: DevicePositionViewModel {
        return DevicePositionViewModel(model: CurrentValueSubject<DevicePosition, Never>(DevicePosition.inRange))
    }
    
    static var notPositionedCorrectly: DevicePositionViewModel {
        return DevicePositionViewModel(model: CurrentValueSubject<DevicePosition, Never>(DevicePosition.notPositionedCorrectly))
    }
}
