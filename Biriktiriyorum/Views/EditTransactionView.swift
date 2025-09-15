//
//  EditTransactionView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct EditTransactionView: View {
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    let transaction: Transaction
    
    @State private var amount: String
    @State private var selectedCategory: Category?
    
    @State private var note: String
    @State private var date: Date
    @State private var showSuccessMessage = false
    @State private var isAmountFocused = false
    @State private var isNoteFocused = false

    init(transaction: Transaction) {
        self.transaction = transaction
        self._amount = State(initialValue: String(format: "%.2f", transaction.amount))
        
        self._note = State(initialValue: transaction.note)
        self._date = State(initialValue: transaction.date)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemGray6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Amount Section
                        amountSection
                        
                        // Category Section
                        categorySection
                        
                        
                        
                        // Note Section
                        noteSection
                        
                        // Date Section
                        dateSection
                        
                        // Action Buttons
                        actionButtons
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Success message overlay
                if showSuccessMessage {
                    successOverlay
                }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .onAppear {
                setupInitialCategory()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onDisappear {
            hideKeyboard()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "pencil.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Edit Transaction")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Update your transaction details")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Amount Section
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "turkishlirasign.circle.fill")
                    .foregroundColor(.green)
                Text("Amount")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text("₺")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: $amount)
                    .font(.title)
                    .fontWeight(.bold)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onTapGesture {
                        isAmountFocused = true
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isAmountFocused ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "folder.circle.fill")
                    .foregroundColor(.orange)
                Text("Category")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            if categoryVM.categories.isEmpty {
                Text("No categories available")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(categoryVM.categories) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategory?.id == category.id
                        ) {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - Note Section
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text.circle.fill")
                    .foregroundColor(.purple)
                Text("Note (Optional)")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            TextEditor(text: $note)
                .frame(minHeight: 100)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isNoteFocused ? Color.blue : Color.clear, lineWidth: 2)
                        )
                )
                .onTapGesture {
                    isNoteFocused = true
                }
        }
    }
    
    // MARK: - Date Section
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(.indigo)
                Text("Date")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        Button(action: updateTransaction) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Update Transaction")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSave ? Color.blue : Color(.systemGray4))
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .disabled(!canSave)
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("Transaction updated successfully!")
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 40)
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: showSuccessMessage)
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !amount.isEmpty && selectedCategory != nil && Double(amount) != nil && Double(amount)! > 0
    }
    
    // MARK: - Methods
    private func setupInitialCategory() {
        selectedCategory = categoryVM.categories.first { $0.name == transaction.category }
    }
    
    private func updateTransaction() {
        guard canSave else { return }
        
        guard let amountValue = Double(amount), amountValue > 0 else {
            return
        }

        let updatedTransaction = Transaction(
            id: transaction.id,
            amount: amountValue,
            category: selectedCategory!.name,
            note: note,
            date: date
        )

        // Update transaction
        transactionVM.update(transaction: updatedTransaction)

        // Show success
        showSuccessMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showSuccessMessage = false
            dismiss()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.endEditing()
        isAmountFocused = false
        isNoteFocused = false
    }
}

// MARK: - Preview
#Preview {
    EditTransactionView(transaction: Transaction(
        amount: 150.0,
        category: "Food",
        note: "Lunch with friends",
        date: Date()
    ))
    .environmentObject(TransactionViewModel())
    .environmentObject(CategoryViewModel())
}