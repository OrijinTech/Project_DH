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


class MealInputViewModel: ObservableObject {
    @Published var calories: String?
    @Published var predictedCalories: String?
    @Published var image: UIImage?
    @Published var mealName = ""
    @Published var showMessageWindow = false
    @Published var isLoading = false
    @Published var imageChanged = false
    @Published var showInputError = false
    @Published var sliderValue: Double = 100.0
    
    private let db = Firestore.firestore()
    
    
    /// This function loads the configuration information from the config.plist.
    /// - Parameters: none
    /// - Returns: The configuration in the form of dictionary [String : Any].
    /// - Note: This is our way of getting the OpenAI API Key. This file is in gitignore.
    func loadConfig() -> [String: Any]? {
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let config = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any] {
            return config
        }
        return nil
    }
    
    
    /// This function checks if the food item photo is a valid input.
    /// - Parameters:
    ///     - for: the image of the food item
    /// - Returns: Boolean value whether the food item is a valid input to the AI model.
    func validFoodItem(for image: UIImage) async throws -> Bool {
        print("NOTE: Checking whether the food item is a valid input.")
        
        // Get API Key
        guard let config = loadConfig(),
              let apiKey = config["OpenAI_API_KEY"] as? String else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key not set"])
        }
        let openAI = OpenAI(apiToken: apiKey)
        
        // Improve the prompt to match our needs.
        var promptList: [ChatQuery.ChatCompletionMessageParam] = [
            .user(.init(content: .string("You are a nutrition expert. Please tell me if the image contains any types of food."))),
            .user(.init(content: .string("Please only give YES or NO answer."))),
            .user(.init(content: .string("If you are not sure, then answer NO.")))
        ]
        
        let processedImage = resizeImage(image: image, targetSize: CGSize(width: 224, height: 224))
        
        if var imageData = processedImage.jpegData(compressionQuality: 1.0) {
            var quality: CGFloat = 1.0
            let megabyte = 15
            let maxSize: Int = megabyte * 1024 * 1024 // 15MB in bytes
            let imgParam = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam(content: .vision([.chatCompletionContentPartImageParam(.init(imageUrl: .init(url: imageData, detail: .high)))]))
            // Keep reducing the image quality until the image is below maxSize(15) MB
            while imageData.count > maxSize && quality > 0 {
                print("NOTE: Image larger than \(megabyte) MB, reducing the image quality...")
                quality -= 0.1
                if let compressedData = processedImage.jpegData(compressionQuality: quality) {
                    imageData = compressedData
                } else {
                    break
                }
            }
            promptList.append(.user(imgParam))
        }
        
        let query = ChatQuery(messages: promptList, model: .gpt4_o)
        let result = try await openAI.chats(query: query)
        let response = result.choices.first?.message.content?.string?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        return response?.contains("YES") ?? false
    }
    
    
    /// This function calls the OpenAI API to estimate the calories in the given food item image.
    /// - Parameters:
    ///     - for: the image of the food item
    /// - Returns: none
    func generateCalories(for image: UIImage) async throws {
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
        
        if var imageData = processedImage.jpegData(compressionQuality: 1.0) {
            var quality: CGFloat = 1.0
            let megabyte = 15
            let maxSize: Int = megabyte * 1024 * 1024 // 15MB in bytes
            let imgParam = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam(content: .vision([.chatCompletionContentPartImageParam(.init(imageUrl: .init(url: imageData, detail: .high)))]))
            // Keep reducing the image quality until the image is below maxSize(15) MB
            while imageData.count > maxSize && quality > 0 {
                print("NOTE: Image larger than \(megabyte) MB, reducing the image quality...")
                quality -= 0.1
                if let compressedData = processedImage.jpegData(compressionQuality: quality) {
                    imageData = compressedData
                } else {
                    break
                }
            }
            promptList.append(.user(imgParam))
        }
        
        let query = ChatQuery(messages: promptList, model: .gpt4_o)
        
        let result = try await openAI.chats(query: query)
        let calorie_string = result.choices.first?.message.content?.string ?? "Unknown"
        // String
        let cal_num = extractNumber(from: calorie_string)
        
        await MainActor.run {
            self.predictedCalories = cal_num
            self.calories = cal_num
        }
    }
    
    
    /// This function calls the OpenAI API to estimate the name of the given food item image.
    /// - Parameters:
    ///     - for: the image of the food item
    /// - Returns: none
    func generateMealName(for image: UIImage) async throws {
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
        
        if var imageData = processedImage.jpegData(compressionQuality: 1.0) {
            var quality: CGFloat = 1.0
            let megabyte = 15
            let maxSize: Int = megabyte * 1024 * 1024 // 15MB in bytes
            let imgParam = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam(content: .vision([.chatCompletionContentPartImageParam(.init(imageUrl: .init(url: imageData, detail: .high)))]))
            // Keep reducing the image quality until the image is below maxSize(15) MB
            while imageData.count > maxSize && quality > 0 {
                print("NOTE: Image larger than \(megabyte) MB, reducing the image quality...")
                quality -= 0.1
                if let compressedData = processedImage.jpegData(compressionQuality: quality) {
                    imageData = compressedData
                } else {
                    break
                }
            }
            promptList.append(.user(imgParam))
        }
        
        let query = ChatQuery(messages: promptList, model: .gpt4_o)
        let result = try await openAI.chats(query: query)
        let foodName = result.choices.first?.message.content?.string
        
        await MainActor.run {
            self.mealName = foodName ?? "Unknown Food Name"
        }
    }
    
    
    /// This function saves the food item to Firebase.
    /// - Parameters:
    ///     - image: the image of the food item
    ///     - userId: the current user's id
    /// - Returns: none
    @MainActor
    func saveFoodItem(image: UIImage, userId: String, completion: @escaping (Error?) -> Void) async throws {
        guard let imageUrl = try? await FoodItemImageUploader.uploadImage(image) else {
            print("ERROR: FAILED TO GET imageURL! \nSource: saveFoodItem() ")
            return
        }
        
        let mealType = determineMealType()
        print("mealType is \(mealType)")
        checkForExistingMeal(userId: userId, mealType: mealType) { existingMeal in
            if let meal = existingMeal {
                self.createFoodItem(mealId: meal.id!, imageUrl: imageUrl, completion: completion)
                print("I am creating a new food item!")
            } else {
                self.createNewMeal(userId: userId, mealType: mealType) { newMealId in
                    if let mealId = newMealId {
                        self.createFoodItem(mealId: mealId, imageUrl: imageUrl, completion: completion)
                    } else {
                        completion(NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create meal"]))
                    }
                }
                print("I am creating a new meal and food item!")
            }
        }
        self.showMessageWindow = true
    }
    
    
    /// This function determines the meal type based on the current time.
    /// - Parameters: none
    /// - Returns: The string of the meal type.
    func determineMealType() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        print("It is hour \(hour)")
        switch hour {
        case 6..<10:
            return "Breakfast"
        case 11..<14:
            return "Lunch"
        case 17..<21:
            return "Dinner"
        default:
            return "Snack"
        }
    }
    
    
    /// This function checks if the  meal already exists for the current user and meal type. Ex.: If the user already have food items in breakfast, it means that the breakfast meal type already exists.
    /// - Parameters:
    ///     - userId: the current user's id
    ///     - mealType: the meal type to check for repetitiveness
    /// - Returns: none
    func checkForExistingMeal(userId: String, mealType: String, completion: @escaping (Meal?) -> Void) {
        let calendar = Calendar.current
        let currentDate = Date()
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("meal")
            .whereField("userId", isEqualTo: userId)
            .whereField("mealType", isEqualTo: mealType)
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)
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
    
    
    /// This function creates a new meal on the Firebase.
    /// - Parameters:
    ///     - userId: the current user's id
    ///     - mealType: the meal type to create
    /// - Returns: none
    func createNewMeal(userId: String, mealType: String, completion: @escaping (String?) -> Void) {
        let meal = Meal(date: Date(), mealType: mealType, userId: userId)
        print("Meal date is \(meal.date)")
        print("Meal type is \(meal.mealType)")
        do {
            let newDocRef = try db.collection("meal").addDocument(from: meal)
            completion(newDocRef.documentID)
        } catch {
            print("Error creating meal: \(error)")
            completion(nil)
        }
    }
    
    
    /// This function creates a new food item on the Firebase.
    /// - Parameters:
    ///     - mealId: the meal id which this food item belongs to
    ///     - imageUrl: the food item's image url
    /// - Returns: none
    func createFoodItem(mealId: String, imageUrl: String, completion: @escaping (Error?) -> Void) {
        guard let calories = Int(self.calories ?? "0") else {
            completion(NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid calorie number"]))
            return
        }
        print("The mealName is \(self.mealName)")
        
        let foodItem = FoodItem(mealId: mealId, calorieNumber: Int(calories), foodName: self.mealName, imageURL: imageUrl, percentage: Int(self.sliderValue))
        do {
            let _ = try db.collection("foodItems").addDocument(from: foodItem)
            self.clearInputs()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    
    /// Calculate the calories based on the slider value picked by the user.
    /// - Parameters:none
    /// - Returns: none
    func calorieIntakePercentage() {
        self.calories = String(Int((Double(self.predictedCalories ?? "0") ?? 0) * self.sliderValue / 100))
    }
    
    
    /// This function is for clearing all user inputs on the MealInputView.
    /// - Parameters: none
    /// - Returns: none
    func clearInputs() {
        print("Clearing Inputs")
        self.image = UIImage(resource: .plus)
        self.predictedCalories = nil
        self.sliderValue = 100.0
        self.calories = nil
        self.mealName = ""
    }
    
    
}


