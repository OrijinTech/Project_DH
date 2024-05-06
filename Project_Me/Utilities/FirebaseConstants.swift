//
//  FirebaseConstants.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/11/24.
//

import Foundation


// MARK: This file documents all constants to access the fields on firebase firestore.
// TODO: This needs to be adjusted according to this project.

struct Collection {
    let user = "user"
    let chats = "chats"
    let threads = "threads"
}


struct Document {
    let message = "message"
    
}


struct DataConst {
    let model = "model"
}


struct UserConst {
    let firstName = "firstName"
    let lastName = "lastName"
    let email = "email"
    let userName = "userName"
    let profileImageUrl = "profileImageUrl"
    let description = "description"
    let followerNum = "followerNum"
    
    
}
