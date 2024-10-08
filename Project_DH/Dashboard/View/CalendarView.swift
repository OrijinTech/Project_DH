//
//  CalendarView.swift
//  Project_DH
//
//  Created by mac on 2024/7/20.
//

import SwiftUI


struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var originalDate: Date
    @Binding var showingPopover: Bool
    @ObservedObject var viewModel = DashboardViewModel()
    /// Whether to fetch meals when done is pressed in to hide the calendar view.
    var fetchOnDone: Bool
    
    var body: some View {
        Button(action: {
            originalDate = selectedDate
            showingPopover.toggle()
        }) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.brandDarkGreen)
            }
        }
        .sheet(isPresented: $showingPopover) {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date(), // Disable future dates
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                HStack {
                    Button("Cancel") {
                        selectedDate = originalDate
                        showingPopover = false
                    }
                    .frame(width: 70)
                    .padding(10)
                    .background(Color.brandRed)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer().frame(width: 20)

                    Button("Done") {
                        if fetchOnDone {
                            if let uid = viewModel.profileViewModel.currentUser?.uid {
                                viewModel.fetchMeals(for: uid, on: viewModel.selectedDate)
                            }
                        }
                        showingPopover = false
                    }
                    .frame(width: 70)
                    .padding(10)
                    .background(Color.brandDarkGreen)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top)
            }
            .presentationDetents([.height(500)])
        }
    }
}

#Preview {
    CalendarView(selectedDate: .constant(Date()), originalDate: .constant(Date()), showingPopover: .constant(true), fetchOnDone: true)
}
