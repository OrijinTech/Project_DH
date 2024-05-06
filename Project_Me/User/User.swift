//
//  User.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/11/24.
//

import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore
import Firebase

// MARK: USER DATA MODEL
// TODO: MAKE SURE TO EDIT THIS DATA MODEL ACCORDING OUR NEEDS
struct User: Codable, Identifiable, Hashable {
    @DocumentID var uid: String? // Assign the Document Id on the firestore to the uid variable.
    
    // Major Information
    var firstName: String?
    var lastName: String?
    var email: String
    var tel: String?
    var userName: String
    var profileImageUrl: String?
    var id: String { // Use this to work with instead of the uid
        return uid ?? NSUUID().uuidString
    }
    
    
    // Other Information
    var description: String?
    var followerNum: Int?
    
    // Personal Information
    var birthday: Date?
    var gender: String?
    var weight: Float?
    var height: Float?
    var waterReminder: Bool?
    var units: [String]?
    
}

// Mock user
extension User {
    static let MOCK_USER = User(email: "123@gmail.com", userName: "MockUserName")
    
}


