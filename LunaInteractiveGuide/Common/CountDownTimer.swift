//
//  CountDownTimer.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 11/07/2023.
//

import Foundation
import Combine

protocol CountingDownTimer {
    var isRunning: Bool { get }
    
    func start(onTimeIsUp: @escaping () -> Void)
    func cancel()
}

class CountDownTimer: CountingDownTimer {
    
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>? = nil
    private var subsctiption: AnyCancellable? = nil
    private let seconds: Double
    
    init(seconds: Double) {
        self.seconds = seconds
    }
    
    var isRunning: Bool {
        return timer != nil
    }
    
    func start(onTimeIsUp: @escaping () -> Void) {
        timer = Timer.publish(every: seconds, on: .main, in: .common).autoconnect()
        subsctiption = timer?
            .sink(receiveValue: { [weak self] _ in
                onTimeIsUp()
                self?.cancel()
            })
    }
    
    func cancel() {
        timer?.upstream.connect().cancel()
        timer = nil
        subsctiption?.cancel()
        subsctiption = nil
    }
}
