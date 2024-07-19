//
//  dividerOr.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI

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
