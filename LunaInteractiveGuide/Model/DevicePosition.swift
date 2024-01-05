//
//  DevicePosition.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 08/07/2023.
//

import Foundation

struct DevicePosition: Equatable {
    
    private let maxDegrees: Double = 180
    private let acceptableDegrees: ClosedRange<Double> = 70...110
    let isPositionedCorrectly: Bool
    let isInRange: Bool
    
    /// Represent regular distance from 0, 0.75 will be 135 degrees
    /// or 3/4 of a view if used in coordinate system
    let offsetPercentage: CGFloat
    
    init(verticalDegrees: Double, xAcceleration: Double) {
        self.isPositionedCorrectly = abs(xAcceleration) < 0.2 && verticalDegrees >= 0
        self.isInRange = acceptableDegrees.contains(verticalDegrees) && self.isPositionedCorrectly
        self.offsetPercentage = verticalDegrees / maxDegrees
    }
}
