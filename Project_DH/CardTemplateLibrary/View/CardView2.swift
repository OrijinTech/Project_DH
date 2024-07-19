//
//  CardView.swift
//  Project_Me
//
//  Created by mac on 2024/5/16.
//

import SwiftUI

struct CardView2: View {
    let user: User
    
    var body: some View {
        HStack {
            // Left part: Image, Name, Description
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(user.userName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let description = user.description, !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.leading, 8)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            // Right part: Contact details
            VStack(alignment: .leading, spacing: 8) {
                if let tel = user.tel, !tel.isEmpty {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                        Text(tel)
                            .foregroundColor(.black)
                    }
                }
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                    Text(user.email)
                        .foregroundColor(.black)
                }
                
                if let address = user.address, !address.isEmpty {
                    HStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(.orange)
                        Text(address)
                            .foregroundColor(.black)
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        
        .padding()
        .frame(
            width: UIScreen.main.bounds.width - 20,
            height: UIScreen.main.bounds.height / 5
        )
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
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
    CardView2(user: MockData.mockUsers[0])
}
