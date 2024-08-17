//
//  FoodItemEditView.swift
//  Project_DH
//
//  Created by mac on 2024/8/8.
//
// FoodItemEditView.swift
import SwiftUI

struct FoodItemEditView: View {
    @Binding var foodItem: FoodItem?
    @Binding var isPresented: Bool
    @Binding var calorieNum: Int
    @ObservedObject var viewModel: DashboardViewModel

    @State private var originalFoodName: String = ""
    @State private var originalCalorieNumber: Int = 0
    @State private var originalCalorieSum: Int = 0
    
    var body: some View {
        ZStack {
            // Background overlay to detect taps outside the card
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if let foodItem = foodItem {
                        // Reset to original values
                        foodItem.foodName = originalFoodName
                        foodItem.calorieNumber = originalCalorieNumber
                        calorieNum = originalCalorieSum
                    }
                    isPresented = false
                }

            // Card view
            if let foodItem = foodItem {
                VStack {
                    AsyncImage(url: URL(string: foodItem.imageURL)) { phase in
                        switch phase {
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        default:
                            ProgressView("Loading...")
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    TextField("Food Name", text: Binding(
                        get: { foodItem.foodName },
                        set: { foodItem.foodName = $0 }
                    ))
                    .multilineTextAlignment(.center)
                    .padding()

                    VStack() {
                        HStack {
                            Text("Calories:")
                            Spacer()
                            TextField("", value: Binding(
                                get: { foodItem.calorieNumber },
                                set: { newValue in
                                    viewModel.wholeFoodItem = false
                                    let difference = newValue - foodItem.calorieNumber
                                    calorieNum += difference
                                    foodItem.calorieNumber = newValue
                                }
                            ), formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                        }
                        
                        Toggle("All Eaten:", isOn: $viewModel.wholeFoodItem)
                            .toggleStyle(SwitchToggleStyle(tint: .brand))
                            .font(.custom("custom", size: 15))
                    }
                    .padding(.horizontal, 35)

                    Button("Save") {
                        Task {
                            foodItem.percentageConsumed = calcNewPercentage(for: Double(originalCalorieNumber))
                            await viewModel.updateFoodItem(foodItem)
                            viewModel.fetchMeals(for: viewModel.profileViewModel.currentUser?.uid ?? "", on: viewModel.selectedDate)
                            viewModel.wholeFoodItem = false
                            isPresented = false
                        }
                    }
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 8)
                .frame(maxWidth: 300)
                .onAppear {
                    // Store the original values when the view appears
                    originalFoodName = foodItem.foodName
                    originalCalorieNumber = foodItem.calorieNumber
                    originalCalorieSum = calorieNum
                }
                .onTapGesture {
                    // Prevent tap propagation to the background
                }
            }
        }// End of ZStack
        .onTapGesture {
            UIApplication.shared.hideKeyboard()  // Dismiss the keyboard on any tap
        }
    }
    
    
    /// Calculates the new percentage of the consumed food item.
    /// - Parameters: 
    ///     - for calNum:  The original calorie number of the food item before modification.
    /// - Returns: The percentage calculated.
    func calcNewPercentage(for calNum: Double) -> Int {
        guard let foodItem = foodItem, foodItem.percentageConsumed != 0 else {
            return 0 // Return 0 or any appropriate default value if percentageConsumed is 0 or foodItem is nil.
        }
        let originalCalories = Double(calNum) / (Double(foodItem.percentageConsumed!)/100)
        let percentage = Double(foodItem.calorieNumber) / originalCalories * 100
        if viewModel.wholeFoodItem {
            foodItem.calorieNumber = Int(round(originalCalories))
        }
        if percentage > 100 || viewModel.wholeFoodItem {
            return 100
        }
        return Int(round(percentage))
    }
    
}

#Preview {
    struct Preview: View {
        @State var foodItem: FoodItem? = FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150", percentage: 100)
        @State var isPresented = true
        @State var calorieNum = 100
        var viewModel = DashboardViewModel()

        var body: some View {
            FoodItemEditView(foodItem: $foodItem, isPresented: $isPresented, calorieNum: $calorieNum, viewModel: viewModel)
        }
    }
    return Preview()
}
