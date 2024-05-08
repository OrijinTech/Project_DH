//
//  SignUpView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI
import AuthenticationServices

struct RegistrationView: View {
    @StateObject var authViewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss

    
    var body: some View {
        NavigationStack {
            ScrollView {
                Image(.logo)
                    .resizable().scaledToFill()
                    .frame(width: 120, height: 120)
                    .padding(.vertical, 20)
                
                Text("Let's get started!")
                    .font(.title2)
                    .padding(.bottom, 80)
                    .shadow(radius: 3)
                
                // MARK: User Input Textfields
                VStack{
                    HStack {
                        Image(systemName: "person")
                            .padding(.leading, 15)
                        TextField("Username", text: $authViewModel.username)
                            .textInputAutocapitalization(.never)
                            .font(.subheadline)
                            .padding(12)
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    
                    HStack {
                        Image(systemName: "envelope")
                            .padding(.leading, 10)
                        TextField("Email", text: $authViewModel.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .font(.subheadline)
                            .padding(12)
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    
                    
                    HStack {
                        Image(systemName: "key.horizontal")
                            .padding(.leading, 10)
                        SecureField("Password", text: $authViewModel.password)
                            .textInputAutocapitalization(.never)
                            .font(.subheadline)
                            .padding(12)
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 30)
                }
                
                // MARK: ERROR MESSAGE
                HStack {
                    authViewModel.alertItem?.message ?? Text(" ")
                    Spacer()
                }
                .font(.footnote)
                .foregroundStyle(.red)
                .padding(.leading, 30)
                .padding(.bottom, 5)
                
                //MARK: Privacy and Policy
                VStack{
                    Toggle("I agree to the Privacy Policy", isOn: $authViewModel.privacy)
                        .toggleStyle(SwitchToggleStyle(tint: .brand))
                        .font(.custom("custom", size: 15))
                        .padding(.leading, 30)
                        .padding(.trailing, 40)
                    
                    Toggle("I agree to the Terms and Conditions", isOn: $authViewModel.conditions)
                        .toggleStyle(SwitchToggleStyle(tint: .brand))
                        .font(.custom("custom", size: 15))
                        .padding(.leading, 30)
                        .padding(.trailing, 40)
                        .padding(.bottom, 100)
                }
                
                // MARK: SIGN UP BUTTON
                Button {
                    Task{ try await authViewModel.createUser() }
                }label: {
                    Text("Sign Up                                                      ")
                }
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 310, height: 45)
                .background(.brand)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.vertical)
                .shadow(radius: 3)
            }
            
        } // End of Navigation Stack
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.brand)
                    }
                }
            }
        } // End of toolbar
    }
}

#Preview {
    RegistrationView()
}
