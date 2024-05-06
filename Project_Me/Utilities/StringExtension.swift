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


