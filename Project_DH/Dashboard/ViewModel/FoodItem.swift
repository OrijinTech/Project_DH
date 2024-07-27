//
//  FoodItem.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/27/24.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift


class FoodItem: Codable, Identifiable {
    @DocumentID var id: String?
    var mealId: String
    var calorieNumber: Int
    var foodName: String
    var imageURL: String

    init(mealId: String, calorieNumber: Int, foodName: String, imageURL: String) {
        self.mealId = mealId
        self.calorieNumber = calorieNumber
        self.foodName = foodName
        self.imageURL = imageURL
    }

    func toDictionary() -> [String: Any] {
        
        let calorieString = String(self.calorieNumber)
        
        print("The food info is : \(mealId), \(calorieString), \(foodName), \(imageURL)")
        return [
            "mealId": mealId,
            "calorieNumber": calorieString,
            "foodName": foodName,
            "imageURL": imageURL
        ]
    }
}






