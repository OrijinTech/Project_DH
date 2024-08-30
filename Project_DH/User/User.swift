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


// TODO: MAKE SURE TO EDIT THIS DATA MODEL ACCORDING OUR NEEDS
/// The data model for creating a user of this application.
struct User: Codable, Identifiable, Hashable {
    
    @DocumentID var uid: String? // Assign the Document Id on the firestore to the uid variable.
    
    // Major Information
    var firstName: String?
    var lastName: String?
    var email: String
    var tel: String?
    var userName: String?
    var profileImageUrl: String?
    var address: String?
    var maxCalorieAPIUsageNum: Int? = 5 // The number of times user can estimate calories.
    var maxAssistantTokenNum: Int? = 10000 // The number of tokens available when user is using AI Assistant.
    
    
    var id: String { // Use this to work with instead of the uid
        return uid ?? NSUUID().uuidString
    }
     
    
    // Other Information
    var description: String?
    var followerNum: Int?
    
    // Personal Information
    var birthday: Date?
    var gender: String?
    var targetCalories: String?
    
}


// Mock user
extension User {
    static let MOCK_USER = User(email: "123@gmail.com", userName: "MockUserName")
    
}


