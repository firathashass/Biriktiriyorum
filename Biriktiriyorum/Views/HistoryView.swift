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
    @State private var selectedTransaction: Transaction?
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var transactionToDelete: Transaction?
    
    private var filteredTransactions: [Transaction] {
        let filtered = transactionVM.transactions.filter { transaction in
            let matchesSearch = searchText.isEmpty || 
                transaction.category.localizedCaseInsensitiveContains(searchText) ||
                transaction.note.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilter = true
            
            return matchesSearch && matchesFilter
        }
        return filtered.sorted(by: { $0.date > $1.date })
    }
    
    private var groupedTransactions: [String: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Formatters.dateLong.string(from: transaction.date)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.surface
                    .ignoresSafeArea()
                
                if filteredTransactions.isEmpty {
                    EmptyStateView(searchText: searchText)
                } else {
                    List {
                        ForEach(Array(groupedTransactions.keys.sorted(by: { 
                            Formatters.dateLong.date(from: $0) ?? Date() > Formatters.dateLong.date(from: $1) ?? Date()
                        })), id: \.self) { date in
                            Section(header: Text(date)
                                .font(.headline)
                                .foregroundColor(AppTheme.primaryText)
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
                        .foregroundColor(AppTheme.primaryText)
                    
                    
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(transaction.amount.asTRY())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.primaryText)
                    
                    Text(Formatters.timeShort.string(from: transaction.date))
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            
            if !transaction.note.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "note.text")
                        .foregroundColor(AppTheme.secondaryText)
                        .font(.caption)
                    
                    Text(transaction.note)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(16)
        .background(AppTheme.background)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: AppTheme.shadowRadius, x: 0, y: 2)
        
    }
    
    
    
    
}

struct EmptyStateView: View {
    let searchText: String
    
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
    
    private var emptyStateTitle: String { !searchText.isEmpty ? "No matching transactions" : "No transactions yet" }
    
    private var emptyStateMessage: String { !searchText.isEmpty ? "Try adjusting your search terms to find what you're looking for." : "Start tracking your spending habits to see your transaction history here." }
}

    

#Preview {
    HistoryView()
        .environmentObject(TransactionViewModel())
}
