//
//  Transaction.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id = UUID()
    let amount: Double
    let category: String
    let emotion: EmotionTag
    let note: String
    let date: Date
}

enum EmotionTag: String, CaseIterable, Identifiable, Codable {
    case joyful = "😊 Joyful"
    case regretful = "😔 Regretful"
    case impulsive = "⚡️ Impulsive"
    case neutral = "😐 Neutral"
    
    var id: String { self.rawValue }
}
