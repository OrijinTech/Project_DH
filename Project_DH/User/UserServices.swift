//
//  UserService.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/11/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

/// Takes care of all network tasks of user services with firebase.
class UserServices {

    @Published var currentUser: User?
    
    static let sharedUser = UserServices() // Use this user service object across the application.
    
    
    /// This function fetches all information about the current user. The current user is determined by the Firebase Authentication's current user's uid.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func fetchCurrentUserData() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return } // TODO: ENDED HERE
        let snapshot = try await Firestore.firestore().collection(Collection().user).document(uid).getDocument()
        let user = try snapshot.data(as: User.self)
        self.currentUser = user
        print("SUCCESS: USER DATA FETCHED \nSource: fetchCurrentUserData() \nUser ID: \(String(describing: user.uid))")
    }
    
    
    /// This function fetches all users in the database except for the current user.
    /// - Parameters:none
    /// - Returns: A list of users.
    func fetchUsers() async throws -> [User]{
        guard let currentUid = Auth.auth().currentUser?.uid else { return []}
        let snapshot = try await Firestore.firestore().collection(Collection().user).getDocuments()
        let users = snapshot.documents.compactMap({ try? $0.data(as: User.self)})
        return users.filter({$0.id != currentUid}) // Do not include the current logged in user
    }
    
    
    /// A function which fetches any user in the application with an uid, not just the current user.
    /// - Parameters:
    ///     - with: The uid of the user which you tries to fetch.
    /// - Returns: User
    static func fetchUser(with uid: String) async throws -> User {
        let snapshot = try await Firestore.firestore().collection(Collection().user).document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    
    /// This function sets the current user to nil.
    /// - Parameters: none
    /// - Returns: none
    func reset() {
        self.currentUser = nil
    }
    
    
    // TODO: Need a more general function for uploading more various user data
    /// This function updates the user's profile image. It saves the image url on Firebase, and sets the image on the application.
    /// - Parameters:
    ///     - with: The image url to save to Firebase.
    /// - Returns: none
    @MainActor
    func updateUserProfileImage(with imageUrl: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData([
            "profileImageUrl": imageUrl
        ])
        self.currentUser?.profileImageUrl = imageUrl
    }
    
    
    // TODO: Need a more general function for uploading more various user data
    /// This function updates the username. It saves the username string on Firebase, and sets the username in the application.
    /// - Parameters:
    ///     - with: The username which you want to save.
    /// - Returns: none
    @MainActor
    func updateUserName(with userName: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["userName": userName])
        self.currentUser?.userName = userName
    }
    
    
    // TODO: Need a more general function for uploading more various user data
    /// The generic function to update user's information.
    /// - Parameters:
    ///     - with: The information to change.
    ///     - enumInfo: The AccountOptions.
    /// - Returns: none
    @MainActor
    func updateAccountOptions(with infoToChange: String, enumInfo: AccountOptions) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        switch enumInfo {
        case .username:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["userName": infoToChange])
            self.currentUser?.userName = infoToChange
        case .lastName:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["lastName": infoToChange])
            self.currentUser?.lastName = infoToChange
        case .firstName:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["firstName": infoToChange])
            self.currentUser?.firstName = infoToChange
        case .email:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["email": infoToChange])
            self.currentUser?.email = infoToChange
        case .password:
            print("SHOULD CHANGE PASSWORD")
        case .birthday:
            print("SHOULD CHANGE BIRTHDAY")
        }
    }
    
    
}
