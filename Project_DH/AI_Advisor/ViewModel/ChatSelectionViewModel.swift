//
//  ChatSelectionViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import OpenAI


class ChatSelectionViewModel: ObservableObject {
    
    @Published var chats: [AppChat] = []
    @Published var loadingState: ChatListState = .none
    @Published var showEditWindow = false
    
    // Current Chat Info
    @Published var curTitle = ""
    @Published var curID = ""
    
    private let db = Firestore.firestore()
    
    
    /// This function fetches all chats which belong to the user.
    /// - Parameters:
    ///     - user: the user that the function's search is based on
    /// - Returns: none
    func fetchData(user: String?) {
        if loadingState == .none {
            loadingState = .loading
            db.collection(Collection().chats).whereField("owner", isEqualTo: user ?? "").addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self, let documents = querySnapshot?.documents, !documents.isEmpty else {
                    self?.loadingState = .noResults
                    return
                }
                
                self.chats = documents.compactMap({ snapshot -> AppChat? in
                    return try? snapshot.data(as: AppChat.self)
                })
                .sorted(by: {$0.lastMessageSent > $1.lastMessageSent})
                
                self.loadingState = .resultsFound
            }
        }
    }
    
    
    /// This function creates a new chat and saves it to the Firebase.
    /// - Parameters:
    ///     - user: The user which the chat is saved to.
    /// - Returns: The document id where the chat is saved to.
    func createChat(user: String?) async throws -> String {
        let document = try await db.collection(Collection().chats).addDocument(data: ["lastMessageSent" : Date(), "owner" : user ?? ""])
        return document.documentID
    }
    
    
    /// This function deletes the selected chat.
    /// - Parameters:
    ///     - chat: The chat to delete.
    /// - Returns: none
    func deleteChat(chat: AppChat) {
        guard let id = chat.id else {return}
        db.collection(Collection().chats).document(id).delete()
    }
    
    
    /// This function uploads the chat title to Firebase.
    /// - Parameters:
    ///     - chatId: The chat which the user wants to change the title for.
    /// - Returns: none
    func uploadChatTitle(chatId: String) {
        db.collection(Collection().chats).document(chatId).updateData(["topic": curTitle])
    }
    
    
}


/// The states of the chat list.
enum ChatListState {
    case none
    case loading
    case noResults
    case resultsFound
}


/// The Chat Structure.
struct AppChat: Codable, Identifiable {
    @DocumentID var id: String?
    let topic: String?
    var model: ChatModel?
    let lastMessageSent: FirestoreDate
    let owner: String
    
    /// The time when last message was sent or received.
    var lastMessageTimeAgo: String {
        let now = Date()
        let components = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: lastMessageSent.date, to: now)
        
        let timeUnits: [(value: Int?, unit: String)] = [
            (components.year, "year"),
            (components.month, "month"),
            (components.day, "day"),
            (components.hour, "hour"),
            (components.minute, "minute"),
            (components.second, "second")
        ]
        
        for timeUnit in timeUnits {
            if let value = timeUnit.value, value > 0 {
                return "\(value) \(timeUnit.unit)\(value == 1 ? "" : "s") ago"
            }
        }
        
        return "just now"
        
    }
}


/// The chat id structure.
struct ChatID: Identifiable {
    let id: String
    var ident: String { id }
}


/// Returns the SwiftUI Color depending on the model selected
enum ChatModel: String, Codable, CaseIterable, Hashable {
    case gpt3_5_turbo = "GPT 3.5 Turbo"
    case gpt4 = "GPT 4"
    case gpt4_o = "GPT 4o"
    
    /// The text color for corresponding model name.
    var tintColor: Color {
        switch self {
        case .gpt3_5_turbo:
            return .green
        case .gpt4:
            return .purple
        case .gpt4_o:
            return .blue
        }
    }
    
    
    /// Returns the model which will be used as a parameter value for OpenAI api call
    var model: Model {
        switch self {
        case .gpt3_5_turbo:
            return .gpt3_5Turbo
        case .gpt4:
            return .gpt4
        case .gpt4_o:
            return .gpt4_o
        }
    }
}


/// The date format which is accepted by Firebase Firestore.
struct FirestoreDate: Codable, Hashable, Comparable {
    
    var date: Date
    
    
    init(_ date: Date = Date()) {
        self.date = date
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let timestamp = try container.decode(Timestamp.self)
        date = timestamp.dateValue()
    }
    
    
    /// This function customizes how an instance of a type is encoded into an external representation.
    /// - Parameters:
    ///     - encoder: The encoder which we want to encode the struct.
    /// - Returns: none
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let timestamp = Timestamp(date: date)
        try container.encode(timestamp)
    }
    
    
    static func < (lhs: FirestoreDate, rhs: FirestoreDate) -> Bool {
        lhs.date < rhs.date
    }
    
    
    
}

