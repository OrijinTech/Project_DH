//
//  CardView.swift
//  Project_Me
//
//  Created by mac on 2024/5/4.
//

import SwiftUI

struct CardView1: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(user.userName ?? user.email)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // if have description then display
                    if let description = user.description {
                        Text(description)
                            .font(.subheadline)
                    }
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: 5) {
                if let tel = user.tel {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                        Text(tel)
                    }
                }
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                    Text(user.email)
                }
            }
        }
        .padding()
        .frame(
            width: UIScreen.main.bounds.width - 20,
            height: UIScreen.main.bounds.height / 5
        )
        .background(
            RoundedRectangle(cornerRadius: 15).fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black, lineWidth: 2)
        )
        // .shadow(radius: 5)
        .padding()
    }
}

#Preview {
    CardView1(user: MockData.mockUsers[0])
}
