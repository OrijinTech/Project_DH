//
//  String_Extension.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/18/24.
//

import Foundation
import RegexBuilder



extension String {
    // MARK: Check if the Email String is a valid string
    
    // REGEX AFTER IOS 16
    var isValidEmailFormat: Bool {
        let emailRegex = Regex {
            OneOrMore {
                CharacterClass(
                    .anyOf("._%+-"),
                    ("A"..."Z"),
                    ("0"..."9"),
                    ("a"..."z")
                )
            }
            "@"
            OneOrMore {
                CharacterClass(
                    .anyOf("-"),
                    ("A"..."Z"),
                    ("a"..."z"),
                    ("0"..."9")
                )
            }
            "."
            Repeat(2...64) {
                CharacterClass(
                    ("A"..."Z"),
                    ("a"..."z")
                )
            }
        }
        return self.wholeMatch(of: emailRegex) != nil
    }
    
}


func extractNumber(from text: String) -> String? {
    // Define the regex pattern to match the first number
    let pattern = "\\d+"
    
    // Create the regular expression object
    let regex = try? NSRegularExpression(pattern: pattern)
    
    // Search for the first match in the input text
    if let match = regex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
        // Extract the matched range
        if let range = Range(match.range, in: text) {
            // Convert the matched substring to an integer
            let numberString = String(text[range])
            return numberString
        }
    }
    
    // Return nil if no match is found
    return nil
}
