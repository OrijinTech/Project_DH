//
//  MealSectionView.swift
//  Project_DH
//
//  Created by mac on 2024/7/31.
//

import SwiftUI


struct MealSectionView: View {
    
    @ObservedObject var viewModel = DashboardViewModel()
    var title: String
    @Binding var foodItems: [FoodItem]
    @Binding var calorieNum: Int
    var selectedFoodItemId = ""
    @Binding var meals: [Meal]
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.leading)
            
            List {
                ForEach(foodItems) { foodItem in
                    Button(action: {
                        // action here for selecting the food item
                    }) {
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
//                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                    .swipeActions { // Swipe to delete
                        Button(role: .destructive) {
                            calorieNum -= foodItem.calorieNumber
                            foodItems = viewModel.deleteFoodItem(foodItems: &foodItems, item: foodItem)
                            if foodItems.count == 0 {
                                viewModel.deleteMeal(mealID: foodItem.mealId)
                            }
                            if meals.count == 0 {
                                meals = [Meal]() // TODO: STILL NOT SHOWING "NO MEALS" when no meal detected.
                            }
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5))
                }
            }// End of List View
//            .listStyle(PlainListStyle())
            .frame(height: CGFloat(foodItems.count) * 150) // Adjust height based on the number of items
            .padding(.horizontal, -20)
        }
        .padding(.vertical)
    }
}


#Preview {
    struct Preview: View {
        @State var calNum = 10
        @State var foodItems = [FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150")]
        @State var meals = [Meal]()
        var body: some View {
            MealSectionView(title: "Sample Meal", foodItems: $foodItems, calorieNum: $calNum, meals: $meals)
        }
    }
    return Preview()
}
