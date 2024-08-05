//
//  dividerOr.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI

/// The view which shows the divider line with an "or" in between.
struct dividerOr: View {
    var body: some View {
        HStack {
            VStack {
                Divider()
            }
            .padding(.horizontal, 10)
            Text("OR")
            VStack {
                Divider()
            }
            .padding(.horizontal, 10)
        }
    }
}

#Preview {
    dividerOr()
}
