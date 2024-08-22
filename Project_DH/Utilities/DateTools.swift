//
//  DateTools.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 8/22/24.
//

import Foundation
import SwiftUI


struct DateTools {
    /// Produce a DateFormatter object, with adjusted date and time style.
    /// - Parameters:
    ///     - none
    /// - Returns: A DateFormatter object.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()


    /// A function used to format date.
    /// - Parameters:
    ///     - _date: The date object.
    /// - Returns: String of the formatted date.
    func formattedDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}

