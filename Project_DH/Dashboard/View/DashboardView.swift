//
//  MyDayView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//

import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel = ProfileViewModel()
    @State private var selectedDate: Date = Date()
    @State private var originalDate: Date = Date()
    @State private var showingPopover = false
    @State private var isGreetingVisible: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Section {
                        ForEach(CardOptions.allCases){ card in
                            VStack {
                                HStack {
                                    Text(card.title)
                                        .bold()
                                        .foregroundStyle(.brand)
                                        .padding(.leading, 15)
                                    Spacer()
                                }

                                Divider()
                                Button {
                                    //
                                } label: {
                                    Text(LocalizedStringKey("+ add"))
                                        .padding(.vertical)
                                        .foregroundStyle(.brand)
                                }
                            }
                            .frame(height: card.cardHeight)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .shadow(radius: 5)
                        }
                    }
                }
            }
            .navigationTitle(isGreetingVisible ? "\(getGreeting()), \(viewModel.currentUser?.userName ?? "The Healthy One!")" : "\(formattedDate(selectedDate))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    CalendarView(selectedDate: $selectedDate, originalDate: $originalDate, showingPopover: $showingPopover)
                }
            })
            .onAppear {
                startTimer()
            }
        } // End of Navigation Stack
    }
    
    
    /*
     Description: A function used to format date, output would be (Month Day, Year)
     Input: date
     Output: String
    */
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
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
 Description: A function used to print greetings accroding to system time
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
