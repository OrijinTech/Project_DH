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
import FirebaseFunctions


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
    @Published var selectedMealType: MealType?
    @Published var selectedDate = Date()
    
    
    private let db = Firestore.firestore()
    private let functions = Functions.functions()
    
    
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
        let downsizedImg = ImageManipulation.downSizeImage(for: image)
        
        guard let imageUrl = try await FoodItemImageUploader.uploadImage(downsizedImg!) else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image to Firebase"])
        }
        print("IMAGE URL: \(imageUrl)")
        
        let result = try await functions.httpsCallable("validFoodItem").call(["imageUrl": imageUrl])
        if let data = result.data as? [String: Any], let isValid = data["valid"] as? Bool {
            try await ImageManipulation.deleteImageOnFirebase(imageURL: imageUrl)
            print("VALID: \(isValid)")
            return isValid
        } else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response from the server"])
        }
    }
    
    
    /// This function calls the OpenAI API to estimate the calories in the given food item image.
    /// - Parameters:
    ///     - for: the image of the food item
    /// - Returns: none
    func generateCalories(for image: UIImage) async throws {
        print("NOTE: Predicting Calories..")
        let downsizedImg = ImageManipulation.downSizeImage(for: image)
        
        guard let imageUrl = try await FoodItemImageUploader.uploadImage(downsizedImg!) else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image to Firebase"])
        }
        
        let result = try await functions.httpsCallable("generateCalories").call(["imageUrl": imageUrl])
        if let data = result.data as? [String: Any], let calories = data["calories"] as? String {
            await MainActor.run {
                print("NOTE: Finished Predicting Calories: \(calories)")
                let calorie_string = "\(calories)"
                let cal_num = extractNumber(from: calorie_string)
                self.calories = cal_num
                self.predictedCalories = cal_num
            }
        } else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response from the server"])
        }
        
        try await ImageManipulation.deleteImageOnFirebase(imageURL: imageUrl)
    }
    
    
    /// This function calls the OpenAI API to estimate the name of the given food item image.
    /// - Parameters:
    ///     - for: the image of the food item
    /// - Returns: none
    func generateMealName(for image: UIImage) async throws {
        print("NOTE: Generating the meal name.")
        let downsizedImg = ImageManipulation.downSizeImage(for: image)
        
        guard let imageUrl = try await FoodItemImageUploader.uploadImage(downsizedImg!) else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image to Firebase"])
        }

        let result = try await functions.httpsCallable("generateMealName").call(["imageUrl": imageUrl])
        if let data = result.data as? [String: Any], let mealName = data["mealName"] as? String {
            await MainActor.run {
                self.mealName = mealName
            }
        } else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response from the server"])
        }
        
        try await ImageManipulation.deleteImageOnFirebase(imageURL: imageUrl)
    }
    
    
    /// This function saves the food item to Firebase.
    /// - Parameters:
    ///     - image: the image of the food item
    ///     - userId: the current user's id
    ///     - date: the date which the item will be saved to
    /// - Returns: none
    @MainActor
    func saveFoodItem(image: UIImage, userId: String, date: Date, completion: @escaping (Error?) -> Void) async throws {
        guard let imageUrl = try? await FoodItemImageUploader.uploadImage(image) else {
            print("ERROR: FAILED TO GET imageURL! \nSource: saveFoodItem() ")
            return
        }
        
        if selectedMealType == nil {
            selectedMealType = determineMealType()
        }
        
        let mealType = selectedMealType!
        
        print("NOTE: MealType is \(mealType). \nSource: MealInputViewModel/saveFoodItem()")
        checkForExistingMeal(userId: userId, mealType: mealType, date: date) { existingMeal in
            if let meal = existingMeal {
                self.createFoodItem(mealId: meal.id!, imageUrl: imageUrl, completion: completion)
                print("NOTE: I am creating a new food item! \nSource: MealInputViewModel/saveFoodItem()")
            } else {
                self.createNewMeal(userId: userId, mealType: mealType, date: date) { newMealId in
                    if let mealId = newMealId {
                        self.createFoodItem(mealId: mealId, imageUrl: imageUrl, completion: completion)
                    } else {
                        completion(NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create meal"]))
                    }
                }
                print("NOTE: I am creating a new meal and food item!, \nSource: MealInputViewModel/saveFoodItem()")
            }
        }
        self.showMessageWindow = true
    }
    
    
    /// This function determines the meal type based on the current time.
    /// - Parameters: none
    /// - Returns: The string of the meal type.
    func determineMealType() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<10:
            return .breakfast
        case 11..<14:
            return .lunch
        case 17..<21:
            return .dinner
        default:
            return .snack
        }
    }
    
    
    /// This function checks if the  meal already exists for the current user and meal type. Ex.: If the user already have food items in breakfast, it means that the breakfast meal type already exists.
    /// - Parameters:
    ///     - userId: the current user's id
    ///     - mealType: the meal type to check for repetitiveness
    ///     - date: the date which the item will be checked against
    /// - Returns: none
    func checkForExistingMeal(userId: String, mealType: String, date: Date, completion: @escaping (Meal?) -> Void) {
        let calendar = Calendar.current
        let currentDate = date
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("meal")
            .whereField("userId", isEqualTo: userId)
            .whereField("mealType", isEqualTo: mealType)
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("ERROR: Failed to get documents: \(error) \nSource: MealInputViewModel/checkForExistingMeal()")
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
    ///     - date: the date when you want your meal to be created
    /// - Returns: none
    func createNewMeal(userId: String, mealType: String, date: Date, completion: @escaping (String?) -> Void) {
        let meal = Meal(date: date, mealType: mealType, userId: userId)
        print("Meal date is \(meal.date)")
        print("Meal type is \(meal.mealType)")
        do {
            let newDocRef = try db.collection("meal").addDocument(from: meal)
            completion(newDocRef.documentID)
        } catch {
            print("ERROR: Failed to create new meal. \(error) \nSource: MealInputViewModel/createNewMeal()")
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
        print("NOTE: Clearing Inputs")
        self.image = UIImage(resource: .plus)
        self.selectedDate = Date()
        self.imageChanged = false
        self.predictedCalories = nil
        self.sliderValue = 100.0
        self.calories = nil
        self.mealName = ""
        self.selectedMealType = nil
    }
    
    
}


