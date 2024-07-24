//
//  MediaInputViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/24/24.
//

import Foundation
import OpenAI
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class MediaInputViewModel: ObservableObject {
    @Published var calories: String?
    
    // Get OpenAI API Key from config.plist (in gitignore)
    func loadConfig() -> [String: Any]? {
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let config = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any] {
            return config
        }
        return nil
    }
    
    
    // TODO: The pipeline for calling the calorie generation, and at the same time calling the firestore database to store the photo.
    func getCalories(for image: UIImage){
        print("pass")
    }
    
    
    // OpenAI API call for generating output based on image/text input
    // TODO: Camera-GPT-Input Implementation, refer to notion task
    func generateCalories(for image: UIImage) async throws{
        // Get API Key
        guard let config = loadConfig(),
              let apiKey = config["OpenAI_API_KEY"] as? String else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key not set"])
        }
        let openAI = OpenAI(apiToken: apiKey)
        
        
        var img_messages: [ChatQuery.ChatCompletionMessageParam] = [
            .user(.init(content: .string("Please calculate the calories of the provided image. Please only give me the calorie format in the number of calories without textual explanation."))),
            .user(.init(content: .string("Give me the calorie format in the number of calories without textual explanation.")))
        ]
        
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
                    let imgParam = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam(content: .vision([.chatCompletionContentPartImageParam(.init(imageUrl: .init(url: imageData, detail: .high)))]))
                    img_messages.append(.user(imgParam))
                }
        
        let query = ChatQuery(messages: img_messages, model: .gpt4_o)
        
        for try await result in openAI.chatsStream(query: query) {
            guard let newText = result.choices.first?.delta.content else { continue }
            await MainActor.run {
                self.calories = newText
            }
        }
    }
    
    
}
