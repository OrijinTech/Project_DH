//
//  MainMenuView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI

struct MainMenuView: View {
    /*
    enum Tab: Int {
        case myDay, myCoach, mediaInput, community, profile
    }
    */
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "person.crop.rectangle.fill")
                }
            
            // TODO: implement NameCardRepo
//            NameCardListView()
//                .tabItem {
//                    Image(
//                        systemName: "person.crop.rectangle.fill"
//                    )
//                }
//                .tag(0)
            
//            LibraryView()
//                .tabItem {
//                    Image(
//                        systemName: "building.columns.fill"
//                    )
//                }
//                .tag(1)
            ChatSelectionView()
                .tabItem {
                    Image(systemName: "face.smiling.fill")
                }
            
            // TODO: implement Community
            Text("Display Users Community!")
                .tabItem {
                    Image(
                        systemName: "bubble"
                    )
                }
                .tag(2)
            
            ProfilePageView()
                .tabItem {
                    Image(
                        systemName: "person.crop.circle.fill"
                    )
                }
                .tag(3)
            
            
        }
        // system background color automatically adjust the color
        .tint(.primary)
        
    }
}

#Preview {
    MainMenuView()
}
