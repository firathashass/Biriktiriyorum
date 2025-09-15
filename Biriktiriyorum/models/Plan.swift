//
//  Plan.swift
//  Biriktiriyorum
//
//  Created by AI Assistant on 15.09.2025.
//

import Foundation

struct Plan: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var name: String
    let createdAt: Date

    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
        self.createdAt = Date()
    }
}

