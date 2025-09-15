import Foundation

struct Account: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: AccountType
    var balance: Double

    init(name: String, type: AccountType, balance: Double = 0.0) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.balance = balance
    }

    init(id: UUID, name: String, type: AccountType, balance: Double) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
    }
}

