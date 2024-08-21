//
//  TopShadow.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 8/21/24.
//

import Foundation
import SwiftUI

struct TopShadow: ViewModifier {
    var color: Color = Color.black.opacity(0.1)
    var radius: CGFloat = 3
    var x: CGFloat = 0
    var y: CGFloat = -3
    
    func body(content: Content) -> some View {
        content
            .background(
                Color.white
                    .clipShape(RoundedCornerShape(radius: 20, corners: [.topLeft, .topRight]))
                    .shadow(color: color, radius: radius, x: x, y: y)
            )
            .padding(.top, radius) // Padding to prevent clipping of shadow
    }
}
