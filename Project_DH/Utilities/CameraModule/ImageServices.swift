//
//  ImageServices.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//

import Foundation
import Firebase
import FirebaseStorage


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
        print("SUCCESS: STORAGE REFERENCE RETRIEVED: \(storageRef)")
        
        do {
            let _ = try await storageRef.putDataAsync(imageData)
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
