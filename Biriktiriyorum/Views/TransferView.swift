//
//  TransferView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct TransferView: View {
    @EnvironmentObject var categoryVM: CategoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedSourceCategory: Category?
    @State private var selectedDestinationCategory: Category?
    @State private var transferAmount: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isTransferring = false
    @State private var showingSourcePicker = false
    @State private var showingDestinationPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Transfer form
                        transferFormSection
                        
                        // Transfer button
                        transferButtonSection
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Transfer Money")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Transfer", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successful") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingSourcePicker) {
                CategoryPickerView(transferType: .source) { category in
                    selectedSourceCategory = category
                }
                .environmentObject(categoryVM)
            }
            .sheet(isPresented: $showingDestinationPicker) {
                CategoryPickerView(transferType: .destination) { category in
                    selectedDestinationCategory = category
                }
                .environmentObject(categoryVM)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transfer Money")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Move money between categories")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor.opacity(0.3))
            }
            
            Divider()
        }
    }
    
    // MARK: - Transfer Form Section
    private var transferFormSection: some View {
        VStack(spacing: 20) {
            // Source Category Selection
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.red)
                    Text("From Category")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                if let selectedSource = selectedSourceCategory {
                    selectedCategoryCard(category: selectedSource, isSource: true)
                } else {
                    categorySelectionButton(
                        title: "Select Source Category",
                        icon: "arrow.down.circle.fill",
                        color: .red
                    ) {
                        // Show category picker for source
                        showCategoryPicker(for: .source)
                    }
                }
            }
            
            // Transfer Arrow
            HStack {
                Spacer()
                Image(systemName: "arrow.down")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Spacer()
            }
            .padding(.vertical, 8)
            
            // Destination Category Selection
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                    Text("To Category")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                if let selectedDestination = selectedDestinationCategory {
                    selectedCategoryCard(category: selectedDestination, isSource: false)
                } else {
                    categorySelectionButton(
                        title: "Select Destination Category",
                        icon: "arrow.up.circle.fill",
                        color: .green
                    ) {
                        // Show category picker for destination
                        showCategoryPicker(for: .destination)
                    }
                }
            }
            
            // Amount Input
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.orange)
                    Text("Transfer Amount")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                TextField("Enter amount", text: $transferAmount)
                    .textFieldStyle(CustomTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .onChange(of: transferAmount) { newValue in
                        // Only allow numbers and decimal point
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            transferAmount = filtered
                        }
                        // Ensure only one decimal point
                        let components = filtered.components(separatedBy: ".")
                        if components.count > 2 {
                            transferAmount = components[0] + "." + components[1]
                        }
                    }
            }
        }
    }
    
    // MARK: - Transfer Button Section
    private var transferButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: performTransfer) {
                HStack {
                    if isTransferring {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.left.arrow.right.circle.fill")
                    }
                    Text(isTransferring ? "Transferring..." : "Transfer Money")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.accentColor, .accentColor.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(!canTransfer || isTransferring)
            .opacity(canTransfer ? 1.0 : 0.6)
            
            // Transfer summary
            if canTransfer, let amount = Double(transferAmount), amount > 0 {
                transferSummaryCard(amount: amount)
            }
        }
    }
    
    // MARK: - Helper Views
    private func selectedCategoryCard(category: Category, isSource: Bool) -> some View {
        HStack(spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                (isSource ? Color.red : Color.green).opacity(0.2),
                                (isSource ? Color.red : Color.green).opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Text(String(category.name.prefix(1)).uppercased())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(isSource ? .red : .green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Remaining: ₺\(String(format: "%.0f", category.remainingBalance))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                if isSource {
                    selectedSourceCategory = nil
                } else {
                    selectedDestinationCategory = nil
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private func categorySelectionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func transferSummaryCard(amount: Double) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Transfer Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Amount:")
                    Spacer()
                    Text("₺\(String(format: "%.0f", amount))")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("From:")
                    Spacer()
                    Text(selectedSourceCategory?.name ?? "")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                
                HStack {
                    Text("To:")
                    Spacer()
                    Text(selectedDestinationCategory?.name ?? "")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .font(.subheadline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Helper Methods
    private var canTransfer: Bool {
        guard let source = selectedSourceCategory,
              let destination = selectedDestinationCategory,
              let amount = Double(transferAmount),
              amount > 0 else {
            return false
        }
        
        return source.id != destination.id && source.remainingBalance >= amount
    }
    
    private func showCategoryPicker(for type: TransferType) {
        switch type {
        case .source:
            showingSourcePicker = true
        case .destination:
            showingDestinationPicker = true
        }
    }
    
    private func performTransfer() {
        guard let source = selectedSourceCategory,
              let destination = selectedDestinationCategory,
              let amount = Double(transferAmount),
              amount > 0 else {
            alertMessage = "Please fill in all fields correctly"
            showingAlert = true
            return
        }
        
        isTransferring = true
        
        // Simulate a brief delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let success = categoryVM.transferMoney(from: source, to: destination, amount: amount)
            
            isTransferring = false
            
            if success {
                alertMessage = "Successfully transferred ₺\(String(format: "%.0f", amount)) from \(source.name) to \(destination.name)"
                transferAmount = ""
                selectedSourceCategory = nil
                selectedDestinationCategory = nil
            } else {
                alertMessage = "Transfer failed. Please check the amount and try again."
            }
            
            showingAlert = true
        }
    }
}

// MARK: - Transfer Type Enum
enum TransferType {
    case source
    case destination
}

#Preview {
    TransferView()
        .environmentObject(CategoryViewModel())
} 