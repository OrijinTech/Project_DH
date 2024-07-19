//
//  DetailForm.swift
//  Project_Me
//
//  Created by mac on 2024/5/16.
//

import SwiftUI

struct DetailForm: View {
    @Binding var selectedCardType: CardType?
    @Binding var userName: String
    @Binding var email: String
    @Binding var tel: String
    @Binding var description: String
    @Binding var address: String
    @Binding var createdUser: User?
    @Environment(\.presentationMode) var presentationMode
    
    var isFormValid: Bool {
        !userName.isEmpty && !email.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Name (Required)", text: $userName)
                    TextField("Email (Required)", text: $email)
                    TextField("Tel", text: $tel)
                    TextField("Description", text: $description)
                    TextField("Address", text: $address)
                }
                
                Button(action: {
                    self.createdUser = User(
                        email: email,
                        tel: tel.isEmpty ? nil : tel,
                        userName: userName,
                        address: address.isEmpty ? nil : address,
                        description: description.isEmpty ? nil : description
                    )
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Create Card")
                }
                .disabled(!isFormValid)
                
                Button(action: {
                    self.resetForm()
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                }
            }
            .navigationBarTitle("Enter Details", displayMode: .inline)
        }
    }
    
    
    private func resetForm() {
            userName = ""
            email = ""
            tel = ""
            description = ""
            address = ""
            selectedCardType = nil
            createdUser = nil
        }
}

#Preview {
    DetailForm(
        selectedCardType: .constant(.cardView1),
        userName: .constant(""),
        email: .constant(""),
        tel: .constant(""),
        description: .constant(""),
        address: .constant(""),
        createdUser: .constant(nil)
    )
}
