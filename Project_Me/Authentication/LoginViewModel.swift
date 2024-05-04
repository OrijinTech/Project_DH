//
//  AuthenticationViewModel.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import Foundation


class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var alertItem: AlertItem?
    
    @MainActor
    func login() async throws {
        guard isValidForm else { return }
        try await AuthServices.sharedAuth.login(withEmail: email, password: password)
        alertItem = AlertContent.invalidCredentials
    }
    
    
    var isValidForm: Bool {
        // check if we have all values in the profile forms
        guard !email.isEmpty && !password.isEmpty else {
            alertItem = AlertContent.invalidForm
            return false
        }
        return true
    }
    
    
}






