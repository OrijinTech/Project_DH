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
            chatSelectionView
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
                .onChange(of: viewModel.scrollToBottom) { error, scroll in // When scrollToBottom changes to true, scroll to bottom
                    if scroll {
                        scrollToBottom(scrollView: scrollView)
                    }
                }
            }
            
            messageInputView
            
        }
        .navigationTitle(viewModel.chat?.topic ?? "New Chat")
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
    
    
    func scrollToBottom(scrollView: ScrollViewProxy) {
        guard !viewModel.messages.isEmpty, let lastMessage = viewModel.messages.last else {
            return
        }
        withAnimation {
            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
    
    
    var chatSelectionView: some View {
        Group {
            if let model = viewModel.chat?.model?.rawValue {
                Text(model)
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
