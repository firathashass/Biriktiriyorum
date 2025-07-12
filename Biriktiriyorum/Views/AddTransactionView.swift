//
//  AddTransactionView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var amount: String = ""
    @State private var selectedCategory: Category?
    @State private var selectedEmotion: EmotionTag?
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showSuccessMessage = false
    @State private var isAmountFocused = false
    @State private var isNoteFocused = false
    @State private var showingBudgetAlert = false

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
                        
                        // Emotion Section
                        emotionSection
                        
                        // Note Section
                        noteSection
                        
                        // Date Section
                        dateSection
                        
                        // Save Button
                        saveButton
                        
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
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .alert("Insufficient Budget", isPresented: $showingBudgetAlert) {
                Button("OK") { }
            } message: {
                Text("The selected category doesn't have enough budget remaining for this transaction.")
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
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Add New Transaction")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Track your spending and emotions")
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
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(categoryVM.getAllGroups(), id: \.self) { group in
                        CategoryGroupSection(
                            group: group,
                            categories: categoryVM.getCategoriesInGroup(group),
                            selectedCategory: $selectedCategory
                        )
                    }
                }
            }
            
            // Budget information for selected category
            if let selectedCategory = selectedCategory {
                let category = categoryVM.getCategoryByName(selectedCategory.name)
                if let category = category {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Budget Info:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Assigned: ₺\(String(format: "%.2f", category.assignedBudget))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Remaining: ₺\(String(format: "%.2f", category.remainingBalance))")
                                    .font(.caption)
                                    .foregroundColor(category.remainingBalance > 0 ? .green : .red)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Emotion Section
    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.pink)
                Text("How do you feel about this purchase?")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(EmotionTag.allCases) { emotion in
                    EmotionCard(
                        emotion: emotion,
                        isSelected: selectedEmotion == emotion
                    ) {
                        selectedEmotion = emotion
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
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveTransaction) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Transaction")
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
                Text("Transaction saved successfully!")
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
        !amount.isEmpty && selectedCategory != nil && selectedEmotion != nil && Double(amount) != nil && Double(amount)! > 0
    }
    
    // MARK: - Methods
    private func saveTransaction() {
        guard canSave else { return }
        
        guard let amountValue = Double(amount), amountValue > 0 else {
            return
        }
        
        // Check if category has enough budget
        if let selectedCategory = selectedCategory {
            let category = categoryVM.getCategoryByName(selectedCategory.name)
            if let category = category {
                if category.remainingBalance < amountValue {
                    showingBudgetAlert = true
                    return
                }
            }
        }

        let transaction = Transaction(
            amount: amountValue,
            category: selectedCategory!.name,
            emotion: selectedEmotion!,
            note: note,
            date: date
        )

        // Add transaction
        transactionVM.add(transaction: transaction)
        
        // Subtract from category balance
        if let selectedCategory = selectedCategory {
            _ = categoryVM.subtractFromCategoryBalance(selectedCategory.name, amount: amountValue)
        }

        // Reset form
        amount = ""
        selectedCategory = nil
        selectedEmotion = nil
        note = ""
        date = Date()
        isAmountFocused = false
        isNoteFocused = false

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

// MARK: - Category Card Component
struct CategoryCard: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .orange)
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                
                // Show remaining balance
                Text("₺\(String(format: "%.0f", category.remainingBalance))")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : (category.remainingBalance > 0 ? .green : .red))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.orange : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Emotion Card Component
struct EmotionCard: View {
    let emotion: EmotionTag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Extract emoji (first character)
                Text(String(emotion.rawValue.prefix(1)))
                    .font(.title2)
                
                // Extract text (everything after the emoji and space)
                Text(emotion.rawValue.dropFirst(2).trimmingCharacters(in: .whitespaces))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.pink : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Category Group Section Component
struct CategoryGroupSection: View {
    let group: String
    let categories: [Category]
    @Binding var selectedCategory: Category?
    
    private var groupColor: Color {
        switch group {
        case "Essentials":
            return .red
        case "Lifestyle":
            return .blue
        case "Savings":
            return .green
        default:
            return .purple
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Group Header
            HStack {
                ZStack {
                    Circle()
                        .fill(groupColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "folder.fill")
                        .font(.caption)
                        .foregroundColor(groupColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(group)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(categories.count) categories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Group budget summary
                let groupBudget = getGroupBudget()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("₺\(String(format: "%.0f", groupBudget.remaining))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(groupBudget.remaining > 0 ? .green : .red)
                    
                    Text("remaining")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            // Categories Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(categories) { category in
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
    
    private func getGroupBudget() -> (assigned: Double, remaining: Double, spent: Double) {
        let assigned = categories.reduce(0) { $0 + $1.assignedBudget }
        let remaining = categories.reduce(0) { $0 + $1.remainingBalance }
        let spent = assigned - remaining
        return (assigned, remaining, spent)
    }
}

// MARK: - Preview
#Preview {
    AddTransactionView()
        .environmentObject(TransactionViewModel())
        .environmentObject(CategoryViewModel())
}
