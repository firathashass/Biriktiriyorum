//
//  CategoryPickerView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct CategoryPickerView: View {
    @EnvironmentObject var categoryVM: CategoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    let transferType: TransferType
    let onCategorySelected: (Category) -> Void
    
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
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Categories list
                    categoriesList
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transferType == .source ? "From Category" : "To Category")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(transferType == .source ? "Select the category to transfer from" : "Select the category to transfer to")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Image(systemName: transferType == .source ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(transferType == .source ? .red : .green)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Divider()
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Categories List
    private var categoriesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(filteredCategories.enumerated()), id: \.element.id) { index, category in
                    CategoryPickerRowView(
                        category: category,
                        transferType: transferType,
                        onSelect: {
                            onCategorySelected(category)
                            dismiss()
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Computed Properties
    private var filteredCategories: [Category] {
        switch transferType {
        case .source:
            return categoryVM.categories.filter { $0.remainingBalance > 0 }
        case .destination:
            return categoryVM.categories
        }
    }
}

// MARK: - Category Picker Row View
struct CategoryPickerRowView: View {
    let category: Category
    let transferType: TransferType
    let onSelect: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                onSelect()
            }
        }) {
            HStack(spacing: 16) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    (transferType == .source ? Color.red : Color.green).opacity(0.2),
                                    (transferType == .source ? Color.red : Color.green).opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Text(String(category.name.prefix(1)).uppercased())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(transferType == .source ? .red : .green)
                }
                
                // Category details
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("Assigned: ₺\(String(format: "%.0f", category.assignedBudget))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("Remaining: ₺\(String(format: "%.0f", category.remainingBalance))")
                            .font(.caption)
                            .foregroundColor(category.remainingBalance > 0 ? .green : .red)
                    }
                    
                    // Progress bar
                    ProgressView(value: category.assignedBudget > 0 ? (category.assignedBudget - category.remainingBalance) / category.assignedBudget : 0)
                        .progressViewStyle(LinearProgressViewStyle(tint: category.remainingBalance > 0 ? .green : .red))
                        .scaleEffect(y: 0.5)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(transferType == .source && category.remainingBalance <= 0)
        .opacity(transferType == .source && category.remainingBalance <= 0 ? 0.5 : 1.0)
    }
}

#Preview {
    CategoryPickerView(transferType: .source) { _ in }
        .environmentObject(CategoryViewModel())
} 