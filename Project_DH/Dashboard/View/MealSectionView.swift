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
                .padding(.top, 20)
            
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
                    .padding(.vertical, 10)
                    .listRowInsets(EdgeInsets())
                    .swipeActions { // Swipe to delete
                        Button(role: .destructive) {
                            deleteFoodItem(foodItem: foodItem)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                                .foregroundStyle(Color.red)
                        }
                    }
                    .onDrag {
                        NSItemProvider(object: foodItem.id! as NSString)
                    }
                } // End of For each
                .onInsert(of: ["public.text"], perform: handleDrop)

            } // End of List View
            .frame(minHeight: CGFloat(foodItems.count) * 100 + 40) // Adjust height based on the number of items (each row + padding)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x:2, y:2)
            .scrollContentBackground(.hidden)  // Hide default background
            .padding(.top, -35)
            .scrollDisabled(true) // Disable scrolling
            .padding(.bottom, 30)
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color("brandLightGreen"), Color("brandDarkGreen")]), startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.5), radius: 10, x:0, y:2)
        .padding(.bottom, 40)
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
            @State var foodItems = [FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150", percentage: 100), FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150", percentage: 100),FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150", percentage: 100)]
            @State var showEditPopup = false
            @State var selectedFoodItem: FoodItem?

            var body: some View {
                MealSectionView(title: "Sample Meal", foodItems: $foodItems, calorieNum: $calNum, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
            }
        }
        return Preview()
}
