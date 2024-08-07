//
//  MealModel.swift
//  Project_DH
//
//  Created by mac on 2024/7/26.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift

struct Meal: Decodable, Identifiable, Encodable, Equatable {
    /// The uid of the meal.
    @DocumentID var id: String?
    /// The date of creation for the meal.
    var date: Date
    /// The type of the meal.
    var mealType: String
    /// The associated user for the meal.
    var userId: String
}
