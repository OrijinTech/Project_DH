//
//  DashboardView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//

import SwiftUI


struct DashboardView: View {

    @ObservedObject var viewModel = DashboardViewModel()
    @State private var originalDate: Date = Date()
    @State private var showingPopover = false
    @State private var isGreetingVisible: Bool = true
    @State private var loadedFirstTime = false
    @State private var showEditPopup = false
    @State private var selectedFoodItem: FoodItem?
    
    
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    if viewModel.isLoading && loadedFirstTime == false {
                        ProgressView("Loading...")
                            .padding()
                            .onAppear {
                                loadedFirstTime = true
                            }
                    } else if viewModel.meals.isEmpty {
                        Text("No meals yet!")
                            .font(.headline)
                            .padding()
                    } else {
                        ScrollView {
                            // Show sum of calories                            
                            VStack(alignment: .center) {
                                if let targetCalories = viewModel.profileViewModel.currentUser?.targetCalories {
                                    ProgressBarView(targetCalories: Int(targetCalories)!, currentCalories: viewModel.sumCalories)
                                } else {
                                    Text("You Consumed \(viewModel.sumCalories) Calories Today")
                                        .font(.title)
                                        .padding(.top, 10)
                                }
                                if viewModel.exceededCalorieTarget {
                                    Text(LocalizedStringKey("Be careful, you exceeded your calorie limit!"))
                                        .foregroundStyle(Color.red)
                                        .font(.subheadline)
                                }
                                
                            }
                            .padding(.vertical, 40)

                            VStack {
                                if !viewModel.breakfastItems.isEmpty {
                                    MealSectionView(viewModel: viewModel, title: "Breakfast", foodItems: $viewModel.breakfastItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
                                }
                                if !viewModel.lunchItems.isEmpty {
                                    MealSectionView(viewModel: viewModel, title: "Lunch", foodItems: $viewModel.lunchItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
                                }
                                if !viewModel.dinnerItems.isEmpty {
                                    MealSectionView(viewModel: viewModel, title: "Dinner", foodItems: $viewModel.dinnerItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
                                }
                                if !viewModel.snackItems.isEmpty {
                                    MealSectionView(viewModel: viewModel, title: "Snack", foodItems: $viewModel.snackItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .refreshable { // Pull down to refresh
                            loadedFirstTime = true
                            viewModel.isRefreshing = true
                            viewModel.sumCalories = 0
                            if let uid = viewModel.profileViewModel.currentUser?.uid {
                                viewModel.fetchMeals(for: uid, on: viewModel.selectedDate)
                            }
                        }
                    }
                } // End of VStack
                .navigationTitle(isGreetingVisible ? "\(getGreeting()), \(viewModel.profileViewModel.currentUser?.userName ?? "The Healthy One!")" : "\(formattedDate(viewModel.selectedDate))")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        CalendarView(selectedDate: $viewModel.selectedDate, originalDate: $originalDate, showingPopover: $showingPopover, viewModel: viewModel)
                    }
                })
                .onAppear {
                    print("FETCHING")
                    startTimer()
                    viewModel.sumCalories = 0
                    if let uid = viewModel.profileViewModel.currentUser?.uid {
                        viewModel.fetchMeals(for: uid)
                    } else {
                        // Wait for the uid to be available
                        viewModel.cancellable = viewModel.profileViewModel.$currentUser
                            .compactMap { $0?.uid } // Only proceed if currentUser.uid is non-nil
                            .sink { uid in
                                viewModel.fetchMeals(for: uid)
                                viewModel.cancellable?.cancel() // Cancel the subscription
                            }
                    }
                    viewModel.selectedDate = Date()
                }
            } // End of Navigation Stack

            // Overlay FoodItemEditView on top of the entire DashboardView
            if showEditPopup {
                FoodItemEditView(foodItem: $selectedFoodItem, isPresented: $showEditPopup, calorieNum: $viewModel.sumCalories, viewModel: viewModel)
            }
        } // End of ZStack
    }

    
    /// Produce a DateFormatter object, with adjusted date and time style.
    /// - Parameters: none
    /// - Returns: A DateFormatter object.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    
    /// A function used to format date.
    /// - Parameters: _date: The date object.
    /// - Returns: String of the formatted date.
    func formattedDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    
    /// The function starts a timer with a 5-second interval.
    /// - Parameters: _date: The date object.
    /// - Returns: String of the formatted date.
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 1.0)) {
                isGreetingVisible.toggle()
            }
        }
    }
}


/// A function used to print greetings according to system time
/// - Parameters: none
/// - Returns: String of the greeting.
func getGreeting() -> String {
    let hour = Calendar.current.component(.hour, from: Date())

    switch hour {
    case 0..<12:
        return "Good morning"
    case 12..<17:
        return "Good afternoon"
    case 17..<24:
        return "Good evening"
    default:
        return "Hello"
    }
}

#Preview("English") {
    DashboardView()
}

#Preview("Chinese") {
    DashboardView()
        .environment(\.locale, Locale(identifier: "zh-Hans"))
}
