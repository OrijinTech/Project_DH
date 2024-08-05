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


/// The viewmodel for SignIn View.
class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var nonce: String?
    @Published var alertItem: AlertItem?
    
    
    /// This function is triggered when the user tries to log in on the front end.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func login() async throws {
        guard isValidForm else { return }
        try await AuthServices.sharedAuth.login(withEmail: email, password: password)
        alertItem = AlertContent.invalidCredentials
    }
    
    
    /// This function for Google sign in method. This is called in the views which has this view model.
    /// - Parameters: none
    /// - Returns: none
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
    
    
    /// This function is for handling the apple sign in action from the front end.
    /// - Parameters:
    ///     - _ authorization: the ASAuthorization object.
    /// - Returns: none
    @MainActor
    func signInApple(_ authorization: ASAuthorization) async throws {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce else {
                fatalError("ERROR: Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("ERROR: Unable to fetch identity token \nSource: SignInViewModel/signInApple() ")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("ERROR: Unable to serialize token string from data: \n\(appleIDToken.debugDescription) \nSource: SignInViewModel/signInApple() ")
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
    
    
    /// Generates a random string (nonce) of a specified length, with a default length of 32 characters.
    /// - Parameters:
    ///     - length: the length of the resultant random string
    /// - Returns: The random string with specified length
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("ERROR: Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode) \nSource: SignInViewModel/randomNonceString() ")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    
    /// Computes the SHA-256 hash of an input string and returns the hash as a hexadecimal string
    /// - Parameters:
    ///     - _ input: The string used for computing.
    /// - Returns: The hashed string.
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    /// The function handles for user's password reset request from the front end.
    /// - Parameters:
    ///     - _ input: The string used for computing.
    /// - Returns: The hashed string.
    @MainActor
    func resetPassword() async throws {
        try await AuthServices.sharedAuth.resetPassword(with: self.email)
    }
    
    
    ///  Checks whether all email and password  fields are filled.
    /// - Parameters: none
    /// - Returns: boolean value whether the fields are filled.
    var isValidForm: Bool {
        guard !email.isEmpty && !password.isEmpty else {
            alertItem = AlertContent.invalidForm
            return false
        }
        return true
    }
    
    
}


///  The structs for google sign in token.
struct GoogleSignInModel {
    let idToken: String
    let accessToken: String
}







