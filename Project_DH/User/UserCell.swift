//
//  UserCell.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/15/24.
//

import SwiftUI


struct UserCell: View {
    
    let user: User
    
    var body: some View {
        HStack {
            CircularProfileImageView(user: user, width: 40, height: 40, showCircle: false)
                
            VStack(alignment: .leading, spacing: 2) {
                Text(user.userName ?? user.email)
                    .fontWeight(.semibold)
                Text("One-line description.")
            }
            .font(.footnote)
            
            Spacer()
            
            Text("Follow")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width:100, height: 32)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1))
                }
        }
        .padding(.horizontal, 15)
    }
}


#Preview {
    UserCell(user: User.MOCK_USER)
}
