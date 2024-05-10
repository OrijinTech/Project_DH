//
//  PhotoServices.swift
//  DH_App
//
//  Created by Yongxiang Jin on 5/10/24.
//

import Foundation
import SwiftUI
import PhotosUI



// ===================================================================================================================================================================
//                                                                             USER IMAGE PICKERS
// ===================================================================================================================================================================
// ImagePicker struct is a SwiftUI wrapper around UIImagePickerController
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool  // Binding to control the presentation of the image picker
    @Binding var image: UIImage?    // Binding to hold the selected image
    var sourceType: UIImagePickerController.SourceType// Specifies the source type for the image picker (camera or photo library)
    
    // This method creates a Coordinator instance which handles the delegation of UIImagePickerController
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // This method creates a UIImagePickerController instance and sets its delegate and source type
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator  // Set the delegate to handle image picker events
        picker.sourceType = sourceType // Set the source type (camera or photo library)
        return picker
    }
    
    // This method is used to update the UIImagePickerController when SwiftUI view updates, but not used in this example
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    
    // Coordinator class to handle the delegate methods of UIImagePickerController
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent:ImagePicker  // Reference to the parent ImagePicker struct
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        
        // This delegate method is called when an image is selected
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {// Retrieve the selected image
                parent.image = uiImage
            }
            parent.isPresented = false// Dismiss the image picker
        }
        
        // This delegate method is called when the image picker is cancelled
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false // Dismiss the image picker
        }
    }
}

// PhotoPicker struct is a SwiftUI wrapper around PHPickerViewController, which is a modern replacement for UIImagePickerController for picking photos from the library
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?  // Binding to hold the selected image
    @EnvironmentObject var viewModel: ProfileViewModel
    @Binding var pickedPhoto: Bool
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent:PhotoPicker // Reference to the parent PhotoPicker struct
        
        init(parent: PhotoPicker) {
            self.parent = parent
        }
        
        // This delegate method is called when an image is selected
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let result = results.first{
                result .itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let uiImage = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImage = uiImage // Assign the selected image to the parent's `selectedImage` property
                            self.parent.viewModel.profileImage = Image(uiImage: uiImage)
                            self.parent.viewModel.uiImage = uiImage
                            self.parent.pickedPhoto = true
                        }
                    }
                }
            }
            picker.dismiss(animated: true,completion: nil) // Dismiss the photo picker
            
        }
    }
    
    
    
    // This method creates a Coordinator instance which handles the delegation of PHPickerViewController
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
        
    }
    
    // This method creates a PHPickerViewController instance with specified configurations
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        
        configuration.selectionLimit = 1// Limiting selection to one image
        configuration .filter = .images // Filtering for images only
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator // Set the delegate to handle photo picker events
        return picker
        
    }
    
    // This method is used to update the PHPickerViewController when SwiftUI view updates, but not used in this example
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
}



// ======================================================================================================================================================================
//                                                                             FOOD IMAGE PICKERS
// ======================================================================================================================================================================


// ImagePicker struct is a SwiftUI wrapper around UIImagePickerController
struct FoodImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool  // Binding to control the presentation of the image picker
    @Binding var image: UIImage?    // Binding to hold the selected image
    var sourceType: UIImagePickerController.SourceType// Specifies the source type for the image picker (camera or photo library)
    
    // This method creates a Coordinator instance which handles the delegation of UIImagePickerController
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // This method creates a UIImagePickerController instance and sets its delegate and source type
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator  // Set the delegate to handle image picker events
        picker.sourceType = sourceType // Set the source type (camera or photo library)
        return picker
    }
    
    // This method is used to update the UIImagePickerController when SwiftUI view updates, but not used in this example
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    
    // Coordinator class to handle the delegate methods of UIImagePickerController
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent:FoodImagePicker  // Reference to the parent ImagePicker struct
        init(parent: FoodImagePicker) {
            self.parent = parent
        }
        
        
        // This delegate method is called when an image is selected
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {// Retrieve the selected image
                parent.image = uiImage
            }
            parent.isPresented = false// Dismiss the image picker
        }
        
        // This delegate method is called when the image picker is cancelled
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false // Dismiss the image picker
        }
    }
}


// PhotoPicker struct is a SwiftUI wrapper around PHPickerViewController, which is a modern replacement for UIImagePickerController for picking photos from the library
struct FoodPhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?  // Binding to hold the selected image
    @Binding var pickedPhoto: Bool
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: FoodPhotoPicker // Reference to the parent PhotoPicker struct
        
        init(parent: FoodPhotoPicker) {
            self.parent = parent
        }
        
        // This delegate method is called when an image is selected
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let result = results.first{
                result .itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let uiImage = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImage = uiImage // Assign the selected image to the parent's `selectedImage` property
                            self.parent.pickedPhoto = true
                        }
                    }
                }
            }
            picker.dismiss(animated: true,completion: nil) // Dismiss the photo picker
            
        }
    }
    
    
    
    // This method creates a Coordinator instance which handles the delegation of PHPickerViewController
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
        
    }
    
    // This method creates a PHPickerViewController instance with specified configurations
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        
        configuration.selectionLimit = 1// Limiting selection to one image
        configuration .filter = .images // Filtering for images only
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator // Set the delegate to handle photo picker events
        return picker
        
    }
    
    // This method is used to update the PHPickerViewController when SwiftUI view updates, but not used in this example
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
}
