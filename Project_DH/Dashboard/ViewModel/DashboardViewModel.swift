//
//  DashboardViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//


import Foundation
import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published var meals = [Meal]()
    @Published var isLoading = true
    @Published var profileViewModel = ProfileViewModel()
    @Published var selectedDate = Date()
    
    private var cancellable: AnyCancellable? // To manage the subscription
    private var mealServices = MealServices()
    
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
        let dateToFetch = date ?? Date() // Use the provided date or default to system current date
        isLoading = true
        // print("I am loading the data. The userId is \(userId). And the date is \(date)")
        Task {
            do {
                try await mealServices.fetchMeals(for: userId, on: dateToFetch)
                DispatchQueue.main.async {
                    self.meals = self.mealServices.meals
                    print("meals are \(self.meals)")
                    self.isLoading = false
                }
            } catch {
                // print("Failed to fetch meals: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}
