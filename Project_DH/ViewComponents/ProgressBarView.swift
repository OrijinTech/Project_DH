//
//  ProgressBarView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 8/15/24.
//

import SwiftUI

/// Shows a progress bar for calorie tracking.
struct ProgressBarView: View {
    var targetCalories: Int
    var currentCalories: Int
    
    var body: some View {
        VStack {
            if targetCalories > 0 {
                Text("Target Calories: \(Int(targetCalories))")
                    .font(.title)
                    .padding(.bottom, 10)
                if currentCalories > targetCalories {
                    ProgressView(value: Double(targetCalories), total: Double(targetCalories))
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)
                }
                else {
                    ProgressView(value: Double(currentCalories), total: Double(targetCalories))
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)
                }
                Text("You Consumed \(currentCalories) Calories Today")
                    .font(.headline)
                    .padding(.top, 10)
            } else {
                Text("You Consumed \(currentCalories) Calories Today")
                    .font(.title)
                    .padding(.top, 10)
            }
        }
        .padding()
    }
}


#Preview {
    ProgressBarView(targetCalories: 1000, currentCalories: 100)
}
