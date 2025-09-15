//
//  TransactionViewModel.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import Foundation
import Combine

final class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    private var cancellables: Set<AnyCancellable> = []
    private var planVM: PlanViewModel?
    private var planChangeCancellable: AnyCancellable?
    
    init(planViewModel: PlanViewModel? = nil) {
        self.planVM = planViewModel
        print("TransactionViewModel initialized")
        observePlanChanges()
        loadTransactions()
    }
    
    func setPlanViewModel(_ vm: PlanViewModel) {
        self.planVM = vm
        observePlanChanges()
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
            let key = planVM?.scopedKey(base: "SavedTransactions") ?? "SavedTransactions"
            UserDefaults.standard.set(encoded, forKey: key)
            // Remove synchronize() - it's blocking the UI
            print("Successfully saved \(transactions.count) transactions")
        } else {
            print("ERROR: Failed to encode transactions")
        }
    }
    
    private func loadTransactions() {
        print("Loading transactions from UserDefaults...")
        let key = planVM?.scopedKey(base: "SavedTransactions") ?? "SavedTransactions"
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
            print("Successfully loaded \(transactions.count) transactions")
        } else {
            print("No saved transactions found")
        }
    }

    private func observePlanChanges() {
        planChangeCancellable = NotificationCenter.default.publisher(for: .activePlanChanged)
            .sink { [weak self] _ in
                self?.loadTransactions()
            }
    }
    
    // MARK: - Aggregates

    func getWeeklyStats() -> [String: (count: Int, totalAmount: Double)] {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        let weeklyTransactions = transactions.filter { transaction in
            calendar.isDate(transaction.date, inSameDayAs: weekStart) || transaction.date > weekStart
        }
        
        var stats: [String: (count: Int, totalAmount: Double)] = [:]
        for transaction in weeklyTransactions {
            let key = transaction.category
            let current = stats[key] ?? (count: 0, totalAmount: 0)
            stats[key] = (count: current.count + 1, totalAmount: current.totalAmount + transaction.amount)
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

    func getStatsForDateRange(from startDate: Date, to endDate: Date) -> [String: (count: Int, percentage: Double, totalAmount: Double)] {
        let calendar = Calendar.current
        let filteredTransactions = transactions.filter { transaction in
            transaction.date >= startDate && transaction.date <= endDate
        }
        
        let totalTransactions = filteredTransactions.count
        guard totalTransactions > 0 else { return [:] }
        
        var stats: [String: (count: Int, percentage: Double, totalAmount: Double)] = [:]
        for transaction in filteredTransactions {
            let key = transaction.category
            let current = stats[key] ?? (count: 0, percentage: 0, totalAmount: 0)
            stats[key] = (count: current.count + 1,
                          percentage: 0,
                          totalAmount: current.totalAmount + transaction.amount)
        }
        // compute percentages
        for (key, value) in stats {
            stats[key]?.percentage = Double(value.count) / Double(totalTransactions) * 100
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
    
    func getStatsForPeriod(_ period: TimePeriod) -> [String: (count: Int, percentage: Double, totalAmount: Double)] {
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
