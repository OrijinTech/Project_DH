//
//  ProfilePageViewModel.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//

import Foundation
import Combine
import Firebase
import PhotosUI
import SwiftUI


/// Receive the user data from the UserService to this view model. We can then pass the user info into the profile view from this view model
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var profileImage: Image?
    @Published var userName = ""
    @Published var uiImage: UIImage?
    @Published var showEditWindow = false
    @Published var curState = AccountOptions.email
    @Published var strToChange = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        setupUser()
    }
    
    
    /// This function is called when setting up the user session.
    /// - Parameters: none
    /// - Returns: none
    private func setupUser() {
        UserServices.sharedUser.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }.store(in: &cancellables)
    }
    
    
    /// This function calls the profile image update logic.
    /// - Parameters: none
    /// - Returns: none
    /// - Note: This function doesn't perform the update logic, it is an interface for the frontend to call.
    func updateProfilePhoto() async throws {
        try await updateProfileImage()
        print("UPDATE: USER PROFILE")
    }
    
    
    /// This function calls the profile username update logic.
    /// - Parameters:
    ///     - with: The new username entered.
    /// - Returns: none
    /// - Note: This function doesn't perform the update logic, it is an interface for the frontend to call.
    func updateUsermame(with userName: String) async throws {
        try await updateUserName(with: userName)
    }
    
    
    /// This function updates the profile username, and handles the logic for that.
    /// - Parameters: none
    /// - Returns: none
    /// - Note: This function doesn't perform the networking tasks, instead it calls the updateUserProfileImage function inside UserServices to do that.
    @MainActor
    private func updateProfileImage() async throws {
        guard let image = self.uiImage else { return }
        guard let imageUrl = try? await ImageUploader.uploadImage(image) else {
            print("ERROR: FAILED TO GET imageURL! \nSource: updateProfileImage() ")
            return
        }
        try await UserServices.sharedUser.updateUserProfileImage(with: imageUrl)
    }
    
    
    /// This function updates the profile username, and handles the logic for that.
    /// - Parameters:
    ///     - with: The new username entered.
    /// - Returns: none
    /// - Note: This function doesn't perform the networking tasks, instead it calls the updateUserName function inside UserServices to do that.
    @MainActor
    func updateUserName(with userName: String) async throws {
        try await UserServices.sharedUser.updateUserName(with: userName)
    }
    
    
    /// This function is an generic function which updates any user related information.
    /// - Parameters:
    ///     - with: the enum which is the AccountOptions
    ///     - strInfo: The information to update.
    /// - Returns: none
    @MainActor
    func updateInfo(with enumType: AccountOptions, strInfo: String?) async throws {
        guard strInfo != nil else { return }
        switch enumType {
        case .username:
            try await UserServices.sharedUser.updateAccountOptions(with: strInfo!, enumInfo: .username)
        case .lastName:
            try await UserServices.sharedUser.updateAccountOptions(with: strInfo!, enumInfo: .lastName)
        case .firstName:
            try await UserServices.sharedUser.updateAccountOptions(with: strInfo!, enumInfo: .firstName)
        case .email:
            try await UserServices.sharedUser.updateAccountOptions(with: strInfo!, enumInfo: .email)
        case .password:
            try await UserServices.sharedUser.updateAccountOptions(with: strInfo!, enumInfo: .password)
        case .birthday:
            try await UserServices.sharedUser.updateAccountOptions(with: strInfo!, enumInfo: .birthday)
        }
    }
    
    
    /// This function displays the current user information.
    /// - Parameters:
    ///     - with: The enum of AccountOptions.
    /// - Returns: none
    func getUserDisplayStrInfo(with enumType: AccountOptions) -> String {
        switch enumType {
        case .username:
            return currentUser?.userName ?? ""
        case .lastName:
            return currentUser?.lastName ?? ""
        case .firstName:
            return currentUser?.firstName ?? ""
        case .email:
            return currentUser?.email ?? ""
        case .password:
            return ""
        case .birthday:
            return ""
        }
    }
    
    
//    private func loadImage() async {
//        guard let item = selectedItem else { return }
//        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
//        guard let uiImage = UIImage(data: data) else { return }
//        self.profileImage = Image(uiImage: uiImage)
//    }
    
    
}
