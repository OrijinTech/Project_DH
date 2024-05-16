//
//  LibraryView.swift
//  Project_Me
//
//  Created by mac on 2024/5/4.
//

import SwiftUI

struct LibraryView: View {
    @State private var showingDetail = false
    @State private var selectedCardType: CardType?
    @State private var userName = ""
    @State private var email = ""
    @State private var tel = ""
    @State private var description = ""
    @State private var address = ""
    @State private var createdUser: User?

    var body: some View {
        NavigationView {
            List {
                ForEach(CardType.allCases, id: \.self) { cardType in
                    Button(action: {
                        self.selectedCardType = cardType
                        self.showingDetail.toggle()
                    }) {
                        Text(cardType.rawValue)
                    }
                }
            }
            .navigationBarTitle("Library")
            .sheet(isPresented: $showingDetail) {
                DetailForm(
                    selectedCardType: $selectedCardType,
                    userName: $userName,
                    email: $email,
                    tel: $tel,
                    description: $description,
                    address: $address,
                    createdUser: $createdUser
                )
            }
            
            if let user = createdUser {
                VStack {
                    if selectedCardType == .cardView1 {
                        CardView1(user: user)
                    } else if selectedCardType == .cardView2 {
                        CardView2(user: user)
                    }
                }
                .padding()
            }
        }
    }
}


#Preview {
    LibraryView()
}
