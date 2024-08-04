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

// Publish the user data from the UserService to here. We can then pass the user info into the profile view from this view model
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var profileImage: Image?
    @Published var userName = ""
    @Published var uiImage: UIImage?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showEditWindow = false
    
    @Published var curState = AccountOptions.email
    @Published var strToChange = ""
    
    
    init() {
        setupUser()
    }
    
    private func setupUser() {
        UserServices.sharedUser.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }.store(in: &cancellables)
    }
    
    
    func updateProfilePhoto() async throws {
        try await updateProfileImage()
        print("UPDATE: USER PROFILE")
    }
    
    func updateUsermame(with userName: String) async throws {
        try await updateUserName(with: userName)
    }
    
    
    @MainActor
    private func updateProfileImage() async throws {
        guard let image = self.uiImage else { return }
        guard let imageUrl = try? await ImageUploader.uploadImage(image) else {
            print("ERROR: FAILED TO GET imageURL! \nSource: updateProfileImage() ")
            return
        }
        try await UserServices.sharedUser.updateUserProfileImage(with: imageUrl)
    }
    
    @MainActor
    func updateUserName(with userName: String) async throws {
        try await UserServices.sharedUser.updateUserName(with: userName)
    }
    
    
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
