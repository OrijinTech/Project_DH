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

    var body: some View {
        ZStack {
            // Background overlay to detect taps outside the card
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
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

                    TextField("Calories", value: Binding(
                        get: { foodItem.calorieNumber },
                        set: { foodItem.calorieNumber = $0 }
                    ), formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .padding()

                    Button("Save") {
                        Task {
                            await viewModel.updateFoodItem(foodItem)
                            isPresented = false
                        }
                    }
                    .padding()
                    .frame(maxWidth: 150)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))
            }
        }
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
