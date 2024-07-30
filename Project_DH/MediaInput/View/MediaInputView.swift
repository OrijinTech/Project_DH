//
//  MediaInputView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/21/24.
//


import SwiftUI
import PhotosUI
struct MediaInputView: View {
    @StateObject var viewModel = MediaInputViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    @State private var image: UIImage?
    @State private var isConfirmationDialogPresented: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: SourceType = .camera
    @State private var pickedPhoto: Bool = false
    @State private var isProcessingMealInfo = false
    @State private var savePressed = false
    
    
    
    enum SourceType {
        case camera
        case photoLibrary
    }
    var body: some View {
        NavigationStack {
            ZStack {
                // TODO: Maybe make the loading screen nicer.
                // While processing meal info, show loading screen
                if isProcessingMealInfo {
                    ProgressView("Processing your food :-)")
                        .padding()
                } else {
                    VStack {
                        VStack{
                            TextField("Meal", text: $viewModel.mealName)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.top, 12)
                        }
                        Spacer()
                        
                        ZStack{
                            CircularImageView(image: image ?? UIImage(resource: .plus))
                                .onChange(of: image) {
                                    if image != UIImage(resource: .plus){
                                        getMealInfo(for: image!)
                                    }
                                }
                        }
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
                                FoodImagePicker(isPresented: $isImagePickerPresented, image: $image, sourceType: .camera)
                            }else{
                                FoodPhotoPicker(selectedImage: $image, pickedPhoto: $pickedPhoto)
                            }
                        }
                        .padding(.bottom)
                        
                        HStack{
                            Text("Calories Detected: \(viewModel.calories ?? "0")")
                                .font(.title3)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 50)
                        
                        // Save Meal Button
                        Button {
                            savePressed = true
                            Task {
                                defer {
                                    savePressed = false
                                }
                                
                                if let userId = profileViewModel.currentUser?.uid {
                                    do {
                                        // Save the food item
                                        try await viewModel.saveFoodItem(image: image!, userId: userId) { error in
                                            if let error = error {
                                                print("ERROR: \(error.localizedDescription)")
                                            } else {
                                                print("SUCCESS: Food Saved!")
                                            }
                                        }
                                    } catch {
                                        print("ERROR: \(error.localizedDescription)")
                                    }
                                }
                                self.image = UIImage(resource: .plus)
                                viewModel.imageChanged = false
                            }
                        } label: {
                            Text("Save Meal                                                     ")
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 180, height: 45)
                        .background(.brand)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.vertical)
                        .shadow(radius: 3)
                        .disabled(!viewModel.imageChanged || isProcessingMealInfo || savePressed)
                        
                        Spacer()
                    }
                    .disabled(viewModel.showMessageWindow)
                    .blur(radius: viewModel.showMessageWindow ? 5 : 0)
                    .navigationTitle("ADD A MEAL")
                    .navigationBarTitleDisplayMode(.inline)
                    
                    if viewModel.showMessageWindow {
                        PopUpMessageView(messageTitle: "Success!", message: "Your food item is saved.", isPresented: $viewModel.showMessageWindow)
                            .animation(.easeInOut, value: viewModel.showMessageWindow)
                    }
                    
                } // end of else statement
                
            } // End of ZStack
            
        } // End of Navigation Stack
        
    }// End of body
    
    
    func getMealInfo(for image: UIImage) {
        isProcessingMealInfo = true
        Task {
            do {
                print("NOTE: Prediction Started, please wait.")
                try await viewModel.generateCalories(for: image)
                try await viewModel.generateMealName(for: image)
            } catch {
                print(error)
            }
            isProcessingMealInfo = false
            viewModel.imageChanged = true
        }
    }
    
    
    func clearInputs() {
        self.image = nil
        viewModel.calories = "0"
        viewModel.mealName = ""
    }
    
    
}

#Preview {
    MediaInputView()
}


struct CircularImageView: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable().scaledToFill()
            .frame(width: 200, height: 200)
            .clipShape(Circle())
    }
}








