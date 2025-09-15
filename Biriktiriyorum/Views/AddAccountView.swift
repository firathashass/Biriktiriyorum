//
//  AddAccountView.swift
//  Biriktiriyorum
//
//  Created by Assistant on 15.09.2025.
//

import SwiftUI

struct AddAccountView: View {
    @EnvironmentObject var accountVM: AccountViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var type: AccountType = .checking
    @State private var balance: String = "0"

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && Double(balance) != nil
    }

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Account name", text: $name)
                Picker("Type", selection: $type) {
                    ForEach(AccountType.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                TextField("Starting balance", text: $balance)
                    .keyboardType(.decimalPad)
            }
        }
        .navigationTitle("Add Account")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { save() }
                    .disabled(!canSave)
            }
        }
    }

    private func save() {
        guard let startBalance = Double(balance) else { return }
        let account = Account(name: name.trimmingCharacters(in: .whitespaces), type: type, balance: startBalance)
        accountVM.addAccount(account)
        dismiss()
    }
}

#Preview {
    NavigationView { AddAccountView() }
        .environmentObject(AccountViewModel())
}

