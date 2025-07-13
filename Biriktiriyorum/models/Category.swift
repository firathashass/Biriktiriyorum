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
    var group: String
    var goalAmount: Double? // Optional goal amount
    var monthlyBillAmount: Double? // Optional monthly bill amount
    
    init(name: String, assignedBudget: Double = 0.0, remainingBalance: Double = 0.0, group: String = "Other", goalAmount: Double? = nil, monthlyBillAmount: Double? = nil) {
        self.name = name
        self.assignedBudget = assignedBudget
        self.remainingBalance = remainingBalance
        self.group = group
        self.goalAmount = goalAmount
        self.monthlyBillAmount = monthlyBillAmount
    }
}
