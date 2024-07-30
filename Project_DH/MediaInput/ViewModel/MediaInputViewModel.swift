//
//  MediaInputViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/24/24.
//

import Foundation
import OpenAI
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import FirebaseStorage

class MediaInputViewModel: ObservableObject {
    @Published var calories: String?
    @Published var mealName = ""
    @Published var showMessageWindow = false
    @Published var isLoading = false
    @Published var imageChanged = false
    
    private let db = Firestore.firestore()
    
    
    // Get OpenAI API Key from config.plist (in gitignore)
    func loadConfig() -> [String: Any]? {
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let config = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any] {
            return config
        }
        return nil
    }
    
    
    // TODO: The pipeline for calling the calorie generation, and at the same time calling the firestore database to store the photo.
    func getCalories(for image: UIImage){
        print("pass")
    }
    
    
    // OpenAI API call for generating output based on image/text input
    // TODO: Camera-GPT-Input Implementation, refer to notion task
    func generateCalories(for image: UIImage) async throws{
        print("NOTE: Predicting Calories..")
        
        // Get API Key
        guard let config = loadConfig(),
              let apiKey = config["OpenAI_API_KEY"] as? String else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key not set"])
        }
        let openAI = OpenAI(apiToken: apiKey)
        
        // Improve the prompt to match our needs.
        var promptList: [ChatQuery.ChatCompletionMessageParam] = [
            .user(.init(content: .string("You are a nutrition expert. Please calculate the calories of the provided image."))),
            .user(.init(content: .string("Please only provide the calorie number, do not give any textual explanation.")))
        ]
        
        let processedImage = resizeImage(image: image, targetSize: CGSize(width: 224, height: 224))
        
        if let imageData = processedImage.jpegData(compressionQuality: 0.5) {
                    let imgParam = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam(content: .vision([.chatCompletionContentPartImageParam(.init(imageUrl: .init(url: imageData, detail: .high)))]))
                    promptList.append(.user(imgParam))
                }
        
        let query = ChatQuery(messages: promptList, model: .gpt4_o)
        
        let result = try await openAI.chats(query: query)
        let calorie_string = result.choices.first?.message.content?.string ?? "Unknown"
        // String
        let cal_num = extractNumber(from: calorie_string)
        
        await MainActor.run {
            self.calories = cal_num
        }
    }
    
    
    func generateMealName(for image: UIImage) async throws{
        print("NOTE: Generating the meal name.")
        
        // Get API Key
        guard let config = loadConfig(),
              let apiKey = config["OpenAI_API_KEY"] as? String else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key not set"])
        }
        let openAI = OpenAI(apiToken: apiKey)
        
        // Improve the prompt to match our needs.
        var promptList: [ChatQuery.ChatCompletionMessageParam] = [
            .user(.init(content: .string("You are a nutrition expert. Please predict the name of the food."))),
            .user(.init(content: .string("Please only provide the name of the food"))),
        ]
        
        let processedImage = resizeImage(image: image, targetSize: CGSize(width: 224, height: 224))
        
        if let imageData = processedImage.jpegData(compressionQuality: 1.0) {
                    let imgParam = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam(content: .vision([.chatCompletionContentPartImageParam(.init(imageUrl: .init(url: imageData, detail: .high)))]))
                    promptList.append(.user(imgParam))
                }
        
        let query = ChatQuery(messages: promptList, model: .gpt4_o)
        let result = try await openAI.chats(query: query)
        let foodName = result.choices.first?.message.content?.string
        
        await MainActor.run {
            self.mealName = foodName ?? "Unknown Food Name"
        }
    }
    
    
    // Saving the food Item to Firebase
    @MainActor
    func saveFoodItem(image: UIImage, userId: String, completion: @escaping (Error?) -> Void) async throws {
        guard let imageUrl = try? await FoodItemImageUploader.uploadImage(image) else {
            print("ERROR: FAILED TO GET imageURL! Source: saveFoodItem() ")
            return
        }
        
        let mealType = determineMealType()
        checkForExistingMeal(userId: userId, mealType: mealType) { existingMeal in
            if let meal = existingMeal {
                self.createFoodItem(mealId: meal.id!, imageUrl: imageUrl, completion: completion)
            } else {
                self.createNewMeal(userId: userId, mealType: mealType) { newMealId in
                    if let mealId = newMealId {
                        self.createFoodItem(mealId: mealId, imageUrl: imageUrl, completion: completion)
                    } else {
                        completion(NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create meal"]))
                    }
                }
            }
        }
        self.showMessageWindow = true
    }
    
    // Determine the meal type based on the current time
    func determineMealType() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<10:
            return "Breakfast"
        case 10..<14:
            return "Lunch"
        case 17..<21:
            return "Dinner"
        default:
            return "Snack"
        }
    }
    
    // Check if a meal exists for the current user and meal type
    func checkForExistingMeal(userId: String, mealType: String, completion: @escaping (Meal?) -> Void) {
        db.collection("meal")
            .whereField("userId", isEqualTo: userId)
            .whereField("mealType", isEqualTo: mealType)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion(nil)
                } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                    if let meal = try? documents.first?.data(as: Meal.self) {
                        completion(meal)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
    }
    
    // Create a new meal document
    func createNewMeal(userId: String, mealType: String, completion: @escaping (String?) -> Void) {
        let meal = Meal(date: Date(), mealType: mealType, userId: userId)
        do {
            let newDocRef = try db.collection("meal").addDocument(from: meal)
            completion(newDocRef.documentID)
        } catch {
            print("Error creating meal: \(error)")
            completion(nil)
        }
    }
    
    // Helper function to create a FoodItem document
    func createFoodItem(mealId: String, imageUrl: String, completion: @escaping (Error?) -> Void) {
        guard let calories = Int(self.calories ?? "0") else {
            completion(NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid calorie number"]))
            return
        }
        print("The mealName is \(self.mealName)")
        
        let foodItem = FoodItem(mealId: mealId, calorieNumber: Int(calories), foodName: self.mealName, imageURL: imageUrl)
        do {
            let _ = try db.collection("foodItems").addDocument(from: foodItem)
            self.calories = "0"
            self.mealName = ""
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    
}
