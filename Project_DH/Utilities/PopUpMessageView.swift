//
//  PopUpMessageView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/27/24.
//

import SwiftUI

struct PopUpMessageView: View {
    var messageTitle: String
    var message: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack{
            VStack {
                Text(messageTitle)
                    .font(.title3)
                    .padding(.top, 10)
                    .multilineTextAlignment(.center)
                Text(message)
                    .padding()
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .multilineTextAlignment(.center)
                Button(action: {
                    isPresented = false
                }) {
                    Text("Close")
                }
                .padding(.bottom, 10)
            }
        }
        .frame(width: 300)
        .background(Color(.white))
        .border(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
}


struct PopUpMessageView_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        PopUpMessageView(
            messageTitle: "Success!",
            message: "The displayed message will be here",
            isPresented: $isPresented
        )
        .previewLayout(.sizeThatFits) // Adjust the preview size to fit the view
    }
}
