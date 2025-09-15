import Foundation

enum AccountType: String, CaseIterable, Identifiable, Codable {
    // YNAB’deki dört ana tür ve alt türleri
    case checking = "Checking"    // Cash account
    case savings  = "Savings"     // Cash account
    case cash     = "Cash"        // Cash account (otomatik cleared)
    case creditCard   = "Credit Card" // Credit account
    case lineOfCredit = "Line of Credit" // Credit account
    case mortgage  = "Mortgage"     // Loan account
    case autoLoan  = "Auto Loan"    // Loan account
    case studentLoan = "Student Loan" // Loan account
    case personalLoan = "Personal Loan"
    case medicalDebt  = "Medical Debt"
    case otherDebt    = "Other Debt"
    case trackingAsset  = "Tracking Asset"    // Tracking account
    case trackingLiability = "Tracking Liability" // Tracking account

    var id: String { rawValue }
}

