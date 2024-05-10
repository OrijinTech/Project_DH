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
        
        do {
            let _ = try await storageRef.putDataAsync(imageData)
            let url = try await storageRef.downloadURL()
            return url.absoluteString
        } catch {
            print("ERROR: FAILED TO UPLOAD PROFILE PHOTO")
            return nil
        }
    }
    
    
}
