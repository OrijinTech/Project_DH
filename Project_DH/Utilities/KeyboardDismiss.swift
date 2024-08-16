//
//  KeyboardDismissView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 8/16/24.
//

import Foundation
import SwiftUI
import UIKit

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

