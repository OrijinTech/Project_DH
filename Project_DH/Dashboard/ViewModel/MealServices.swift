//
//  MealServices.swift
//  Project_DH
//
//  Created by mac on 2024/7/26.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class MealServices: ObservableObject {
    @Published var meals = [Meal]()
    private var db = Firestore.firestore()
    
    @MainActor
    func fetchMeals(for userId: String?) async throws {
        guard let userId = userId else { return }
        let querySnapshot = try await db.collection("meal").whereField("userId", isEqualTo: userId).getDocuments()
        self.meals = querySnapshot.documents.compactMap { document in
            try? document.data(as: Meal.self)
        }
    }
    
    func loadMockData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        meals = [
            Meal(id: "1", date: formatter.date(from: "2024/07/26 08:00")!, mealType: "Breakfast", userId: "user1"),
            Meal(id: "2", date: formatter.date(from: "2024/07/26 12:00")!, mealType: "Lunch", userId: "user1"),
            Meal(id: "3", date: formatter.date(from: "2024/07/26 19:00")!, mealType: "Dinner", userId: "user1"),
            Meal(id: "4", date: formatter.date(from: "2024/07/27 08:00")!, mealType: "Breakfast", userId: "user2"),
            Meal(id: "5", date: formatter.date(from: "2024/07/27 12:00")!, mealType: "Lunch", userId: "user2"),
            Meal(id: "6", date: formatter.date(from: "2024/07/27 19:00")!, mealType: "Dinner", userId: "user2")
        ]
    }
}
