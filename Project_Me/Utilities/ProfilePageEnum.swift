//
//  ProfilePageData.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//


import SwiftUI

enum ProfileOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case dietPlans
    case friends
    case healthRecords
    case settings
    
    
    var title: LocalizedStringKey {
        switch self {
        case .dietPlans:
            return "Diet Plans"
        case .friends:
            return "Friends"
        case .healthRecords:
            return "Health Records"
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



enum PersonalInfoOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case weight
    case height
    case gender
    case waterReminder
    case units
    
    var title: LocalizedStringKey {
        switch self {
        case .weight:
            return "Set my weight"
        case .height:
            return "Set my height"
        case .waterReminder:
            return "Water Reminder"
        case .units:
            return "Set up Units"
        case .gender:
            return "Change gender"
        }
    }
    
    
}


