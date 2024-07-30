//
//  MemoryManagement.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/30/24.
//

import Foundation

func clearCache() {
    URLCache.shared.removeAllCachedResponses()
    print("Cache cleared")
}
