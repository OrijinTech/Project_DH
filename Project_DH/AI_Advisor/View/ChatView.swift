//
//  ChatView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/11/24.
//

import SwiftUI


struct ChatView: View {
    
    @StateObject var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text(viewModel.chat?.topic ?? "AI Advisor")
                .font(.title3)
                .bold()
                .padding(.top, 15)
                .padding(.bottom, 20)
            
            // Model Selection
//            modelSelectionView
//                .padding(.bottom, 10)
            
            ScrollViewReader { scrollView in
                List(viewModel.messages) { message in
                    messageView(for: message)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .id(message.id)
                        .onChange(of: viewModel.messages) { oldValue, newValue in
                            print(viewModel.messages)
                            scrollToBottom(scrollView: scrollView)
                        }
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .listStyle(.plain)
                .onChange(of: viewModel.scrollToBottom) { error, scroll in // When scrollToBottom variable changes to true, scroll to bottom
                    if scroll {
                        scrollToBottom(scrollView: scrollView)
                    }
                }
            }
            
            messageInputView
            
        }
        .navigationBarTitleDisplayMode(.inline)
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
        }
        .onAppear {
            viewModel.fetchData()
        }
        
        
        
    }// End of body view
    
    
    /// This view shows the AI model selection bar on the top.
    var modelSelectionView: some View {
        Group {
            if let model = viewModel.chat?.model?.rawValue {
                Text(model)
                    .font(.subheadline)
            } else {
                Picker(selection: $viewModel.selectedModel) {
                    ForEach(ChatModel.allCases, id: \.self) { model in
                        Text(model.rawValue)
                    }
                } label: {
                    Text("")
                }
                .pickerStyle(.segmented)
                .padding()
            }
        }
    }
    
    
    /// This view shows the user input elements, including the message enter, and message sending button.
    var messageInputView: some View {
        HStack {
            TextField("Send a message...", text: $viewModel.messageText)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onSubmit {
                    sendMessage()
                }
            Button {
                sendMessage()
            } label: {
                Text("Send")
                    .padding()
                    .foregroundStyle(.white)
                    .background(Color.brand)
                    .bold()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
    
    
    /// This function shows the view for displaying the messages inside the chat.
    /// - Parameters:
    ///     - for: the massage to display
    /// - Returns: the view to show
    func messageView(for message: AppMessage) -> some View {
        HStack {
            if (message.role == .user) {
                Spacer()
            }
            Text(message.text)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .foregroundStyle(message.role == .user ? .white : .black)
                .background(message.role == .user ? .brand : .white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            if (message.role == .assistant) {
                Spacer()
            }
        }
    }
    
    
    /// This function allows the selected chat to automatically scroll to the bottom once opened.
    /// - Parameters:
    ///     - scrollView: The ScrollViewProxy
    /// - Returns: none
    func scrollToBottom(scrollView: ScrollViewProxy) {
        guard !viewModel.messages.isEmpty, let lastMessage = viewModel.messages.last else {
            return
        }
        withAnimation {
            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
    
    
    /// This function handles the user action for sending the message.
    /// - Parameters: none
    /// - Returns: none
    func sendMessage() {
        Task {
            do {
                try await viewModel.sendMessage()
            } catch {
                print(error)
            }
        }
    }
    
}


#Preview {
    ChatView(viewModel: .init(chatId: ""))
}
