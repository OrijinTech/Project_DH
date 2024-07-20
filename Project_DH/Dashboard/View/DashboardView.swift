//
//  MyDayView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//

import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel = ProfileViewModel()
    
    private let usernamePlaceholder: LocalizedStringKey = "The Healthy One"
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack {
                        HStack {
                            Text("Good Morning!")
                                .font(.title2)
                                .bold()
                                .padding(.leading, 30)
                                .padding(.top, 20)
                            Spacer()
                        }.padding(.bottom, 10)
                        
                        HStack {
                            if let username = viewModel.currentUser?.userName{
                                Text(username)
                                    .font(.headline)
                                    .bold()
                                    .padding(.leading, 30)
                            } else {
                                Text(usernamePlaceholder)
                                    .font(.headline)
                                    .bold()
                                    .padding(.leading, 30)
                            }
                            
                            Spacer()
                        }.padding(.bottom, 30)
                        
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
            }
            .navigationTitle("MY DAY")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: DATE SELECTION TO DISPLAY DIFFERENT DAYS of MY DAY
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.brand)
                    }
                }
            })
        } // End of Navigation Stack

    }
}

#Preview("English") {
    DashboardView()
}


#Preview("Chinese") {
    DashboardView()
        .environment(\.locale, Locale(identifier: "zh-Hans"))
}
