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
import FirebaseFirestoreSwift

class DashboardViewModel: ObservableObject {
    @Published var meals = [Meal]()
    
    @Published var breakfastItems = [FoodItem]()
    @Published var lunchItems = [FoodItem]()
    @Published var dinnerItems = [FoodItem]()
    @Published var snackItems = [FoodItem]()
    
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
    
    private func startObservingUser() {
        cancellable = profileViewModel.$currentUser
            .compactMap { $0?.uid } // Only proceed if currentUser.uid is non-nil
            .sink { [weak self] uid in
                self?.fetchMeals(for: uid)
            }
    }
    
    func fetchMeals(for userId: String, on date: Date? = nil) {
        let dateToFetch = date ?? Date()
        isLoading = true
        Task {
            do {
                try await mealServices.fetchMeals(for: userId, on: dateToFetch)
                DispatchQueue.main.async {
                    self.meals = self.mealServices.meals
                    self.categorizeFoodItems()
                    self.isLoading = false
                    self.isRefreshing = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to fetch meals: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    private func categorizeFoodItems() {
        DispatchQueue.main.async {
            self.breakfastItems = []
            self.lunchItems = []
            self.dinnerItems = []
            self.snackItems = []
        }
        
        for meal in meals {
            fetchFoodItems(mealId: meal.id ?? "", mealType: meal.mealType)
        }
    }
    
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
                    print("NOTE: Fetching breakfast items: \(self.breakfastItems)")
                case "lunch":
                    self.lunchItems = foodItems
                    print("NOTE: Fetching lunch items:\(self.lunchItems)")
                case "dinner":
                    self.dinnerItems = foodItems
                    print("NOTE: Fetching dinner items: \(self.dinnerItems)")
                case "snack":
                    self.snackItems = foodItems
                    print("NOTE: Fetching snack items: \(self.snackItems)")
                default:
                    print("NOTE: Unknown meal type")
                }
            }
        }
    }
}
