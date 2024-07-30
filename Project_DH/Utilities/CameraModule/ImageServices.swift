//
//  ImageServices.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//

import Foundation
import Firebase
import FirebaseStorage



struct ImageUploader {
    
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
            print("ERROR: FAILED TO UPLOAD PROFILE PHOTO")
            return nil
        }
    }
    
}




struct FoodItemImageUploader {
    
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
