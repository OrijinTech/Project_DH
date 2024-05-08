//
//  AuthenticationViewModel.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import Foundation
import GoogleSignIn
import FirebaseAuth
import CryptoKit
import AuthenticationServices

class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var nonce: String?
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
    
    @MainActor 
    func signInApple(_ authorization: ASAuthorization) async throws {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            try await AuthServices.sharedAuth.loginWithApple(credential: credential)
        }
    }
    
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    @MainActor
    func resetPassword() async throws {
        try await AuthServices.sharedAuth.resetPassword(with: self.email)
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

// MARK: THIS IS THE DATA MODEL FOR GOOGLE SIGN IN
struct GoogleSignInModel {
    let idToken: String
    let accessToken: String
}







