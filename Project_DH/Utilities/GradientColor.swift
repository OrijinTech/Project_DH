//
//  GradientColor.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 8/17/24.
//

import Foundation
import SwiftUI

struct GradientColor: View {
    let fromColor: Color
    let toColor: Color
    
    var body: some View {
        RadialGradient(gradient: Gradient(colors: [fromColor, toColor]), center: .center, startRadius: 20, endRadius: 150)
            .frame(width: 300, height: 200)
            .cornerRadius(10)
            .shadow(radius: 10)
    }
}
