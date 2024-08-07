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
    
    private var cancellable: AnyCancellable?
    private var mealServices = MealServices()
    private var db = Firestore.firestore()
    
    init() {
        startObservingUser()
    }
    
    /// Observe changes to current user and perform an action when the user ID (uid) changes
    /// - Parameters: none
    /// - Returns: none
    private func startObservingUser() {
        cancellable = profileViewModel.$currentUser
            .compactMap { $0?.uid } // Only proceed if currentUser.uid is non-nil
            .sink { [weak self] uid in
                self?.fetchMeals(for: uid)
            }
    }
    
    
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
                    self.categorizeFoodItems() // Also fetching food items here
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
    



    
    
    
}
