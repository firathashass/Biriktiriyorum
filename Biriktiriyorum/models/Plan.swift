//
//  Plan.swift
//  Biriktiriyorum
//
//  Created by Assistant on 15.09.2025.
//

import Foundation

struct Plan: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}

