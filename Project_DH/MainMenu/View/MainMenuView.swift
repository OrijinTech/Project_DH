//
//  MainMenuView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI


/// The view which handles all major tabs of the application. The logic for the bottom tabs.
struct MainMenuView: View {
    
    var body: some View {

        ZStack(alignment: .bottom) {
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
                    .tag(2)
                
                Text("Display Users Community!")
                    .tabItem {
                        Image(systemName: "bubble")
                    }
                    .tag(3)
                
                ProfilePageView()
                    .tabItem {
                        Image(systemName: "person.crop.circle.fill")
                    }
                    .tag(4)
            }
            .tint(.primary)
            
            // Custom border line above the tab icons
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray)
                    .frame(height: 1)
                    .padding(.bottom, 49)
            }
            .edgesIgnoringSafeArea(.bottom) // Ensures the Divider is aligned with the tab bar
        }

    }
}


#Preview {
    MainMenuView()
}
