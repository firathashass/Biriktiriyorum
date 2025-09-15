//
//  AccountListView.swift
//  Biriktiriyorum
//
//  Created by Assistant on 15.09.2025.
//

import SwiftUI

struct AccountListView: View {
    @EnvironmentObject var accountVM: AccountViewModel
    @State private var showingAddSheet = false

    var body: some View {
        List {
            if accountVM.accounts.isEmpty {
                Section {
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "creditcard")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("No accounts yet")
                            .foregroundColor(.secondary)
                        Text("Tap + to add your first account")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
                }
            } else {
                Section(header: Text("Accounts")) {
                    ForEach(accountVM.accounts) { account in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(account.name)
                                    .font(.headline)
                                Text(account.type.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("₺\(String(format: "%.2f", account.balance))")
                                .font(.headline)
                                .foregroundColor(account.balance >= 0 ? .primary : .red)
                        }
                    }
                    .onDelete(perform: accountVM.deleteAccount)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationView { AddAccountView() }
                .environmentObject(accountVM)
        }
    }
}

#Preview {
    NavigationView {
        AccountListView()
            .environmentObject(AccountViewModel())
    }
}

