//
//  HistoryView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var transactionVM: TransactionViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(transactionVM.transactions.sorted(by: { $0.date > $1.date })) { txn in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("₺\(txn.amount, specifier: "%.2f")")
                                .font(.headline)
                            Spacer()
                            Text(txn.emotion.rawValue)
                                .font(.subheadline)
                        }
                        Text(txn.category)
                            .font(.subheadline)
                        if !txn.note.isEmpty {
                            Text("📝 \(txn.note)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        Text(dateString(txn.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("History")
        }
    }

    func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
