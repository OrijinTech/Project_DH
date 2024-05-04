//
//  AlertContent.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/18/24.
//


import SwiftUI

struct AlertItem: Identifiable{
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContent {
    // Account Alerts
    static let invalidForm = AlertItem(title: Text("Invalid Form"),
                                            message: Text("Please ensure all fields are filled."),
                                            dismissButton: .default(Text("Ok")))
    
    static let invalidEmail = AlertItem(title: Text("Invalid Email"),
                                            message: Text("Please enter the correct email format."),
                                            dismissButton: .default(Text("Ok")))
    
    static let invalidPassword = AlertItem(title: Text("Invalid Password"),
                                            message: Text("Password must be at least 6 characters."),
                                            dismissButton: .default(Text("Ok")))
    
    static let invalidCredentials = AlertItem(title: Text("Invalid Credentials"),
                                            message: Text("Invalid email or password."),
                                            dismissButton: .default(Text("Ok")))
}
