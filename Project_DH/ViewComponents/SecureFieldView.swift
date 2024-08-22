//
//  SecureFieldView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 8/22/24.
//

import SwiftUI

struct SecureFieldView: View {
    @Binding var text: String
    @State private var displayText: String = ""
    
    var placeholder: String
    var maskCharacter: Character = "•"

    var body: some View {
        ZStack(alignment: .leading) {
            if displayText.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .opacity(0.6)
            }
            
            TextField("", text: $displayText, onEditingChanged: { isEditing in
                if !isEditing {
                    displayText = String(repeating: maskCharacter, count: text.count)
                }
            })
            .font(.subheadline)
            .background(Color.clear)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .keyboardType(.default)
            .onChange(of: displayText) {oldValue, newValue in
                if newValue.count > text.count {
                    // Append the new character to the actual text
                    let newCharacter = newValue.suffix(1)
                    text.append(String(newCharacter))

                    // Mask all previous characters, show only the last one
                    displayText = String(repeating: maskCharacter, count: text.count - 1) + newCharacter
                } else {
                    // If the user deletes characters, update both text and displayText
                    text = String(text.prefix(newValue.count))
                    displayText = newValue
                }
            }
        }
    }
}


#Preview {
    SecureFieldView(text: .constant("passcode124"), placeholder: "Password")
}
