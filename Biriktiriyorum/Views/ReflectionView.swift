//
//  ReflectionView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI
 

struct ReflectionView: View {
    @StateObject private var transactionViewModel = TransactionViewModel()
    @State private var selectedPeriod: TimePeriod = .thisWeek
    
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Period Selector
                    timePeriodSelector
                    
                    // Header Stats
                    headerStatsView
                    
                    // Summary
                    summaryView
                }
                .padding()
            }
            .navigationTitle("Biriktiriyorum")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var timePeriodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Period")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TimePeriod.allCases) { period in
                        PeriodButton(
                            period: period,
                            isSelected: selectedPeriod == period,
                            action: { selectedPeriod = period }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var headerStatsView: some View {
        VStack(spacing: 16) {
            HStack {
                StatCard(
                    title: "Total Spent",
                    value: String(format: "%.2f ₺", transactionViewModel.getTotalSpentForPeriod(selectedPeriod)),
                    color: .blue
                )
                
                StatCard(
                    title: "Transactions",
                    value: "\(transactionViewModel.getTransactionCountForPeriod(selectedPeriod))",
                    color: .green
                )
            }
            
            if selectedPeriod != .thisWeek {
                HStack {
                    StatCard(
                        title: "This Week",
                        value: String(format: "%.2f ₺", transactionViewModel.getWeeklyTotal()),
                        color: .purple
                    )
                    
                    StatCard(
                        title: "This Week",
                        value: "\(transactionViewModel.getWeeklyStats().values.reduce(0) { $0 + $1.count })",
                        color: .orange
                    )
                }
            }
        }
    }
    
    private var summaryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary - \(selectedPeriod.displayText)")
                .font(.title2)
                .fontWeight(.bold)
            
            let stats = transactionViewModel.getStatsForPeriod(selectedPeriod)
            
            if stats.isEmpty {
                Text("No transactions in \(selectedPeriod.displayText.lowercased()).")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(stats.keys.sorted(), id: \.self) { key in
                        if let stat = stats[key] {
                            HStack {
                                Text(key)
                                Spacer()
                                Text("\(stat.count) | \(String(format: "%.2f ₺", stat.totalAmount))")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PeriodButton: View {
    let period: TimePeriod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(period.displayText)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    ReflectionView()
}
