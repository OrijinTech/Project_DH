//
//  RegisterViewModel.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import Foundation


class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var privacy = false
    @Published var conditions = false
    
    @Published var alertItem: AlertItem?
    @Published var showLoadingScreen = true
    
    // TODO: CREATE LOCAL USER OBJECT
//    @Published var User
    
    
    
    func createUser() async throws {
        guard isValidForm else { return }
        try await AuthServices.sharedAuth.createUser(withEmail: email, password: password, username: username)
    }
    
    
    // Broadcasting the error for account form
    var isValidForm: Bool {
        // check if we have all values in the profile forms
        guard !username.isEmpty && !email.isEmpty && !password.isEmpty else {
            alertItem = AlertContent.invalidForm
            return false
            
        }
        // check if email string is valid: isValidEmail is a method which extends String
        guard email.isValidEmailFormat else {
            alertItem = AlertContent.invalidEmail
            return false
        }
        
        guard password.count >= 6 else {
            alertItem = AlertContent.invalidPassword
            return false
        }
        
        return true
    }
    
    
}

