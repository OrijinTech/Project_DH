//
//  EditProfileView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 5/10/24.
//

import SwiftUI
import PhotosUI


struct EditProfileView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    @Binding var showingProfileInfo: Bool
    
    @State private var image: UIImage?
    @State private var isConfirmationDialogPresented: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: SourceType = .camera
    @State private var pickedPhoto: Bool = false
    
    var currentEditTab = ""
    
    enum SourceType {
        case camera
        case photoLibrary
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                HStack {
                    Button {
                        showingProfileInfo = false
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(.brandDarkGreen)
                        }
                    }.padding(.leading, 30)
                    
                    Spacer()
                    

                    Button { // Save the photo to the Firebase
                        Task {
                            try await viewModel.updateProfilePhoto()
                            pickedPhoto = false
                        }
                    } label: {
                        Text(LocalizedStringKey("Save"))
                            .foregroundStyle(.brandDarkGreen)
                            .opacity(!pickedPhoto ? 0 : 1)
                    }
                    .padding(.trailing, 30)
                    .disabled(!pickedPhoto)
                    
                }
                .disabled(viewModel.showEditWindow)
                
                // Profile Photo
                VStack(spacing: 15) {
                    ZStack {
                        if let image = viewModel.profileImage { // An image is selected, but not yet uploaded
                            ProfileImageView(image: image)
                        }
                        else{
                            CircularProfileImageView(user: viewModel.currentUser, width: 100, height: 100, showCircle: true)
                        }
                    }
                    .padding(.bottom, 5)
                    .padding(.top, 30)
                    .onTapGesture{
                        isConfirmationDialogPresented = true
                    }
                    .confirmationDialog("Choose an option", isPresented: $isConfirmationDialogPresented) {
                        Button("Camera"){
                            sourceType = .camera
                            isImagePickerPresented = true
                        }
                        Button("Photo Library"){
                            sourceType = .photoLibrary
                            isImagePickerPresented = true
                        }
                        
                    }
                    .fullScreenCover(isPresented: $isImagePickerPresented) {
                        if sourceType == .camera{
                            ImagePicker(isPresented: $isImagePickerPresented, image: $image, sourceType: .camera)
                        }else{
                            PhotoPicker(selectedImage: $image, pickedPhoto: $pickedPhoto)
                                .environmentObject(viewModel)// Binding image, the returned image is sent back to this view
                        }
                    }
                    
                    Text(viewModel.currentUser?.userName ?? "Username")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 30)
                }
                .disabled(viewModel.showEditWindow)
                
                
                List {
                    
                    Section(header: Text("Account Info")){
                        ForEach(AccountOptions.allCases){ option in
                            HStack {
                                Text(option.title)
                                Spacer()
                                Text(viewModel.getUserDisplayStrInfo(with: option))
                                    .font(.subheadline)
                                    .foregroundStyle(Color(.systemGray2))
                            }
                            .onTapGesture {
                                viewModel.curStateAccount = option
                                viewModel.editInfoWindowTitle = option.title
                                viewModel.editInfoWindowPlaceHolder = option.placeholder
                                viewModel.showEditWindow = true
                            }
                        }
                    }
                    
                    Section(header: Text("Dietary Info")){
                        ForEach(DietaryInfoOptions.allCases){ option in
                            HStack {
                                Text(option.title)
                                Spacer()
                                Text(viewModel.getUserDietaryInfo(with: option))
                                    .font(.subheadline)
                                    .foregroundStyle(Color(.systemGray2))
                            }
                            .onTapGesture {
                                viewModel.curStateDietary = option
                                viewModel.editInfoWindowTitle = option.title
                                viewModel.editInfoWindowPlaceHolder = option.placeholder
                                viewModel.showEditWindow = true
                            }
                        }
                    }
                    
                }
                .disabled(viewModel.showEditWindow)
            }
            .blur(radius: viewModel.showEditWindow ? 5 : 0)
            
            if viewModel.showEditWindow {
                EditInfoView
            }
            
        }// End of Z Stack
        
    }
    
    /// The view to show a popup for editing user info.
    var EditInfoView: some View {
        VStack {
            VStack {
                Text(viewModel.editInfoWindowTitle)
                    .font(.title3)
                    .padding(.top, 10)
                if viewModel.editInfoWindowTitle == "Change Target Calories" {
                    TextField(viewModel.editInfoWindowPlaceHolder, text: $viewModel.strToChange)
                        .keyboardType(.numberPad)
                } else {
                    TextField(viewModel.editInfoWindowPlaceHolder, text: $viewModel.strToChange)
                }
                Divider()
                HStack(alignment: .center, spacing: 50) {
                    Button {
                        viewModel.showEditWindow = false
                    } label: {
                        Text("Cancel")
                    }
                    Divider()
                    Button { // Save the title
                        Task {
                            try await viewModel.updateInfo(with: viewModel.curStateAccount, with: viewModel.curStateDietary, strInfo: viewModel.strToChange)
                            viewModel.strToChange = ""
                            viewModel.curStateAccount = nil
                            viewModel.curStateDietary = nil
                        }
                        viewModel.showEditWindow = false
                        
                    } label: {
                        Text("Save")
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(width: 300, height: 120)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
}


/// The view to show the profile picture.
struct ProfileImageView: View {
    var image: Image
   
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5)
                .foregroundColor(.gray)
                .frame(width: 100, height: 100)
            image
               .resizable().scaledToFill()
               .frame(width: 100, height: 100)
               .clipShape(Circle())
        }
   }
}


#Preview {
    EditProfileView(showingProfileInfo: .constant(true))
        .environmentObject(ProfileViewModel())
}






