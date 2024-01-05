//
//  ImmediateReturnTimer.swift
//  LunaInteractiveGuideTests
//
//  Created by Maor Duani on 12/07/2023.
//

import Foundation
@testable import LunaInteractiveGuide

class ImmediateReturnTimer: CountingDownTimer {
    
    let isRunning = false
            
    func start(onTimeIsUp: @escaping () -> Void) {
        onTimeIsUp()
    }
    
    func cancel() {}
}
