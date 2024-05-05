//
//  AuthenticationViewModel.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import Foundation
import GoogleSignIn
import FirebaseAuth

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
    
    
    // MARK: The function for sign-in with Google. This is called in the views that has this view model
    @MainActor
    func signInGoogle() async throws {
        //topViewController() Gets the top View of the application to display the Google sign in pop-up page
        guard let topVC = TopViewController.sharedTopController.topViewController() else {
            throw URLError(.cannotFindHost)
        }

        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken: String = signInResult.user.idToken?.tokenString else {
            // TODO: Double check the throw message
            throw URLError(.badServerResponse)
        }
        
        let accessToken: String = signInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInModel(idToken: idToken, accessToken: accessToken)
        
        // Calling the sign in network calls inside AuthServices
        try await AuthServices.sharedAuth.loginWithGoogle(tokens: tokens)
    }
    
    
    // MARK: check if we have all values in the profile forms
    var isValidForm: Bool {
        guard !email.isEmpty && !password.isEmpty else {
            alertItem = AlertContent.invalidForm
            return false
        }
        return true
    }
    
    
}

struct GoogleSignInModel {
    let idToken: String
    let accessToken: String
}








