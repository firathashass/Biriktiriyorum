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
}
