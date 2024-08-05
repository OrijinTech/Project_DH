//
//  Timer.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/8/24.
//

import Foundation
import Combine


class TimeManager: ObservableObject {
    
    @Published var isButtonEnabled = true
    @Published var timeRemaining = 60
    
    private var timer: Timer?
    
    static let sharedTimer = TimeManager()
    
    init() {}
    
    
    /// The function starts a timer which an 1 second interval.
    /// - Parameters: none
    /// - Returns: none
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.isButtonEnabled.toggle()
                self.timer?.invalidate()
                self.timeRemaining = 60
            }
        }
    }
    
    
    /// The function stops the timer. 
    /// - Parameters: none
    /// - Returns: none
    func stopTimer() {
        timer?.invalidate()
    }
    
    
    
}
