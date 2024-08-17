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
        .popover(isPresented: $showingPopover) {
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
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer().frame(width: 20)

                    Button("Done") {
                        if let uid = viewModel.profileViewModel.currentUser?.uid {
                            viewModel.fetchMeals(for: uid, on: selectedDate)
                        }
                        showingPopover = false
                    }
                    .frame(width: 70)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top)
            }
        }
    }
}

#Preview {
    CalendarView(selectedDate: .constant(Date()), originalDate: .constant(Date()), showingPopover: .constant(true))
}
