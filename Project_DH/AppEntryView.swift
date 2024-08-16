//
//  ContentView.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 4/27/24.
//

import SwiftUI

struct AppEntryView: View {
    @StateObject var viewModel = MenuViewModel()
    
    var body: some View {
        Group {
            if viewModel.userSession != nil { // if the user session is none
                MainMenuView()
            } else {
                SignInView()
            }
        }// End of Navigation Stack
    }
}

#Preview {
    AppEntryView()
}
