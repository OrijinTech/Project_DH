//
//  CardListViewModel.swift
//  Project_Me
//
//  Created by mac on 2024/5/16.
//

import Foundation
// TODO: need to modify this for presenting cards on the NameCardListView
class CardListViewModel: ObservableObject {
    @Published var createdUsers: [User] = []
    
    func addUser(_ user: User) {
        createdUsers.append(user)
    }
}
