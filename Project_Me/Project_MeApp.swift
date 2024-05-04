//
//  Project_MeApp.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 4/27/24.
//

import SwiftUI
import Firebase

@main
struct Project_MeApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
