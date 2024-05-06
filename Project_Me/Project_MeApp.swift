//
//  Project_MeApp.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 4/27/24.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct Project_MeApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .preferredColorScheme(.light) // This sets the application to only show in light mode.
        }
    }
}

