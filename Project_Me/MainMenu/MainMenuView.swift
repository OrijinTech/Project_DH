//
//  MainMenuView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI

struct MainMenuView: View {
    enum Tab: Int {
        case myDay, myCoach, mediaInput, community, profile
    }
    
    var body: some View {
        Button {
            AuthServices.sharedAuth.signOut()
        }label: {
            Text("Log Out                                                      ")
        }
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .frame(width: 300, height: 45)
        .background(.brand)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.vertical)
        
//        TabView {
//            MyDayView()
//                .tabItem {
//                    Image(systemName: "note.text")
//                    Text("My Day")
//                }
//            MyCoachView()
//                .tabItem {
//                    Image(systemName: "face.smiling")
//                    Text("My Coach")
//                }
//            MediaInputView()
//                .tabItem {
//                    Image(systemName: "plus")
//                }
//            CommunityView()
//                .tabItem {
//                    Image(systemName: "person.2.fill")
//                    Text("Community")
//                }
//            ProfileView()
//                .tabItem {
//                    Image(systemName: "person")
//                    Text("Me")
//                }
//        }
//        .tint(.brand)
    }
}

#Preview {
    MainMenuView()
}
