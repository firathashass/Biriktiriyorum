import Foundation
import Combine

class AccountViewModel: ObservableObject {
    @Published var accounts: [Account] = []

    init() {
        loadAccounts()
    }

    func addAccount(_ account: Account) {
        accounts.append(account)
        saveAccounts()
    }

    func deleteAccount(at offsets: IndexSet) {
        accounts.remove(atOffsets: offsets)
        saveAccounts()
    }

    func updateAccount(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
            saveAccounts()
        }
    }

    func adjustBalance(for accountID: UUID, by amount: Double) {
        if let index = accounts.firstIndex(where: { $0.id == accountID }) {
            accounts[index].balance += amount
            saveAccounts()
        }
    }

    // UserDefaults persistence
    private func saveAccounts() {
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: "SavedAccounts")
        }
    }

    private func loadAccounts() {
        if let data = UserDefaults.standard.data(forKey: "SavedAccounts"),
           let decoded = try? JSONDecoder().decode([Account].self, from: data) {
            accounts = decoded
        }
    }
}

