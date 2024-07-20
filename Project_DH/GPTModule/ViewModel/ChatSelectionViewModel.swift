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
    
    
    func createChat(user: String?) async throws -> String {
        let document = try await db.collection(Collection().chats).addDocument(data: ["lastMessageSent" : Date(), "owner" : user ?? ""])
        return document.documentID
    }
    
    
    func deleteChat(chat: AppChat) {
        guard let id = chat.id else {return}
        db.collection(Collection().chats).document(id).delete()
    }
    
    func uploadChatTitle(chatId: String) {
        db.collection(Collection().chats).document(chatId).updateData(["topic": curTitle])
    }
    
    
    
}


enum ChatListState {
    case none
    case loading
    case noResults
    case resultsFound
}


struct AppChat: Codable, Identifiable {
    @DocumentID var id: String?
    let topic: String?
    var model: ChatModel?
    let lastMessageSent: FirestoreDate
    let owner: String
    
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


enum ChatModel: String, Codable, CaseIterable, Hashable {
    case gpt3_5_turbo = "GPT 3.5 Turbo"
    case gpt4 = "GPT 4"
    
    var tintColor: Color {
        switch self {
        case .gpt3_5_turbo:
            return .green
        case .gpt4:
            return .purple
        }
    }
    
    var model: Model {
        switch self {
        case .gpt3_5_turbo:
            return .gpt3_5Turbo
        case .gpt4:
            return .gpt4
        }
    }
}


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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let timestamp = Timestamp(date: date)
        try container.encode(timestamp)
    }
    
    static func < (lhs: FirestoreDate, rhs: FirestoreDate) -> Bool {
        lhs.date < rhs.date
    }
    
    
    
}

