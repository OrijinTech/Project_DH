//
//  ProfilePageView.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//

import SwiftUI

struct ProfilePageView: View {
    @StateObject var viewModel = ProfileViewModel()
    @State private var showingProfileInfo: Bool = false
    @State private var showingProfilePreview: Bool = false
    @State private var selectedView: ProfileOptions?
    
    private var user: User? {
        return viewModel.currentUser
    }
    
    var body: some View {
        NavigationStack {
            // TODO: Make this HeaderView
            HStack(spacing: 30) {
                Button { // Move to EditProfileView
                    showingProfileInfo = true
//                        .toolbar(.hidden, for: .tabBar)
                } label: {
                    if let _ = user?.profileImageUrl{
                        CircularProfileImageView(user: user, width: 80, height: 80, showCircle: true)
                    } else {
                        ZStack{
                            Circle()
                                .stroke(lineWidth: 1)
                                .foregroundColor(.gray)
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundStyle(Color(.systemGray4))
                        }
                    }
                }
                .padding(.leading, 40)
                
                VStack(spacing: 10) {
                    Text(user?.userName ?? "Username")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Button { // Show profile preview button
                        showingProfilePreview = true
                    } label: {
                        Text(LocalizedStringKey("Profile Preview"))
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .frame(width: 130, height: 25)
                            .foregroundStyle(.brand)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 40)
            
            List {
                Section { // Choices
                    ForEach(ProfileOptions.allCases){ option in
                        Button {
                            self.selectedView = option
                        } label: {
                            Text(option.title)
                                .foregroundStyle(Color(.black))
                        }
                    }
                }
                
                Section {
                    Button {
                        AuthServices.sharedAuth.signOut()
                    } label: {
                        Text("Log Out")
                            .foregroundStyle(.brand)
                    }
                }
            }

        } // END OF NAVIGATION STACK
        .fullScreenCover(isPresented: $showingProfileInfo, content: {
            EditProfileView(showingProfileInfo: $showingProfileInfo)
                .environmentObject(viewModel)
        })
//        .fullScreenCover(isPresented: $showingProfilePreview, content: {
//            ProfilePreviewView(user: user ?? User.MOCK_USER, showingProfilePreview: $showingProfilePreview)
//        })
//        .fullScreenCover(item: $selectedView) { viewCase in
//            OptionViewHub(enumCase: viewCase)
//        }
    }
}

#Preview {
    ProfilePageView()
}
