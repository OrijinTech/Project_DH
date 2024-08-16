//
//  DashboardViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift


class DashboardViewModel: ObservableObject {
    @Published var meals = [Meal]()
    
    @Published var breakfastItems = [FoodItem]()
    @Published var lunchItems = [FoodItem]()
    @Published var dinnerItems = [FoodItem]()
    @Published var snackItems = [FoodItem]()
    @Published var sumCalories = 0
    @Published var exceededCalorieTarget = false
    @Published var wholeFoodItem = false
    
    @Published var isLoading = true
    @Published var isRefreshing = false
    @Published var profileViewModel = ProfileViewModel()
    @Published var selectedDate = Date()
    
    
    @Published var cancellable: AnyCancellable?
    private var mealServices = MealServices()
    private var db = Firestore.firestore()
    
    
    /// This function fetches all meals for a given user id for a designated day.
    /// - Parameters:
    ///     - for: user's id
    ///     - on: the date on which meals are fetched
    /// - Returns: none
    func fetchMeals(for userId: String, on date: Date? = nil) {
        let dateToFetch = date ?? Date()
        isLoading = true
        Task {
            do {
                try await mealServices.fetchMeals(for: userId, on: dateToFetch)
                DispatchQueue.main.async {
                    self.meals = self.mealServices.meals
                    self.categorizeFoodItems()
                    self.sumCalories = 0
                    self.isLoading = false
                    self.isRefreshing = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("ERROR: Failed to fetch meals: \(error.localizedDescription) \nSource: DashboardViewModel/fetchMeals()")
                    self.isLoading = false
                }
            }
        }
    }
    
    
    /// Checks whether the current calorie intake exceeded the user's target.
    /// - Parameters: none
    /// - Returns: Bool
    func checkCalorieTarget() {
        if let calTarget = profileViewModel.currentUser?.targetCalories {
            print("NOTE: FIRST TRUE \(calTarget), \(self.sumCalories)")
            
            if Int(calTarget) == 0 {
                exceededCalorieTarget = false
            } else {
                exceededCalorieTarget = Int(calTarget)! < self.sumCalories
            }
        } else {
            exceededCalorieTarget = false
        }

    }
    
    
    func sumUpCalories(for foodItems: [FoodItem]) {
        for foodItem in foodItems {
            sumCalories += foodItem.calorieNumber
        }
    }
    
    
    /// This function classifies each fetched food item by calling the fetchFoodItems function.
    /// - Parameters: none
    /// - Returns: none
    /// - Note: This function will clear all food items inside breakfastItems, lunchItems, dinnerItems, and snackItems list.
    private func categorizeFoodItems() {
        DispatchQueue.main.async {
            self.breakfastItems = []
            self.lunchItems = []
            self.dinnerItems = []
            self.snackItems = []
        }
        // For each meal (breakfast, lunch...), get all corresponding food items.
        for meal in meals {
            fetchFoodItems(mealId: meal.id ?? "", mealType: meal.mealType)
        }
        print("I have number of meals: \(meals.count)")

    }
    
    
    /// This function fetches all food items based on their id and meal types.
    /// - Parameters:
    ///     - mealId: the meal id
    ///     - mealType: the type of the meal (breakfast, lunch, dinner, snack)
    /// - Returns: none
    private func fetchFoodItems(mealId: String, mealType: String) {
        db.collection("foodItems").whereField("mealId", isEqualTo: mealId).getDocuments { querySnapshot, error in
            if let _ = error {
                DispatchQueue.main.async {
                    print("ERROR: Failed to fetch food items. \nSource: DashboardViewModel/fetchFoodItems()")
                }
                return
            }
            guard let documents = querySnapshot?.documents else {
                DispatchQueue.main.async {
                    print("ERROR: No food items found. \nSource: DashboardViewModel/fetchFoodItems()")
                }
                return
            }
            
            let foodItems = documents.compactMap { queryDocumentSnapshot -> FoodItem? in
                return try? queryDocumentSnapshot.data(as: FoodItem.self)
            }
            
            DispatchQueue.main.async {
                switch mealType.lowercased() {
                case "breakfast":
                    self.breakfastItems = foodItems
                    print("NOTE: Fetched breakfast items: \(self.breakfastItems)")
                case "lunch":
                    self.lunchItems = foodItems
                    print("NOTE: Fetched lunch items:\(self.lunchItems)")
                case "dinner":
                    self.dinnerItems = foodItems
                    print("NOTE: Fetched dinner items: \(self.dinnerItems)")
                case "snack":
                    self.snackItems = foodItems
                    print("NOTE: Fetched snack items: \(self.snackItems)")
                default:
                    print("NOTE: Unknown meal type")
                }
                self.sumUpCalories(for: foodItems)
                self.checkCalorieTarget()
            }
            
        }
    }
    
    
    /// This function handle the drag and drop food item logic from one list to another list
    /// - Parameters:
    ///     - targetMealType: the meal type list we are moving to (ex. breakfast, dinner ..)
    ///     - foodItemId: the food item id we are moving
    /// - Returns: none
    func moveFoodItem(to targetMealType: String, foodItemId: String) async {
        if let foodItem = getFoodItem(by: foodItemId) {
            // Determine if a new meal needs to be created
            var targetMealId: String? = meals.first(where: { $0.mealType.lowercased() == targetMealType.lowercased() })?.id
            
            if targetMealId == nil {
                // Create a new meal for the target type
                let meal = Meal(date: Date(), mealType: targetMealType, userId: profileViewModel.currentUser?.uid ?? "")
                targetMealId = createNewMeal(meal: meal)
            }
            // Move the food item to the new meal
            let originalMealId  = foodItem.mealId
            foodItem.mealId = targetMealId!
            do {
                try db.collection("foodItems").document(foodItemId).setData(from: foodItem)
                //TODO: check if orginal mealtype has no foodItem left, if so then delete the meal
                // Fetch remaining food items in the original meal
                let remainingFoodItems = try await db.collection("foodItems")
                    .whereField("mealId", isEqualTo: originalMealId)
                    .getDocuments()
                if remainingFoodItems.isEmpty {
                    // If no items are left, delete the original meal
                    deleteMeal(mealID: originalMealId)
                }
            } catch {
                print("ERROR: Failed to move food item: \(error.localizedDescription)")
            }
            // Refresh the meals and food items
            DispatchQueue.main.async {
                self.fetchMeals(for: self.profileViewModel.currentUser?.uid ?? "", on: self.selectedDate)
            }
        } else {
            print("foodItem not found when moving food item!")
        }
       
    }
    
    
    /// This function helps to get the foodItem from the list
    /// - Parameters:
    ///     - id: The foodItem id
    /// - Returns: The foodItem found from the meal list
    private func getFoodItem(by id: String) -> FoodItem? {
        print("Searching for FoodItem with id: \(id)")

        if let item = self.breakfastItems.first(where: { $0.id == id }) {
            print("Found in breakfastItems: \(item.foodName)")
            return item
        }
        if let item = self.lunchItems.first(where: { $0.id == id }) {
            print("Found in lunchItems: \(item.foodName)")
            return item
        }
        if let item = self.dinnerItems.first(where: { $0.id == id }) {
            print("Found in dinnerItems: \(item.foodName)")
            return item
        }
        if let item = self.snackItems.first(where: { $0.id == id }) {
            print("Found in snackItems: \(item.foodName)")
            return item
        }

        print("No FoodItem found with id: \(id)")
        return nil
    }

    
    /// This function create a new meal into the Firebase
    /// - Parameters:
    ///     - meal: The meal item to add
    /// - Returns: The new mealId created by the Firebase
    func createNewMeal(meal: Meal) -> String {
        do {
            let documentRef = try db.collection("meals").addDocument(from: meal)
            return documentRef.documentID
        } catch {
            print("Error creating new meal: \(error.localizedDescription)")
            return ""
        }
    }
    
    
    /// This function deletes the food item from a list of food items, and removes from the Firebase.
    /// - Parameters:
    ///     - foodItems: List of food items.
    ///     - item: The food item to delete.
    /// - Returns: The updated food item list.
    func deleteFoodItem(foodItems: [FoodItem], item: FoodItem) -> [FoodItem]{
        var updatedFoodItems = foodItems
        guard let id = item.id else {return updatedFoodItems}
        db.collection("foodItems").document(id).delete()
        if let index = updatedFoodItems.firstIndex(of: item) {
            updatedFoodItems.remove(at: index)
        }
        return updatedFoodItems
    }
    
    
    /// This function deletes the meal from the meals list, and removes from the Firebase.
    /// - Parameters:
    ///     - mealID: The meal id of the meal to delete.
    /// - Returns: none
    func deleteMeal(mealID: String) {
        print("NOTE: Deleting Meal ID: \(mealID)")
        db.collection("meal").document(mealID).delete()
        if let index = meals.firstIndex(where: { $0.id == mealID }) {
            meals.remove(at: index)
        }
    }
    
    
    /// This function update the foodItem from the foodItem list
    /// - Parameters:
    ///     - foodItem: The foodItem
    /// - Returns: none
    func updateFoodItem(_ foodItem: FoodItem) async {
        guard let id = foodItem.id else { return }
        do {
            try db.collection("foodItems").document(id).setData(from: foodItem)
        } catch {
            print("ERROR: Failed to update food item: \(error.localizedDescription)")
        }
    }
    
    
}
