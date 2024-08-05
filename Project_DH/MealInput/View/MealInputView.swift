//
//  MediaInputView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/21/24.
//


import SwiftUI
import PhotosUI


struct MealInputView: View {
    @StateObject var viewModel = MealInputViewModel()
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
                                                print("ERROR: Save meal button \n\(error.localizedDescription)")
                                            } else {
                                                print("SUCCESS: Food Saved!")
                                            }
                                        }
                                    } catch {
                                        print("ERROR: Save meal button \n\(error.localizedDescription)")
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
                    
                    if viewModel.showInputError {
                        PopUpMessageView(messageTitle: "Apologies", message: "Your image does not contain any food, please try again.", isPresented: $viewModel.showInputError)
                            .animation(.easeInOut, value: viewModel.showInputError)
                    }
                    
                } // end of else statement
                
            } // End of ZStack
            
        } // End of Navigation Stack
        
    }// End of body
    
    
    /// This function handles the logic for requesting the food item information from the AI.
    /// - Parameters:
    ///     - for: the image of the food item
    /// - Returns: none
    func getMealInfo(for image: UIImage) {
        isProcessingMealInfo = true
        Task {
            do {
                print("NOTE: Prediction Started, please wait.")
                if try await viewModel.validFoodItem(for: image) { // check if the image contains food
                    try await viewModel.generateCalories(for: image)
                    try await viewModel.generateMealName(for: image)
                    viewModel.imageChanged = true
                }
                else {
                    // clear input
                    clearInputs()
                    viewModel.showInputError = true
                    viewModel.imageChanged = false
                }
                
            } catch {
                print(error)
            }
            isProcessingMealInfo = false
        }
    }
    
    
    /// This function is for clearing all user inputs on the MealInputView.
    /// - Parameters: none
    /// - Returns: none
    func clearInputs() {
        self.image = UIImage(resource: .plus)
        viewModel.calories = "0"
        viewModel.mealName = ""
    }
    
    
}


/// This is the view for displaying the image in a circular border.
struct CircularImageView: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable().scaledToFill()
            .frame(width: 200, height: 200)
            .clipShape(Circle())
    }
}


#Preview {
    MealInputView()
}










