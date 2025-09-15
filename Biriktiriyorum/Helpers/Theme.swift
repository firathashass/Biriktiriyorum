//
//  Theme.swift
//  Biriktiriyorum
//
//  Fintech-grade shared theme, formatters, and haptics
//

import SwiftUI

enum AppTheme {
    // Colors tuned for fintech look
    static let background = Color(.systemBackground)
    static let surface = Color(.secondarySystemBackground)
    static let card = Color(.systemGray6)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let accent = Color.accentColor
    static let positive = Color.green
    static let negative = Color.red
    static let warning = Color.orange

    // Corner radius and spacing scale
    static let cornerRadius: CGFloat = 14
    static let smallRadius: CGFloat = 10
    static let shadowRadius: CGFloat = 8
    static let horizPadding: CGFloat = 20
}

enum Formatters {
    // Shared currency formatter for TRY (₺)
    static let currencyTRY: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "TRY"
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        return f
    }()

    // Shared short time formatter
    static let timeShort: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    // Shared long date (section headers)
    static let dateLong: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .none
        return f
    }()
}

enum Haptics {
    static func light() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.prepare()
        gen.impactOccurred()
    }
    static func success() {
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        gen.notificationOccurred(.success)
    }
    static func warning() {
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        gen.notificationOccurred(.warning)
    }
    static func error() {
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        gen.notificationOccurred(.error)
    }
}

extension Double {
    func asTRY() -> String {
        let ns = NSNumber(value: self)
        return Formatters.currencyTRY.string(from: ns) ?? "₺\(String(format: "%.2f", self))"
    }
}

