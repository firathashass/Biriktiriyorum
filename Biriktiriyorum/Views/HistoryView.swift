//
//  HistoryView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var transactionVM: TransactionViewModel
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    @State private var showingFilters = false
    @State private var selectedTransaction: Transaction?
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var transactionToDelete: Transaction?
    
    private var filteredTransactions: [Transaction] {
        let filtered = transactionVM.transactions.filter { transaction in
            let matchesSearch = searchText.isEmpty || 
                transaction.category.localizedCaseInsensitiveContains(searchText) ||
                transaction.note.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilter = selectedFilter == .all || transaction.emotion == selectedFilter.emotion
            
            return matchesSearch && matchesFilter
        }
        return filtered.sorted(by: { $0.date > $1.date })
    }
    
    private var groupedTransactions: [String: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            return formatter.string(from: transaction.date)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if filteredTransactions.isEmpty {
                    EmptyStateView(searchText: searchText, selectedFilter: selectedFilter)
                } else {
                    List {
                        ForEach(Array(groupedTransactions.keys.sorted(by: { 
                            let formatter = DateFormatter()
                            formatter.dateStyle = .full
                            return formatter.date(from: $0) ?? Date() > formatter.date(from: $1) ?? Date()
                        })), id: \.self) { date in
                            Section(header: Text(date)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .textCase(nil)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)) {
                                ForEach(groupedTransactions[date] ?? [], id: \.id) { transaction in
                                    TransactionCard(transaction: transaction)
                                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .contextMenu {
                                            Button(action: {
                                                selectedTransaction = transaction
                                                showingEditSheet = true
                                            }) {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            
                                            Button(role: .destructive, action: {
                                                transactionToDelete = transaction
                                                showingDeleteAlert = true
                                            }) {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                transactionToDelete = transaction
                                                showingDeleteAlert = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button {
                                                selectedTransaction = transaction
                                                showingEditSheet = true
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            .tint(.blue)
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        transactionVM.objectWillChange.send()
                    }
                }
            }
            .navigationTitle("Transaction History")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search transactions...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(selectedFilter == .all ? .primary : .blue)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(selectedFilter: $selectedFilter)
            }
            .sheet(isPresented: $showingEditSheet) {
                if let transaction = selectedTransaction {
                    EditTransactionView(transaction: transaction)
                        .environmentObject(transactionVM)
                }
            }
            .alert("Delete Transaction", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let transaction = transactionToDelete {
                        transactionVM.delete(transaction: transaction)
                        transactionToDelete = nil
                    }
                }
            } message: {
                Text("Are you sure you want to delete this transaction? This action cannot be undone.")
            }
        }
    }
}

struct TransactionCard: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.category)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(transaction.emotion.rawValue)
                        .font(.subheadline)
                        .foregroundColor(emotionColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(emotionColor.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₺\(transaction.amount, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(timeString(transaction.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !transaction.note.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "note.text")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(transaction.note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(emotionColor.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var emotionColor: Color {
        switch transaction.emotion {
        case .joyful:
            return .green
        case .regretful:
            return .red
        case .impulsive:
            return .orange
        case .neutral:
            return .gray
        }
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EmptyStateView: View {
    let searchText: String
    let selectedFilter: TransactionFilter
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(emptyStateTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(emptyStateMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    private var emptyStateTitle: String {
        if !searchText.isEmpty {
            return "No matching transactions"
        } else if selectedFilter != .all {
            return "No \(selectedFilter.displayName.lowercased()) transactions"
        } else {
            return "No transactions yet"
        }
    }
    
    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "Try adjusting your search terms or filters to find what you're looking for."
        } else if selectedFilter != .all {
            return "You haven't made any \(selectedFilter.displayName.lowercased()) transactions yet."
        } else {
            return "Start tracking your spending habits to see your transaction history here."
        }
    }
}

struct FilterView: View {
    @Binding var selectedFilter: TransactionFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        dismiss()
                    }) {
                        HStack {
                            Text(filter.displayName)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

enum TransactionFilter: CaseIterable {
    case all
    case joyful
    case regretful
    case impulsive
    case neutral
    
    var displayName: String {
        switch self {
        case .all:
            return "All Transactions"
        case .joyful:
            return "Joyful"
        case .regretful:
            return "Regretful"
        case .impulsive:
            return "Impulsive"
        case .neutral:
            return "Neutral"
        }
    }
    
    var emotion: EmotionTag? {
        switch self {
        case .all:
            return nil
        case .joyful:
            return .joyful
        case .regretful:
            return .regretful
        case .impulsive:
            return .impulsive
        case .neutral:
            return .neutral
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(TransactionViewModel())
}
