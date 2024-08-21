//
//  ProfilePageData.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//


import SwiftUI


enum ProfileOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case meals
    case myStatistics
    case friends
    case settings
    
    /// The title of the options for the profile page menu.
    var title: LocalizedStringKey {
        switch self {
        case .meals:
            return "Meals"
        case .myStatistics:
            return "My Statistics"
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
    
    /// Title of each options in user info edit page.
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
    
    /// Placeholder to show for each user info field.
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


enum DietaryInfoOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case targetCalories
    
    /// Title of each options in user info edit page.
    var title: LocalizedStringKey {
        switch self {
        case .targetCalories:
            return "Change Target Calories"
        }
    }
    
    /// Placeholder to show for each user info field.
    var placeholder: LocalizedStringKey {
        switch self {
        case .targetCalories:
            return "target calories"
        }
    }
}
