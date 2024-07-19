//
//  AuthServices.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class AuthServices {
    @Published var userSession: FirebaseAuth.User?
    static let sharedAuth = AuthServices()
    
    init() {
        self.userSession = Auth.auth().currentUser // In charge of taking the user to either welcome view or main menu if they are signed in
        Task { try await UserServices.sharedUser.fetchCurrentUserData() } // Get user data
    }
    
    
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await UserServices.sharedUser.fetchCurrentUserData()
            print("LOGGED IN USER \(result.user.uid)" )
        } catch {
            print("ERROR: FAILED TO SIGN IN")
        }
    }
    
    
    @MainActor
    func createUser(withEmail email: String, password: String, username: String) async throws {
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            try await self.uploadUserData(email: email, userName: username, id: result.user.uid)
            print("CREATED USER \(result.user.uid)" )
        } catch {
            print("ERROR: FAILED TO CREATE USER: \(error.localizedDescription)") //automatically gives us the "error" object by swift
        }
    }
    
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            UserServices.sharedUser.reset() // Set currentUser object to nil
        } catch {
            print("ERROR: FAILED TO SIGN OUT") 
        }
    }
    
    
    @MainActor // Same as Dispatchqueue.main.async
    private func uploadUserData(email: String, userName: String?, id: String) async throws {
        let user = User(email: email, userName: userName!, profileImageUrl: nil)
        guard let encodeUser = try? Firestore.Encoder().encode(user) else { return }
        try await Firestore.firestore().collection(Collection().user).document(id).setData(encodeUser)
        UserServices.sharedUser.currentUser = user
    }
    
    
    
}
