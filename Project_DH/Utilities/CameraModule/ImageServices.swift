//
//  ImageServices.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//

import Foundation
import Firebase
import FirebaseStorage
import OpenAI


/// This struct is for uploading general images.
struct ImageUploader {
    
    /// Handles the logic for uploading images onto the Firebase.
    /// - Parameters:
    ///     - image: The image to upload.
    /// - Returns: Returns the optional url of the string which was saved to Firebase.
    static func uploadImage(_ image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return nil }
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        print("SUCCESS: STORAGE REFERENCE RETRIEVED: \(storageRef)")
        
        do {
            let _ = try await storageRef.putDataAsync(imageData)
            let url = try await storageRef.downloadURL()
            print("SUCCESS: UPLOADED USER PROFILE PHOTO WITH URL: \(url)")
            clearCache()
            return url.absoluteString
        } catch {
            print("ERROR: FAILED TO UPLOAD PROFILE PHOTO! \nSource: uploadImage() \n\(error.localizedDescription) ")
            return nil
        }
    }
    
}


struct PhotoUploader {
    
    static func uploadImage(_ image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return nil }
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        do {
            let _ = try await storageRef.putDataAsync(imageData)
            let url = try await storageRef.downloadURL()
            clearCache()
            return url.absoluteString
        } catch {
            print("ERROR: FAILED TO UPLOAD PROFILE PHOTO \nSource: ImageServices/PhotoUploader/uploadImage()")
            return nil
        }
    }
    
}


/// This struct is for uploading food item images.
struct FoodItemImageUploader {
    
    /// Handles the logic for uploading images onto the Firebase.
    /// - Parameters:
    ///     - image: The image to upload.
    /// - Returns: Returns the optional url of the string which was saved to Firebase.
    static func uploadImage(_ image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return nil }
        
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "/foodItem/\(filename)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg" // Set the content type
        print("SUCCESS: STORAGE REFERENCE RETRIEVED: \(storageRef)")
        
        do {
            let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            let url = try await storageRef.downloadURL()
            print("SUCCESS: UPLOADED FOOD ITEM PHOTO WITH URL: \(url)")
            clearCache() // clears the cache after sending the image.
            return url.absoluteString
        } catch {
            print("ERROR: FAILED TO FOOD ITEM PHOTO. \nSource: uploadImage() \n\(error.localizedDescription) ")
            return nil
        }
    }
    
}


struct ImageManipulation {
    
    /// Deletes the image on Firebase Storage with a given image url.
    /// - Parameters:
    ///     - fimageURL: The string of the raw image URL.
    /// - Returns: none
    static func deleteImageOnFirebase(imageURL: String) async throws{
        guard let url = URL(string: imageURL) else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }

        // Extract the path from the URL
        let path = extractPath(from: url)
        let storageRef = Storage.storage().reference(withPath: path)
        
        do {
            try await storageRef.delete()
        } catch {
            print("ERROR: FAILED TO DELETE FILE AT PATH: \(path) \n\(error.localizedDescription) \nSource: ImageServices/ImageManipulation/deleteImageOnFirebase()")
            throw error
        }
    }
    
    
    /// Extracts the relative path for Firebase Storage from a given url.
    /// - Parameters:
    ///     - from: the raw url of the image stored on Firebase Storage.
    /// - Returns: String of the relative path.
    static func extractPath(from url: URL) -> String {
        // Firebase storage URLs typically have 'o/' before the path
        let pathComponents = url.pathComponents
        if let index = pathComponents.firstIndex(of: "o") {
            let componentsAfterO = pathComponents.dropFirst(index + 1)
            let path = componentsAfterO.joined(separator: "/")
            return path
        }
        return ""
    }
    
    
    /// Downsizes the given image.
    /// - Parameters:
    ///     - from: The UI Image to downsize.
    /// - Returns: Optional UI Image which is downsized.
    static func downSizeImage(for image: UIImage) -> UIImage? {
        // Resize the image to the target size
        let processedImage = resizeImage(image: image, targetSize: CGSize(width: 112, height: 112))
        
        // Start with the highest quality compression
        var quality: CGFloat = 1.0
        let megabyte = 15
        let maxSize: Int = megabyte * 1024 * 1024 // 15MB in bytes
        
        // Compress the image data until it's below the max size
        var imageData = processedImage.jpegData(compressionQuality: quality)
        while let data = imageData, data.count > maxSize && quality > 0 {
            print("NOTE: Image larger than \(megabyte) MB, reducing the image quality...")
            quality -= 0.1
            imageData = processedImage.jpegData(compressionQuality: quality)
        }
        
        // If we have valid image data, return the downsized image
        if let finalImageData = imageData, let downsizedImage = UIImage(data: finalImageData) {
            return downsizedImage
        }
        
        // Return nil if the image processing fails
        return nil
    }
    
    
    /// Converts the image to base64 string.
    /// - Parameters:
    ///     - from: The image to turn into base64.
    /// - Returns: The String format of the image.
    static func toBase64String(image: UIImage, compressionQuality: CGFloat = 1.0) -> String? {
        // Convert the image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            print("ERROR: Failed to convert UIImage to JPEG data.")
            return nil
        }
        // Encode the data to Base64 string
        return "data:image/jpeg;base64,\(imageData.base64EncodedString())"
    }
    

    
}
