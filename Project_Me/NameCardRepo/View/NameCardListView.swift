//
//  NameCardListView.swift
//  Project_Me
//
//  Created by mac on 2024/5/4.
//

import SwiftUI

struct NameCardListView: View {
    @StateObject var viewModel = MenuViewModel()
    
    // MOCK
    let mockUser = MockData.mockUsers
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(mockUser) { user in
                        CardView(user: user)
                    }
                }
                .padding()
            }
            .navigationTitle("Hello, \(viewModel.userSession?.email ?? "Folks!")")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NameCardListView()
}
