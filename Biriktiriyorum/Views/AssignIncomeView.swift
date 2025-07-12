//
//  AssignIncomeView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct AssignIncomeView: View {
    @EnvironmentObject var categoryVM: CategoryViewModel
    
    @State private var totalIncome: String = ""
    @State private var categoryAssignments: [String: String] = [:]
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showSuccessMessage = false
    @State private var expandedGroups: Set<String> = Set()
    
    // Initialize with all groups expanded by default
    private var initialExpandedGroups: Set<String> {
        Set(categoryVM.getAllGroups())
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
                        
                        // Income Input Section
                        incomeInputSection
                        
                        // Unassigned Amount Section
                        unassignedSection
                        
                        // Group Assignments Section
                        groupAssignmentsSection
                        
                        // Distribute Button
                        distributeButton
                        
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
            .navigationTitle("Assign Income")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            // Expand all groups by default
            expandedGroups = Set(categoryVM.getAllGroups())
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)
            
            Text("Assign Your Income")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Distribute your income across categories")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Income Input Section
    private var incomeInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "turkishlirasign.circle.fill")
                    .foregroundColor(.green)
                Text("Total Income")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text("₺")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: $totalIncome)
                    .font(.title)
                    .fontWeight(.bold)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: totalIncome) { _ in
                        validateAssignments()
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    // MARK: - Unassigned Section
    private var unassignedSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(unassignedAmount > 0 ? .orange : .green)
                Text("Unassigned")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("₺\(String(format: "%.2f", unassignedAmount))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(unassignedAmount > 0 ? .orange : .green)
            }
            
            if unassignedAmount > 0 {
                Text("You still have ₺\(String(format: "%.2f", unassignedAmount)) to assign")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if unassignedAmount < 0 {
                Text("You've assigned ₺\(String(format: "%.2f", abs(unassignedAmount))) more than your income")
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                Text("Perfect! All income is assigned")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Group Assignments Section
    private var groupAssignmentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "folder.circle.fill")
                    .foregroundColor(.blue)
                Text("Category Groups")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(categoryVM.getAllGroups(), id: \.self) { group in
                    GroupAssignmentSection(
                        group: group,
                        categories: categoryVM.getCategoriesInGroup(group),
                        categoryAssignments: $categoryAssignments,
                        isExpanded: expandedGroups.contains(group),
                        onToggleExpanded: {
                            if expandedGroups.contains(group) {
                                expandedGroups.remove(group)
                            } else {
                                expandedGroups.insert(group)
                            }
                        },
                        onAssignmentChange: { _ in
                            validateAssignments()
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Distribute Button
    private var distributeButton: some View {
        Button(action: distributeIncome) {
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                Text("Distribute Income")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canDistribute ? Color.green : Color(.systemGray4))
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .disabled(!canDistribute)
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("Income distributed successfully!")
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
    private var totalIncomeValue: Double {
        return Double(totalIncome) ?? 0.0
    }
    
    private var totalAssigned: Double {
        return categoryAssignments.values.compactMap { Double($0) }.reduce(0, +)
    }
    
    private var unassignedAmount: Double {
        return totalIncomeValue - totalAssigned
    }
    
    private var canDistribute: Bool {
        return totalIncomeValue > 0 && unassignedAmount == 0
    }
    
    // MARK: - Methods
    private func validateAssignments() {
        // This method is called when assignments change to update the UI
    }
    
    private func distributeIncome() {
        guard canDistribute else { return }
        
        for category in categoryVM.categories {
            if let assignmentString = categoryAssignments[category.name],
               let assignmentValue = Double(assignmentString),
               assignmentValue > 0 {
                categoryVM.updateCategoryBudget(category, assignedBudget: assignmentValue)
            }
        }
        
        // Show success message
        showSuccessMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showSuccessMessage = false
        }
        
        // Reset form after successful distribution
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            totalIncome = ""
            categoryAssignments = [:]
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.endEditing()
    }
}

// MARK: - Group Assignment Section Component
struct GroupAssignmentSection: View {
    let group: String
    let categories: [Category]
    @Binding var categoryAssignments: [String: String]
    let isExpanded: Bool
    let onToggleExpanded: () -> Void
    let onAssignmentChange: (String) -> Void
    
    private var groupTotalAssigned: Double {
        return categories.compactMap { category in
            Double(categoryAssignments[category.name] ?? "0")
        }.reduce(0, +)
    }
    
    private var groupColor: Color {
        switch group {
        case "Essentials":
            return .red
        case "Lifestyle":
            return .blue
        case "Savings":
            return .green
        default:
            return .orange
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Group Header
            Button(action: onToggleExpanded) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(groupColor)
                            Text(group)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("₺\(String(format: "%.2f", groupTotalAssigned)) assigned")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text("\(categories.count) categories")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Categories (if expanded)
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(categories) { category in
                        CategoryAssignmentRow(
                            category: category,
                            assignment: categoryAssignments[category.name] ?? "",
                            onAssignmentChange: { newValue in
                                categoryAssignments[category.name] = newValue
                                onAssignmentChange(newValue)
                            }
                        )
                    }
                }
                .padding(.leading, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

// MARK: - Category Assignment Row Component
struct CategoryAssignmentRow: View {
    let category: Category
    let assignment: String
    let onAssignmentChange: (String) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                HStack {
                    Text("Current: ₺\(String(format: "%.2f", category.assignedBudget))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("Remaining: ₺\(String(format: "%.2f", category.remainingBalance))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack {
                Text("₺")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: Binding(
                    get: { assignment },
                    set: { onAssignmentChange($0) }
                ))
                .font(.headline)
                .fontWeight(.medium)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Preview
#Preview {
    AssignIncomeView()
        .environmentObject(CategoryViewModel())
} 