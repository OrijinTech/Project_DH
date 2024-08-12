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
            }
            
        }
    }
    
    
    func moveFoodItem(to targetMealType: String, foodItemId: String) async {
        print("I am calling this moveFoodItem funciton")
        print("And the foodItemId is \(foodItemId)")
        print("Dinner items I have numbers of : \(self.dinnerItems.count)")
        print("Dinner items I have these: \(self.dinnerItems)")
        print("Breakfast items: \(self.breakfastItems.map { $0.id })")
        print("Lunch items: \(self.lunchItems.map { $0.id })")
        print("Dinner items: \(self.dinnerItems.map { $0.id })")
        print("Snack items: \(self.snackItems.map { $0.id })")
        print("The meals I have now are : \(meals.count)")
        
        
        guard let foodItem = getFoodItem(by: foodItemId) else { return }

        // Determine if a new meal needs to be created
        var targetMealId: String? = meals.first(where: { $0.mealType.lowercased() == targetMealType.lowercased() })?.id

        print("I am working towards it now!!!")
        if targetMealId == nil {
            // Create a new meal for the target type
            let meal = Meal(date: Date(), mealType: targetMealType, userId: profileViewModel.currentUser?.uid ?? "")
            do {
                targetMealId = try await createMeal(meal: meal)
            } catch {
                print("Error creating meal: \(error)")
                return
            }
        }

        print("Here I have mealId \(foodItem.mealId)")
        print("The mealId I am moving to is \(targetMealId)")
        // Move the food item to the new meal
        foodItem.mealId = targetMealId!
        do {
            try await db.collection("foodItems").document(foodItemId).setData(from: foodItem)
            // Refresh the meals and food items
            await fetchMeals(for: profileViewModel.currentUser?.uid ?? "")
        } catch {
            print("ERROR: Failed to move food item: \(error.localizedDescription)")
        }
       
    }
    
    
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
    
    
    private func createMeal(meal: Meal) async throws -> String {
        let document = try db.collection("meal").addDocument(from: meal)
        return document.documentID
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
