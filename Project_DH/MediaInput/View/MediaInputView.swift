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
    @State private var image: UIImage?
    @State private var isConfirmationDialogPresented: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: SourceType = .camera
    @State private var pickedPhoto: Bool = false
    @State private var isProcessingMealInfo = false
    
    
    enum SourceType {
        case camera
        case photoLibrary
    }
    var body: some View {
        NavigationStack {
            ZStack {
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
                        if let image = image{
                            CircularImageView(image: image)
                                .onAppear() {
                                    getMealInfo(for: image)
                                }
                        } else {
                            PlaceholderView()
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
                        Task {
                            do {
                                // Save the food item
                                try await viewModel.saveFoodItem(image: image!) { error in
                                    if let error = error {
                                        print("ERROR: \(error.localizedDescription)")
                                    } else {
                                        print("SUCCESS: Food Saved!")
                                    }
                                }
                                // Clear the image after saving
                                clearInputs()
                            } catch {
                                print("ERROR: \(error.localizedDescription)")
                            }
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
                    .disabled(image == nil || isProcessingMealInfo)
                    
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


struct PlaceholderView: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5)
                .foregroundColor(.gray)
                .frame(width: 200, height: 200)
            Image(systemName: "plus")
                .scaledToFit()
                .font(.system(size: 50))
                .foregroundColor(.gray)
        }
    }
}








