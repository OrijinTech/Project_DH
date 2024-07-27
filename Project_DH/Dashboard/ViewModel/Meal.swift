//
//  MealModel.swift
//  Project_DH
//
//  Created by mac on 2024/7/26.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift

struct Meal: Decodable, Identifiable, Encodable {
    @DocumentID var id: String?
    var date: Date
    var mealType: String
    var userId: String
}
