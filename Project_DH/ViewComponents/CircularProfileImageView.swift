//
//  CircularProfileImageView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/15/24.
//

import SwiftUI
import Kingfisher


struct CircularProfileImageView: View {
    
    var user: User?
    var height: CGFloat?
    var width: CGFloat?
    var showCircle: Bool = false
    
    var transparent: Bool?
    
    init(user: User?, width: CGFloat?, height: CGFloat?, showCircle: Bool) {
        self.user = user
        self.height = height
        self.width = width
        self.showCircle = showCircle
    }
    
    var body: some View {
        ZStack {
            if showCircle{
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundColor(.gray)
                    .frame(width: width, height: height)
            }
            if let imageUrl = user?.profileImageUrl {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(Circle())
    //            .background(transparent ? .clear : .brand)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: width, height: height)
                    .foregroundStyle(Color(.systemGray4))
                    
            }
        }

    }
}


#Preview {
    CircularProfileImageView(user: User.MOCK_USER, width: 40, height: 40, showCircle: false)
}
