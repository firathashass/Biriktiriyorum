//
//  TransactionViewModel.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import Foundation

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    init() {
        print("TransactionViewModel initialized")
        loadTransactions()
    }
    
    func add(transaction: Transaction) {
        print("Adding transaction: \(transaction)")
        transactions.append(transaction)
        print("Total transactions: \(transactions.count)")
        
        // Save in background to avoid blocking UI
        DispatchQueue.global(qos: .utility).async {
            self.saveTransactions()
        }
    }
    
    func update(transaction: Transaction) {
        print("Updating transaction: \(transaction)")
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            print("Successfully updated transaction at index \(index)")
            
            // Save in background to avoid blocking UI
            DispatchQueue.global(qos: .utility).async {
                self.saveTransactions()
            }
        } else {
            print("ERROR: Transaction not found for updating")
        }
    }
    
    func delete(transaction: Transaction) {
        print("Deleting transaction: \(transaction)")
        transactions.removeAll { $0.id == transaction.id }
        print("Total transactions after deletion: \(transactions.count)")
        
        // Save in background to avoid blocking UI
        DispatchQueue.global(qos: .utility).async {
            self.saveTransactions()
        }
    }
    
    func delete(at offsets: IndexSet) {
        print("Deleting transactions at offsets: \(offsets)")
        transactions.remove(atOffsets: offsets)
        print("Total transactions after deletion: \(transactions.count)")
        
        // Save in background to avoid blocking UI
        DispatchQueue.global(qos: .utility).async {
            self.saveTransactions()
        }
    }
    
    private func saveTransactions() {
        print("Saving transactions to UserDefaults...")
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: "SavedTransactions")
            // Remove synchronize() - it's blocking the UI
            print("Successfully saved \(transactions.count) transactions")
        } else {
            print("ERROR: Failed to encode transactions")
        }
    }
    
    private func loadTransactions() {
        print("Loading transactions from UserDefaults...")
        if let data = UserDefaults.standard.data(forKey: "SavedTransactions"),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
            print("Successfully loaded \(transactions.count) transactions")
        } else {
            print("No saved transactions found")
        }
    }
    
    // MARK: - Reflection Statistics
    
    func getEmotionalSpendingStats() -> [EmotionTag: (count: Int, percentage: Double, totalAmount: Double)] {
        let totalTransactions = transactions.count
        guard totalTransactions > 0 else { return [:] }
        
        var stats: [EmotionTag: (count: Int, percentage: Double, totalAmount: Double)] = [:]
        
        for emotion in EmotionTag.allCases {
            let emotionTransactions = transactions.filter { $0.emotion == emotion }
            let count = emotionTransactions.count
            let percentage = Double(count) / Double(totalTransactions) * 100
            let totalAmount = emotionTransactions.reduce(0) { $0 + $1.amount }
            
            stats[emotion] = (count: count, percentage: percentage, totalAmount: totalAmount)
        }
        
        return stats
    }
    
    func getWeeklyStats() -> [EmotionTag: (count: Int, totalAmount: Double)] {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        let weeklyTransactions = transactions.filter { transaction in
            calendar.isDate(transaction.date, inSameDayAs: weekStart) || transaction.date > weekStart
        }
        
        var stats: [EmotionTag: (count: Int, totalAmount: Double)] = [:]
        
        for emotion in EmotionTag.allCases {
            let emotionTransactions = weeklyTransactions.filter { $0.emotion == emotion }
            let count = emotionTransactions.count
            let totalAmount = emotionTransactions.reduce(0) { $0 + $1.amount }
            
            stats[emotion] = (count: count, totalAmount: totalAmount)
        }
        
        return stats
    }
    
    func getTotalSpent() -> Double {
        return transactions.reduce(0) { $0 + $1.amount }
    }
    
    func getWeeklyTotal() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        let weeklyTransactions = transactions.filter { transaction in
            calendar.isDate(transaction.date, inSameDayAs: weekStart) || transaction.date > weekStart
        }
        
        return weeklyTransactions.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Date Range Statistics
    
    func getStatsForDateRange(from startDate: Date, to endDate: Date) -> [EmotionTag: (count: Int, percentage: Double, totalAmount: Double)] {
        let calendar = Calendar.current
        let filteredTransactions = transactions.filter { transaction in
            transaction.date >= startDate && transaction.date <= endDate
        }
        
        let totalTransactions = filteredTransactions.count
        guard totalTransactions > 0 else { return [:] }
        
        var stats: [EmotionTag: (count: Int, percentage: Double, totalAmount: Double)] = [:]
        
        for emotion in EmotionTag.allCases {
            let emotionTransactions = filteredTransactions.filter { $0.emotion == emotion }
            let count = emotionTransactions.count
            let percentage = Double(count) / Double(totalTransactions) * 100
            let totalAmount = emotionTransactions.reduce(0) { $0 + $1.amount }
            
            stats[emotion] = (count: count, percentage: percentage, totalAmount: totalAmount)
        }
        
        return stats
    }
    
    func getTotalSpentForDateRange(from startDate: Date, to endDate: Date) -> Double {
        let filteredTransactions = transactions.filter { transaction in
            transaction.date >= startDate && transaction.date <= endDate
        }
        return filteredTransactions.reduce(0) { $0 + $1.amount }
    }
    
    func getTransactionCountForDateRange(from startDate: Date, to endDate: Date) -> Int {
        let filteredTransactions = transactions.filter { transaction in
            transaction.date >= startDate && transaction.date <= endDate
        }
        return filteredTransactions.count
    }
    
    // MARK: - Predefined Periods
    
    func getStatsForPeriod(_ period: TimePeriod) -> [EmotionTag: (count: Int, percentage: Double, totalAmount: Double)] {
        let (startDate, endDate) = period.dateRange
        return getStatsForDateRange(from: startDate, to: endDate)
    }
    
    func getTotalSpentForPeriod(_ period: TimePeriod) -> Double {
        let (startDate, endDate) = period.dateRange
        return getTotalSpentForDateRange(from: startDate, to: endDate)
    }
    
    func getTransactionCountForPeriod(_ period: TimePeriod) -> Int {
        let (startDate, endDate) = period.dateRange
        return getTransactionCountForDateRange(from: startDate, to: endDate)
    }
}

