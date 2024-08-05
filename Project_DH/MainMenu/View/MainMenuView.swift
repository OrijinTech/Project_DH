//
//  MainMenuView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI


/// The view which handles all major tabs of the application. The logic for the bottom tabs.
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
                .tag(0)
            
            ChatSelectionView()
                .tabItem {
                    Image(systemName: "face.smiling.fill")
                }
                .tag(1)
            
            MealInputView()
                .tabItem {
                    Image(systemName: "plus.app.fill")
                }
            
            // TODO: implement Community
            Text("Display Users Community!")
                .tabItem {
                    Image(systemName: "bubble")
                }
                .tag(2)
            
            ProfilePageView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    
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
