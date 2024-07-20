//
//  DashboardViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//


import Foundation
import SwiftUI

enum CardOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case breakfast
    case lunch
    case dinner
    case snack
    case water
    
    var title: LocalizedStringKey {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .snack:
            return "Snack"
        case .water:
            return "Water"
        }
    }
    
    var cardHeight: CGFloat? {
        switch self {
        case .breakfast, .lunch, .dinner, .snack:
            return 120
        case .water:
            return 160
        }
    }
    
    
    
}

