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
            VStack {
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
                                .foregroundStyle(.brandDarkGreen)
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
                                    .font(.system(size: Fontsize().brand_button))
                            }
                            .padding(.vertical)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 35, bottom: 0, trailing: 0))
                    .listRowBackground(RoundedRectangle(cornerRadius: 20).fill(Color.brandLightTurquoise).padding(.vertical, 3))
                    
                    Spacer()
                    
                    Section {
                        Button {
                            AuthServices.sharedAuth.signOut()
                        } label: {
                            Text("Log Out")
                                .foregroundStyle(.brandDarkGreen)
                                .font(.system(size: Fontsize().brand_button, weight: .bold))
                        }
                        .listRowInsets(.init(top: 0, leading: 30, bottom: 0, trailing: 0))
                        .listRowBackground(Capsule().fill(Color.brandLightTurquoise))
                    }
                }
                .environment(\.defaultMinListRowHeight, 60)
                .scrollDisabled(true)
                .scrollContentBackground(.hidden)
                .clipShape(RoundedCornerShape(radius: 20, corners: [.topLeft, .topRight]))
                .modifier(TopShadow()) // Apply the top
                .ignoresSafeArea(edges: .bottom)
                
                
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color.brandLightTurquoise, Color.brandTurquoise]), startPoint: .leading, endPoint: .trailing))

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
