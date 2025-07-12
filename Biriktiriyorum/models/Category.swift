//
//  Category.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import Foundation

struct Category: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String
    var assignedBudget: Double
    var remainingBalance: Double
    
    init(name: String, assignedBudget: Double = 0.0, remainingBalance: Double = 0.0) {
        self.name = name
        self.assignedBudget = assignedBudget
        self.remainingBalance = remainingBalance
    }
}
