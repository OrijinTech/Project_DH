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
    @StateObject var dashboardViewModel = DashboardViewModel()
    @State private var isConfirmationDialogPresented: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: SourceType = .camera
    @State private var pickedPhoto: Bool = false
    @State private var isProcessingMealInfo = false
    @State private var savePressed = false
    @State private var showingDatePicker = false
    @State private var originalDate: Date = Date()
    
    enum SourceType {
        case camera
        case photoLibrary
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    // TODO: Maybe make the loading screen nicer.
                    // While processing meal info, show loading screen
                    if isProcessingMealInfo {
                        ProgressView("Processing your food :-)")
                            .padding()
                    } else {
                        VStack {
                            ZStack{
                                FoodPictureView(image: viewModel.image ?? UIImage(resource: .plus))
                                    .onChange(of: viewModel.image) {
                                        if viewModel.image != UIImage(resource: .plus){
                                            getMealInfo(for: viewModel.image!)
                                        }
                                    }
                                
                                VStack {
                                    HStack {
                                        Text("Calories Detected: \(viewModel.calories ?? "0")")
                                            .font(.title3)
                                            .padding(.leading, 25)
                                        
                                        if let calories = viewModel.calories, calories != "0" {
                                            Text("(\(String(Int(viewModel.sliderValue)))%)")
                                        }
                                        
                                        Spacer()
                                    }
                                    .frame(width: 270, height: 40)
                                    .background((Color.white).opacity(0.9).shadow(.drop(color: .primary.opacity(0.15), radius: 4)), in: .rect(cornerRadius: 5))
                                    .padding()
                                    .opacity(viewModel.image == UIImage(resource: .plus) || viewModel.image == nil ? 0 : 1)
                                }
                                .padding(.top, 300)
                                .padding(.trailing, 190)
                                
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
                                    FoodImagePicker(isPresented: $isImagePickerPresented, image: $viewModel.image, sourceType: .camera)
                                }else{
                                    FoodPhotoPicker(selectedImage: $viewModel.image, pickedPhoto: $pickedPhoto)
                                }
                            }
                            .padding(.bottom)
                            
                            VStack {
                                VStack{
                                    TextField("What did you eat?", text: $viewModel.mealName)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .font(.title2)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("\(DateTools().formattedDate(viewModel.selectedDate))")
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .font(.title2)
                                        .multilineTextAlignment(.center)
                                        .padding(.vertical, 12)
                                }
                                
                                // Slider to pick percentage of the calories.
                                HStack {
                                    Text("0%")
                                    Slider(value: $viewModel.sliderValue, in: 0...100, step: 1)
                                                    .frame(width: 170)
                                                    .disabled(!viewModel.imageChanged || isProcessingMealInfo || savePressed)
                                                    .onChange(of: viewModel.sliderValue) {
                                                        viewModel.calorieIntakePercentage()
                                                    }
                                    Text("100%")
                                }
                                .frame(width: 270)
                                .padding(.bottom, 30)
                                
                                // Select Meal Type
                                DropDownMenu(selection: $viewModel.selectedMealType, hint: viewModel.determineMealType(), options: [.breakfast, .lunch, .dinner, .snack], anchor: .top)
                                    .padding(.bottom, 40)
                                    .disabled(isProcessingMealInfo || savePressed)
                                
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
                                                try await viewModel.saveFoodItem(image: viewModel.image!, userId: userId, date: viewModel.selectedDate) { error in
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
                                        viewModel.image = UIImage(resource: .plus)
                                        viewModel.imageChanged = false
                                    }
                                } label: {
                                    Text(LocalizedStringKey("Save Meal                                                     "))
                                }
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(width: 180, height: 45)
                                .background(.brandDarkGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.bottom, 3)
                                .shadow(radius: 3)
                                .disabled(!viewModel.imageChanged || isProcessingMealInfo || savePressed)
                                .opacity(!viewModel.imageChanged || isProcessingMealInfo || savePressed ? 0.6 : 1.0)
                                
                                // Reset inputs
                                Button {
                                    viewModel.clearInputs()
                                    savePressed = false
                                } label: {
                                    Text(LocalizedStringKey("Cancel"))
                                        .foregroundStyle(.black)
                                        .frame(width: 180, height: 45)
                                }
                                .background((Color.white).shadow(.drop(color: .primary.opacity(0.15), radius: 4)), in: .rect(cornerRadius: 8))
                                .disabled(savePressed || isProcessingMealInfo)
                                .opacity(savePressed || isProcessingMealInfo ? 0.6 : 1.0)
                                
                                
                                Spacer()
                            }

                        }
                        .disabled(viewModel.showMessageWindow)
                        .blur(radius: viewModel.showMessageWindow ? 5 : 0)
                        .navigationTitle("ADD A MEAL")
                        .navigationBarTitleDisplayMode(.inline)
                        .disabled(savePressed)
                        
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
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        CalendarView(selectedDate: $viewModel.selectedDate, originalDate: $originalDate, showingPopover: $showingDatePicker, viewModel: dashboardViewModel, fetchOnDone: false)
                            .disabled(isProcessingMealInfo || savePressed)
                            .opacity(isProcessingMealInfo || savePressed ? 0 : 1.0)
                    }
                })
            } // End of Scroll View

            
        } // End of Navigation Stack
        .onTapGesture {
            UIApplication.shared.hideKeyboard()  // Dismiss the keyboard on any tap
        }
        
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
                    viewModel.clearInputs()
                    viewModel.showInputError = true
                }
                
            } catch {
                print(error)
            }
            isProcessingMealInfo = false
        }
    }
    
    
}


/// This is the view for displaying the image in a circular border.
struct FoodPictureView: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable().scaledToFill()
            .frame(minWidth: 200, maxHeight: 400)
            .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}


#Preview {
    MealInputView()
}










