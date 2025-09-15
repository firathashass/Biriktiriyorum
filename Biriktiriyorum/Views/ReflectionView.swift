//
//  ReflectionView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI
import Charts

struct ReflectionView: View {
    @EnvironmentObject var transactionVM: TransactionViewModel
    @State private var selectedPeriod: TimePeriod = .thisWeek
    
    private let emotionColors: [EmotionTag: Color] = [
        .joyful: .green,
        .regretful: .red,
        .impulsive: .orange,
        .neutral: .gray
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Period Selector
                    timePeriodSelector
                    
                    // Header Stats
                    headerStatsView
                    
                    // Emotional Spending Chart
                    emotionalSpendingChart
                    
                    // Weekly Summary
                    weeklySummaryView
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
                    value: String(format: "%.2f ₺", transactionVM.getTotalSpentForPeriod(selectedPeriod)),
                    color: .blue
                )
                
                StatCard(
                    title: "Transactions",
                    value: "\(transactionVM.getTransactionCountForPeriod(selectedPeriod))",
                    color: .green
                )
            }
            
            if selectedPeriod != .thisWeek {
                HStack {
                    StatCard(
                        title: "This Week",
                        value: String(format: "%.2f ₺", transactionVM.getWeeklyTotal()),
                        color: .purple
                    )
                    
                    StatCard(
                        title: "This Week",
                        value: "\(transactionVM.getWeeklyStats().values.reduce(0) { $0 + $1.count })",
                        color: .orange
                    )
                }
            }
        }
    }
    
    private var emotionalSpendingChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Emotional Spending - \(selectedPeriod.displayText)")
                .font(.title2)
                .fontWeight(.bold)
            
            let stats = transactionVM.getStatsForPeriod(selectedPeriod)
            
            if stats.isEmpty {
                Text("No transactions in \(selectedPeriod.displayText.lowercased()). Start tracking your spending to see emotional patterns!")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                // Pie Chart using Charts framework
                Chart {
                    ForEach(EmotionTag.allCases, id: \.self) { emotion in
                        if let stat = stats[emotion], stat.count > 0 {
                            SectorMark(
                                angle: .value("Count", stat.count),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(emotionColors[emotion] ?? .gray)
                        }
                    }
                }
                .frame(height: 200)
                
                // Legend
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(EmotionTag.allCases, id: \.self) { emotion in
                        if let stat = stats[emotion], stat.count > 0 {
                            HStack {
                                Circle()
                                    .fill(emotionColors[emotion] ?? .gray)
                                    .frame(width: 12, height: 12)
                                
                                VStack(alignment: .leading) {
                                    Text(emotion.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    Text("\(stat.count) (\(String(format: "%.1f", stat.percentage))%)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
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
    
    private var weeklySummaryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(selectedPeriod.displayText) Emotions")
                .font(.title2)
                .fontWeight(.bold)
            
            let periodStats = transactionVM.getStatsForPeriod(selectedPeriod)
            
            if periodStats.values.allSatisfy({ $0.count == 0 }) {
                Text("No transactions in \(selectedPeriod.displayText.lowercased()) yet.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(EmotionTag.allCases, id: \.self) { emotion in
                        if let stat = periodStats[emotion], stat.count > 0 {
                            HStack {
                                Text(emotion.rawValue)
                                    .font(.body)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("\(stat.count) transactions")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(String(format: "%.2f ₺", stat.totalAmount))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }
                            .padding(.vertical, 4)
                            
                            if emotion != EmotionTag.allCases.last {
                                Divider()
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
    let accountVM = AccountViewModel()
    let transactionVM = TransactionViewModel(accountViewModel: accountVM)
    return NavigationView {
        ReflectionView()
            .environmentObject(transactionVM)
    }
}
