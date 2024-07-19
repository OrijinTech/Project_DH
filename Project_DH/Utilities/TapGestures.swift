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

// MARK: Currently used for hiding keyboard after user taps away
extension UIApplication {
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
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}

class AnyGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touchedView = touches.first?.view, touchedView is UIControl {
            state = .cancelled

        } else if let touchedView = touches.first?.view as? UITextView, touchedView.isEditable {
            state = .cancelled

        } else {
            state = .began
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       state = .ended
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
}
