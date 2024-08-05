//
//  MealSectionView.swift
//  Project_DH
//
//  Created by mac on 2024/7/31.
//

import SwiftUI


struct MealSectionView: View {
    var title: String
    var foodItems: [FoodItem]
    @Binding var calorieNum: Int
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.leading)

            ForEach(foodItems) { foodItem in
                HStack {
                    VStack(alignment: .leading) {
                        Text(foodItem.foodName)
                        Text("Calories: \(foodItem.calorieNumber)")
                            .onAppear {
                                print("ADDING CALORIES")
                                calorieNum += foodItem.calorieNumber
                            }
                    }
                    
                    Spacer()
                    
                    AsyncImage(url: URL(string: foodItem.imageURL)) { phase in
                        switch phase {
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        default:
                            ProgressView("Loading...")
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal)
                .frame(height: 80)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
            }
        }
        .padding(.vertical)
    }
}


#Preview {
    struct Preview: View {
        @State var calNum = 10
        var body: some View {
            MealSectionView(title: "Sample Meal", foodItems: [FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150")], calorieNum: $calNum)
        }
    }
    return Preview()
}
