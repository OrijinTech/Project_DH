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

struct User: Codable, Identifiable, Hashable {
    @DocumentID var uid: String? // Assign the Document Id on the firestore to the uid variable.
    
    // Major Information
    var firstName: String?
    var lastName: String?
    var email: String
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


extension User {
    static let MOCK_USER = User(email: "123@gmail.com", userName: "MockUserName")
    
}


