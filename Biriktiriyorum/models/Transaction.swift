//
//  Transaction.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let category: String
    let note: String
    let date: Date
    
    init(amount: Double, category: String, note: String, date: Date) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
    }
    
    init(id: UUID, amount: Double, category: String, note: String, date: Date) {
        self.id = id
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
    }
}
