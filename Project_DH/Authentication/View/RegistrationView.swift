//
//  SignUpView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI
import AuthenticationServices


/// The major view for showing the registration page.
/// - Parameters:
///     - none
/// - Returns: none
struct RegistrationView: View {
    @StateObject var authViewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss

    
    var body: some View {
        NavigationStack {
            VStack {
                Image(.logo)
                    .resizable().scaledToFill()
                    .frame(width: 120, height: 120)
                    .padding(.vertical, 20)
                
                Text("Let's get started!")
                    .font(.title2)
                    .padding(.bottom, 80)
                    .shadow(color: Color.black.opacity(0.1), radius: 2)
                
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
                        SecureFieldView(text: $authViewModel.password, placeholder: "Password")
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
                .foregroundStyle(.brandRed)
                .padding(.leading, 30)
                .padding(.bottom, 5)
                
                //MARK: Privacy and Policy
                VStack{
                    Toggle("I agree to the Privacy Policy", isOn: $authViewModel.privacy)
                        .toggleStyle(SwitchToggleStyle(tint: .brandDarkGreen))
                        .font(.custom("custom", size: 15))
                        .padding(.leading, 30)
                        .padding(.trailing, 40)
                    
                    Toggle("I agree to the Terms and Conditions", isOn: $authViewModel.conditions)
                        .toggleStyle(SwitchToggleStyle(tint: .brandDarkGreen))
                        .font(.custom("custom", size: 15))
                        .padding(.leading, 30)
                        .padding(.trailing, 40)
                }
                
                Spacer()
                
                // MARK: SIGN UP BUTTON
                Button {
                    Task{ try await authViewModel.createUser() }
                }label: {
                    Text("Sign Up")
                }
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 310, height: 45)
                .background(.brandDarkGreen)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 30)
                .shadow(radius: 3)
            }
            
        } // End of Navigation Stack
        .navigationBarBackButtonHidden()
        .onTapGesture {
            UIApplication.shared.hideKeyboard()  // Dismiss the keyboard on any tap
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.brandDarkGreen)
                    }
                }
            }
        } // End of toolbar
    }
}

#Preview {
    RegistrationView()
}
