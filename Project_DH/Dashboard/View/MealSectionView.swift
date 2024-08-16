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
    @Binding var showEditPopup: Bool
    @Binding var selectedFoodItem: FoodItem?
    /// var selectedFoodItemId = ""
    
    
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
                        selectedFoodItem = foodItem
                        showEditPopup = true
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(foodItem.foodName)
                                Text("Calories: \(foodItem.calorieNumber)")
                            }
                            .padding(.trailing, 20)
                            
                            Spacer()
                            
                            // Food Percentage Eaten
                            Text("\(String(foodItem.percentageConsumed ?? 100))%")
                            
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
                    }
                    .swipeActions { // Swipe to delete
                        Button(role: .destructive) {
                            deleteFoodItem(foodItem: foodItem)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                                .foregroundStyle(Color.red)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5))
                    .onDrag {
                        NSItemProvider(object: foodItem.id! as NSString)
                    }
                }
                .onInsert(of: ["public.text"], perform: handleDrop)
            } // End of List View
            .frame(height: CGFloat(foodItems.count) * 150) // Adjust height based on the number of items
            .padding(.horizontal, -20)
        }
        .padding(.vertical)
    }
    
    
    /// This function handles the drop logic for food item
    /// - Parameters:
    ///     - index: The index of food item need to be drop
    ///     - itemProviders: used for indicating the item we are processing
    /// - Returns: A DateFormatter object.
    private func handleDrop(index: Int, itemProviders: [NSItemProvider]) {
        for provider in itemProviders {
            provider.loadObject(ofClass: NSString.self) { item, error in
                DispatchQueue.main.async {
                    if let foodItemId = item as? String {
                        Task {
                            print("I am moving food item to \(title)")
                            await viewModel.moveFoodItem(to: title, foodItemId: foodItemId)
                        }
                    }
                }
            }
        }
    }
    
    
    /// This function classifies each fetched food item by calling the fetchFoodItems function.
    /// - Parameters:
    ///     - foodItem: The food item to delete.
    /// - Returns: none
    func deleteFoodItem(foodItem: FoodItem) {
        let imageUrl = foodItem.imageURL
        calorieNum -= foodItem.calorieNumber
        foodItems = viewModel.deleteFoodItem(foodItems: foodItems, item: foodItem)
        Task {
            do {
                try await ImageManipulation.deleteImageOnFirebase(imageURL: imageUrl)
            } catch {
                print("ERROR: Error deleting image. \nSource: MealSectionView/deleteFoodItem()")
            }
        }
        if foodItems.count == 0 {
            viewModel.deleteMeal(mealID: foodItem.mealId)
        }
    }
    
    
}


#Preview {
    struct Preview: View {
            @State var calNum = 10
            @State var foodItems = [FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150", percentage: 100)]
            @State var showEditPopup = false
            @State var selectedFoodItem: FoodItem?

            var body: some View {
                MealSectionView(title: "Sample Meal", foodItems: $foodItems, calorieNum: $calNum, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
            }
        }
        return Preview()
}
