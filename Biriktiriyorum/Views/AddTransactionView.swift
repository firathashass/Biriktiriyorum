//
//  AddTransactionView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct AddTransactionView: View {
    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var selectedEmotion: EmotionTag = .neutral
    @State private var note: String = ""
    @State private var date: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount (₺)")) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Category")) {
                    TextField("e.g. Food, Rent", text: $category)
                }
                
                Section(header: Text("Emotion")) {
                    Picker("Emotion", selection: $selectedEmotion) {
                        ForEach(EmotionTag.allCases) { emotion in
                            Text(emotion.rawValue).tag(emotion)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Note (Optional)")) {
                    TextEditor(text: $note)
                        .frame(height: 100)
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Select Date", selection: $date, displayedComponents: .date)
                }
                
                Button("Save Transaction") {
                    saveTransaction()
                }
            }
            .navigationTitle("Add Transaction")
        }
    }
    
    func saveTransaction() {
        guard let amountValue = Double(amount) else {
            print("Invalid amount")
            return
        }

        let transaction = Transaction(
            amount: amountValue,
            category: category,
            emotion: selectedEmotion,
            note: note,
            date: date
        )

        // For now, just print
        print("Saved:", transaction)
    }
}
