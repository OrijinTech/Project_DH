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
    // Progress bar
    var lineWidth: CGFloat = 18
    var color: Color = .blue
    var rotationAngle: CGFloat = 153
    
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
                    ZStack {
                        // Background Circle
                        Circle()
                            .trim(from: 0.0, to: 0.65)
                            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                            .opacity(0.3)
                            .foregroundColor(color)
                            .rotationEffect(Angle(degrees: rotationAngle))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x:0, y:2)

                        // Progress Circle
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(Double(currentCalories) / Double(targetCalories), 1.0)) * 0.65)
                            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                            .foregroundColor(color)
                            .rotationEffect(Angle(degrees: rotationAngle)) // Start from the top
                            .animation(.linear, value: Double(currentCalories) / Double(targetCalories))

                        // Progress Text
                        VStack {
                            Text(String(format: "%.0f%%", min(Double(currentCalories) / Double(targetCalories), 1.0) * 100.0))
                                .font(.largeTitle)
                                .foregroundColor(color)
                            
                            Divider()
                                .padding(.horizontal, 30)
                                .bold()
                            
                            Text("\(currentCalories)Cal")
                                .font(.largeTitle)
                                .foregroundColor(color)
                        }
                        
                    }
                    .padding(.horizontal, 80)
                    .padding(.top, 20)
                }
                
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
