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
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
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
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
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
    func saveFoodItem(image: UIImage, completion: @escaping (Error?) -> Void) async throws{
        guard let imageUrl = try? await FoodItemImageUploader.uploadImage(image) else {
            print("ERROR: FAILED TO GET imageURL! Source: saveFoodItem() ")
            return
        }
        
        let cal = self.calories!
        let calorie_int = Int(cal)!
        let food = FoodItem(calorieNumber: calorie_int, foodName: self.mealName, imageURL: imageUrl)

        let foodData = food.toDictionary()
        try await self.db.collection("foodItems").addDocument(data: foodData)
        
    }
    
    
}
