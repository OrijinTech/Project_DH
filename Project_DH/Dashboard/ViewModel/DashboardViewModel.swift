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
    
    private func fetchMeals(for userId: String) {
        isLoading = true
        Task {
            do {
                try await mealServices.fetchMeals(for: userId)
                DispatchQueue.main.async {
                    self.meals = self.mealServices.meals
                    self.isLoading = false
                }
            } catch {
                print("Failed to fetch meals: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}
