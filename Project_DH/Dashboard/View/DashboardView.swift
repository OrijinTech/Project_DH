//
//  DashboardView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//


import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel = DashboardViewModel()
    
    @State private var selectedDate: Date = Date()
    @State private var originalDate: Date = Date()
    @State private var showingPopover = false
    @State private var isGreetingVisible: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if viewModel.meals.isEmpty {
                    Text("No meals yet!")
                        .font(.headline)
                        .padding()
                } else {
                    ScrollView {
                        VStack {
                            if !viewModel.breakfastItems.isEmpty {
                                MealSectionView(title: "Breakfast", foodItems: viewModel.breakfastItems)
                            }
                            if !viewModel.lunchItems.isEmpty {
                                MealSectionView(title: "Lunch", foodItems: viewModel.lunchItems)
                            }
                            if !viewModel.dinnerItems.isEmpty {
                                MealSectionView(title: "Dinner", foodItems: viewModel.dinnerItems)
                            }
                            if !viewModel.snackItems.isEmpty {
                                MealSectionView(title: "Snack", foodItems: viewModel.snackItems)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } // End of VStack
            .navigationTitle(isGreetingVisible ? "\(getGreeting()), \(viewModel.profileViewModel.currentUser?.userName ?? "The Healthy One!")" : "\(formattedDate(selectedDate))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    CalendarView(selectedDate: $selectedDate, originalDate: $originalDate, showingPopover: $showingPopover, viewModel: viewModel)
                }
            })
            .onAppear {
                startTimer()
                if let uid = viewModel.profileViewModel.currentUser?.uid {
                    viewModel.fetchMeals(for: uid)
                }
                selectedDate = Date()
            }
        } // End of Navigation Stack
    }
    
    // Date Formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    /*
     Description: A function used to format date, output would be (Month Day, Year)
     Input: date
     Output: String
    */
    func formattedDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    /*
     Description: A function used to set timer for animation
     Input: Void
     Output: Void
    */
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 1.0)) {
                isGreetingVisible.toggle()
            }
        }
    }
}

/*
 Description: A function used to print greetings according to system time
 Input: Void
 Output: String
*/
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
