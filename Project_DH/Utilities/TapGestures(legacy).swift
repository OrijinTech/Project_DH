//
//  TapGestures.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/5/24.
//

import Foundation
import SwiftUI


// ADDING TAP GESTURES TO WINDOWS
// BELOW CODE IS REFERENCED FROM: https://stackoverflow.com/a/60010955/8697793


/// Currently used for hiding keyboard after user taps away
extension UIApplication {
    
    /// Adds a gesture recognizer to a window in a SwiftUI or UIKit application
    /// - Parameters: none
    /// - Returns: none
    func addTapGestureRecognizer() {
        guard let window = (connectedScenes.first as? UIWindowScene)?.windows.first else { return }
//        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        let tapGesture = AnyGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
    
}


extension UIApplication: UIGestureRecognizerDelegate {
    /// This method determines whether two gesture recognizers should be allowed to recognize their gestures simultaneously
    /// - Parameters:
    ///    - _ gestureRecognizer: First UIGestureRecognizer.
    ///    - shouldRecognizeSimultaneouslyWith: Second UIGestureRecognizer.
    /// - Returns: Boolean value whether two recognizers should recognize simultaneously.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
    
}


class AnyGestureRecognizer: UIGestureRecognizer {
    
    /// This method is called when one or more fingers touch down on the screen.
    /// - Parameters:
    ///     - _ touches: Instances representing the touches for the starting phase of the event.
    ///     - with: The event associated with the touch event.
    /// - Returns: none
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touchedView = touches.first?.view, touchedView is UIControl {
            state = .cancelled

        } else if let touchedView = touches.first?.view as? UITextView, touchedView.isEditable {
            state = .cancelled

        } else {
            state = .began
        }
    }

    
    /// This method is called when one or more fingers are lifted from the screen.
    /// - Parameters:
    ///     - _ touches: Instances representing the touches that have ended
    ///     - with: The event associated with the touch event.
    /// - Returns: none
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       state = .ended
    }

    
    /// This method is called when one or more touches are canceled by the system.
    /// - Parameters:
    ///     - _ touches: Instances representing the touches that were canceled.
    ///     - with: The event associated with the touch event.
    /// - Returns: none
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
    
}
