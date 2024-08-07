//
//  FoodItem.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/27/24.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift


class FoodItem: Codable, Identifiable, Equatable {
    
    /// The uid of the food item.
    @DocumentID var id: String?
    /// The associated meal id which this food item belongs to.
    var mealId: String
    /// The calorie number of this food item.
    var calorieNumber: Int
    /// The name of the food item.
    var foodName: String
    /// The image url of the food item picture.
    var imageURL: String
    /// The percentage of food item consumed
    var percentageConsumed: Int?

    
    init(mealId: String, calorieNumber: Int, foodName: String, imageURL: String, percentage: Int) {
        self.mealId = mealId
        self.calorieNumber = calorieNumber
        self.foodName = foodName
        self.imageURL = imageURL
        self.percentageConsumed = percentage
    }
    
    
    /// Conform to Equatable protocol
    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    /// This function turns the FoodItem object into a dictionary format. This is usually used for encoding.
    /// - Parameters: none
    /// - Returns: dictionary of String to Any
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






