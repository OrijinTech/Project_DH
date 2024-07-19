//
//  NameCardListView.swift
//  Project_Me
//
//  Created by mac on 2024/5/4.
//

import SwiftUI

// TODO: Implement the user's owned cards view shown
struct NameCardListView: View {
    @StateObject var viewModel = MenuViewModel()
    @StateObject var cardListViewModel = CardListViewModel()
    
    // MOCK
    let mockUser = MockData.mockUsers
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    /*
                    ForEach(mockUser) { user in
                        CardView1(user: user)
                    }
                     */
                    ForEach(CardType.allCases, id: \.self) { cardType in
                        if cardType == .cardView1 {
                            CardView1(user: mockUser[0])
                        }
                        if cardType == .cardView2 {
                            CardView2(user: mockUser[1])
                        }
                            
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
