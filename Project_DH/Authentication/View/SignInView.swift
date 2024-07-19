//
//  SignInView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import CryptoKit

struct SignInView: View {
    @StateObject var authViewModel = SignInViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(.logo)
                    .resizable().scaledToFill()
                    .frame(width: 120, height: 120)
                    .padding(.vertical, 20)
                
                Text("Welcome Back!")
                    .font(.title2)
                    .padding(.bottom, 100)
                    .shadow(radius: 3)
                
                VStack{
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
                
                
                HStack { // ERROR MESSAGE
                    authViewModel.alertItem?.message ?? Text(" ")
                    Spacer()
                }
                .font(.footnote)
                .foregroundStyle(.red)
                .padding(.leading, 30)
                
                
                NavigationLink {
                    // TODO: Add a function to prompt user for an email if the password has been forgotten
                    ForgotPasswordView()
                } label: {
                    Text("Forgot password?")
                        .font(.footnote)
                        .foregroundStyle(.brand)
                        .fontWeight(.semibold)
                        .padding(.top)
                        .padding(.trailing, 28)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                // MARK: SIGN IN WITH EMAIL AND PASSWORD
                Button {
                    Task { try await authViewModel.login() }
                }label: {
                    Text("Sign In                                                      ")
                }
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 300, height: 45)
                .background(.brand)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.vertical)
                .shadow(radius: 3)
                
                dividerOr()
                
                // MARK: SIGN IN WITH APPLE
                SignInWithAppleButton(.signIn) { request in
                    let nonce = authViewModel.randomNonceString()
                    authViewModel.nonce = nonce
                    request.requestedScopes = [.email, .fullName]
                    request.nonce = authViewModel.sha256(nonce)
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        Task { try await authViewModel.signInApple(authorization) }
                    case .failure(let error):
                        print("FAILED SIGNING IN WITH APPLE \(error)")
                    }
                }
                .frame(width: 293, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, 8)
                .shadow(radius: 3)
                
                // MARK: SIGN IN WITH GOOGLE
                Button {
                    Task {
                        do {
                            try await authViewModel.signInGoogle()
                        } catch {
                            print(error)
                        }
                    }
                }label: {
                    HStack {
                        Image(.googleLogo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                        Text("Sign in with Google")
                            .font(.custom("googlefont", fixedSize: 15.5))
                            .foregroundStyle(Color(.systemGray))
                            .padding(.trailing)
                    }
                    
                }
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 293, height: 40)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 40)
                .shadow(radius: 3)

                Spacer()
                
                Divider()
                
                HStack {
                    Text("Don't have an account?")
                    NavigationLink {
                        RegistrationView()
                    } label: {
                        Text("Sign Up")
                            .foregroundStyle(.brand)
                    }
                }
                .font(.footnote)
                .padding(.vertical)
            }
            
        } // End of Navigation Stack
        .navigationBarBackButtonHidden()
    }
    
}

#Preview {
    SignInView()
}
