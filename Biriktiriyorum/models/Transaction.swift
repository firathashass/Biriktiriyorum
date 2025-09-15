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
    let emotion: EmotionTag
    let note: String
    let date: Date
    let accountID: UUID   // Yeni alan
    
    init(amount: Double, category: String, emotion: EmotionTag, note: String, date: Date, accountID: UUID) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.emotion = emotion
        self.note = note
        self.date = date
        self.accountID = accountID
    }
    
    init(id: UUID, amount: Double, category: String, emotion: EmotionTag, note: String, date: Date, accountID: UUID) {
        self.id = id
        self.amount = amount
        self.category = category
        self.emotion = emotion
        self.note = note
        self.date = date
        self.accountID = accountID
    }
}

enum EmotionTag: String, CaseIterable, Identifiable, Codable {
    case joyful = "😊 Joyful"
    case regretful = "😔 Regretful"
    case impulsive = "⚡️ Impulsive"
    case neutral = "😐 Neutral"
    
    var id: String { self.rawValue }
}
