//
//  MenuViewModel.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import Firebase
import SwiftUI
import Combine

class MenuViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var showLoadingScreen = true
    
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        setupUser()
    }
    
    private func setupUser(){
        AuthServices.sharedAuth.$userSession.sink { [weak self] userSessionFromAuthService in
            self?.userSession = userSessionFromAuthService
//            self?.showLoadingScreen = false
        }.store(in: &cancellable)
    }
    
    
}
