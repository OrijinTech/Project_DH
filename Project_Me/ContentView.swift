//
//  ContentView.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 4/27/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = MenuViewModel()
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                MainMenuView()
            } else {
                SignInView()
            }
        }// End of Navigation Stack
    }
}

#Preview {
    ContentView()
}