// MARK: - Time Period Enum

enum TimePeriod: String, CaseIterable, Identifiable {
    case thisWeek = "This Week"
    case lastWeek = "Last Week"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case last3Months = "Last 3 Months"
    case last6Months = "Last 6 Months"
    case thisYear = "This Year"
    case allTime = "All Time"
    
    var id: String { self.rawValue }
    
    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .thisWeek:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return (weekStart, now)
            
        case .lastWeek:
            let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart) ?? now
            let lastWeekEnd = calendar.date(byAdding: .day, value: -1, to: thisWeekStart) ?? now
            return (lastWeekStart, lastWeekEnd)
            
        case .thisMonth:
            let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return (monthStart, now)
            
        case .lastMonth:
            let thisMonthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart) ?? now
            let lastMonthEnd = calendar.date(byAdding: .day, value: -1, to: thisMonthStart) ?? now
            return (lastMonthStart, lastMonthEnd)
            
        case .last3Months:
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return (threeMonthsAgo, now)
            
        case .last6Months:
            let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) ?? now
            return (sixMonthsAgo, now)
            
        case .thisYear:
            let yearStart = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return (yearStart, now)
            
        case .allTime:
            let distantPast = calendar.date(byAdding: .year, value: -100, to: now) ?? now
            return (distantPast, now)
        }
    }
    
    var displayText: String {
        switch self {
        case .thisWeek:
            return "This Week"
        case .lastWeek:
            return "Last Week"
        case .thisMonth:
            return "This Month"
        case .lastMonth:
            return "Last Month"
        case .last3Months:
            return "Last 3 Months"
        case .last6Months:
            return "Last 6 Months"
        case .thisYear:
            return "This Year"
        case .allTime:
            return "All Time"
        }
    }
}
