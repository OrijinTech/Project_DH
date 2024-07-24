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
    
    enum SourceType {
        case camera
        case photoLibrary
    }
    var body: some View {
        NavigationStack {
            VStack {
                ZStack{
                    if let image = image{
                        CircularImageView(image: image)
                            .onAppear {
                                getCalories(for: image)
                            }
                    }else{
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
                }
                
            }
            .navigationTitle("ADD A MEAL")
            .navigationBarTitleDisplayMode(.inline)
            
        } // End of Navigation Stack
    }// End of body
    
    
    func getCalories(for image: UIImage) {
        Task {
            do {
                try await viewModel.generateCalories(for: image)
            } catch {
                print(error)
            }
        }
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





