//
//  MenuViewModel.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import Firebase
import FirebaseAuth
import SwiftUI
import Combine


/// The viewmodel for MeinMenuView.
class MenuViewModel: ObservableObject {
    /// user session which is retrieved from the Firebase
    @Published var userSession: FirebaseAuth.User?
    /// loading screen which shows during the user session setup
    @Published var showLoadingScreen = true
    /// variable which follows cancellable protocol
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        setupUser()
    }

    
    /// This function is called when setting up the user session.
    /// - Parameters: none
    /// - Returns: none
    private func setupUser(){
        AuthServices.sharedAuth.$userSession.sink { [weak self] userSessionFromAuthService in
            self?.userSession = userSessionFromAuthService
//            self?.showLoadingScreen = false
        }.store(in: &cancellable)
    }
    
    
}
