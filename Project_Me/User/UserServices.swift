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

class UserServices {
    @Published var currentUser: User?
    
    static let sharedUser = UserServices()
    
    @MainActor
    func fetchCurrentUserData() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let snapshot = try await Firestore.firestore().collection(Collection().user).document(uid).getDocument()
        let user = try snapshot.data(as: User.self)
        self.currentUser = user
    }
    
    
    func fetchUsers() async throws -> [User]{
        guard let currentUid = Auth.auth().currentUser?.uid else { return []}
        let snapshot = try await Firestore.firestore().collection(Collection().user).getDocuments()
        let users = snapshot.documents.compactMap({ try? $0.data(as: User.self)})
        return users.filter({$0.id != currentUid}) // Do not include the current logged in user
    }
    
    // a function which fetches any user in the application with an uid, not just the current user
    static func fetchUser(with uid: String) async throws -> User {
        let snapshot = try await Firestore.firestore().collection(Collection().user).document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    
    func reset() {
        self.currentUser = nil
    }
    
    @MainActor
    func updateUserProfileImage(with imageUrl: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData([
            "profileImageUrl": imageUrl
        ])
        self.currentUser?.profileImageUrl = imageUrl
    }
    
    @MainActor
    func updateUserName(with userName: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["userName": userName])
        self.currentUser?.userName = userName
    }
    
    
}
