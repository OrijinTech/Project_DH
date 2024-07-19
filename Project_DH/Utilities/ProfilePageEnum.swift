//
//  ProfilePageData.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//


import SwiftUI

enum ProfileOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case socialMedia
    case businessInfo
    case friends
    case settings
    
    
    var title: LocalizedStringKey {
        switch self {
        case .socialMedia:
            return "Social Media"
        case .businessInfo:
            return "Business Info"
        case .friends:
            return "My Friends"
        case .settings:
            return "Settings"
        }
    }
    
}


enum AccountOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case username
    case lastName
    case firstName
    case email
    case password
    case birthday
    
    var title: LocalizedStringKey {
        switch self {
        case .username:
            return "Change Username"
        case .email:
            return "Change Email"
        case .password:
            return "Change Password"
        case .firstName:
            return "Change First Name"
        case .lastName:
            return "Change Last Name"
        case .birthday:
            return "Change Birthday"
        }
    }
    
    var placeholder: LocalizedStringKey {
        switch self {
        case .username:
            return "username"
        case .lastName:
            return "last name"
        case .firstName:
            return "first name"
        case .email:
            return "email"
        case .password:
            return "password"
        case .birthday:
            return "birthday"
        }
    }
}

