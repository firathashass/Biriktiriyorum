//
//  CategoryView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var categoryVM: CategoryViewModel
    @State private var newCategoryName = ""
    @State private var newCategoryGroup = "Other"
    @State private var isAddingCategory = false
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: Category?
    @State private var editingCategory: Category?
    @State private var editingText = ""
    @State private var showingTransferView = false
    @State private var expandedGroups: Set<String> = Set(CategoryViewModel.defaultGroups)
    @State private var showingGroupManagement = false
    @State private var showingMoveCategory = false
    @State private var categoryToMove: Category?
    @State private var newGroupName = ""
    @State private var isAddingGroup = false
    @State private var editingGroup: String?
    @State private var editingGroupText = ""
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isEditingTextFieldFocused: Bool
    @FocusState private var isGroupTextFieldFocused: Bool
    @FocusState private var isEditingGroupTextFieldFocused: Bool
    @State private var newGoalAmount: String = ""
    @State private var newMonthlyBillAmount: String = ""
    @State private var editingGoalAmount: String = ""
    @State private var editingMonthlyBillAmount: String = ""
    
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
                    // Header section
                    headerSection
                    
                    // Categories list
                    categoriesList
                    
                    // Add category section
                    addCategorySection
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingTransferView = true
                    }) {
                        Image(systemName: "arrow.left.arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: {
                            showingGroupManagement = true
                        }) {
                            Image(systemName: "folder.badge.gearshape")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                isAddingCategory.toggle()
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingTransferView) {
                TransferView()
                    .environmentObject(categoryVM)
            }
            .sheet(isPresented: $showingGroupManagement) {
                GroupManagementView(
                    categoryVM: categoryVM,
                    isPresented: $showingGroupManagement
                )
            }
            .alert("Delete Category", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete,
                       let index = categoryVM.categories.firstIndex(of: category) {
                        withAnimation(.spring()) {
                            categoryVM.removeCategory(at: IndexSet(integer: index))
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this category? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(categoryVM.categories.count)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.accentColor)
                    Text("Total Categories")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Image(systemName: "folder.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor.opacity(0.3))
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Budget Summary Section
            budgetSummarySection
            
            Divider()
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Budget Summary Section
    private var budgetSummarySection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.green)
                Text("Budget Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                // Total Assigned
                BudgetSummaryCard(
                    title: "Assigned",
                    amount: totalAssignedBudget,
                    color: .blue,
                    icon: "dollarsign.circle.fill"
                )
                
                // Total Remaining
                BudgetSummaryCard(
                    title: "Remaining",
                    amount: totalRemainingBudget,
                    color: totalRemainingBudget >= 0 ? .green : .red,
                    icon: "creditcard.fill"
                )
                
                // Total Spent
                BudgetSummaryCard(
                    title: "Spent",
                    amount: totalSpent,
                    color: .orange,
                    icon: "cart.fill"
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Categories List
    private var categoriesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(categoryVM.getAllGroups(), id: \.self) { group in
                    GroupSectionView(
                        group: group,
                        categories: categoryVM.getCategoriesInGroup(group),
                        isExpanded: expandedGroups.contains(group),
                        onToggle: {
                            withAnimation(.spring()) {
                                if expandedGroups.contains(group) {
                                    expandedGroups.remove(group)
                                } else {
                                    expandedGroups.insert(group)
                                }
                            }
                        },
                        onDelete: { category in
                            categoryToDelete = category
                            showingDeleteAlert = true
                        },
                        onEdit: { category in
                            startEditing(category)
                        },
                        onSave: {
                            saveEdit()
                        },
                        onCancel: {
                            cancelEdit()
                        },
                        onTransfer: {
                            showingTransferView = true
                        },
                        onMove: { category in
                            categoryToMove = category
                            showingMoveCategory = true
                        },
                        editingCategory: editingCategory,
                        editingText: $editingText,
                        editingGoalAmount: $editingGoalAmount,
                        editingMonthlyBillAmount: $editingMonthlyBillAmount
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showingMoveCategory) {
            if let category = categoryToMove {
                MoveCategoryView(
                    category: category,
                    categoryVM: categoryVM,
                    isPresented: $showingMoveCategory
                )
            }
        }
    }
    
    // MARK: - Add Category Section
    private var addCategorySection: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                if isAddingCategory {
                    addCategoryForm
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                HStack {
                    if !isAddingCategory {
                        Button(action: {
                            withAnimation(.spring()) {
                                isAddingCategory = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isTextFieldFocused = true
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add New Category")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.accentColor, .accentColor.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Add Category Form
    private var addCategoryForm: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Category name", text: $newCategoryName)
                    .textFieldStyle(CustomTextFieldStyle())
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        addCategory()
                    }
                
                Menu {
                    ForEach(categoryVM.getAllAvailableGroups(), id: \.self) { group in
                        Button(group) {
                            newCategoryGroup = group
                        }
                    }
                } label: {
                    Text(newCategoryGroup)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.accentColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                
                Button(action: addCategory) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(newCategoryName.isEmpty ? .gray : .green)
                }
                .disabled(newCategoryName.isEmpty)
                
                Button(action: {
                    withAnimation(.spring()) {
                        isAddingCategory = false
                        newCategoryName = ""
                        newCategoryGroup = "Other"
                        isTextFieldFocused = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            HStack(spacing: 12) {
                TextField("Goal (optional)", text: $newGoalAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(CustomTextFieldStyle())
                TextField("Monthly Bill (optional)", text: $newMonthlyBillAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            .padding(.horizontal, 0)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helper Methods
    private func addCategory() {
        guard !newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let goal = Double(newGoalAmount.trimmingCharacters(in: .whitespacesAndNewlines))
        let bill = Double(newMonthlyBillAmount.trimmingCharacters(in: .whitespacesAndNewlines))
        withAnimation(.spring()) {
            categoryVM.addCategory(name: newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines), group: newCategoryGroup, goalAmount: goal, monthlyBillAmount: bill)
            newCategoryName = ""
            newCategoryGroup = "Other"
            newGoalAmount = ""
            newMonthlyBillAmount = ""
            isAddingCategory = false
            isTextFieldFocused = false
            if !expandedGroups.contains(newCategoryGroup) {
                expandedGroups.insert(newCategoryGroup)
            }
        }
    }
    
    private func startEditing(_ category: Category) {
        editingCategory = category
        editingText = category.name
        editingGoalAmount = category.goalAmount != nil ? String(format: "%.0f", category.goalAmount!) : ""
        editingMonthlyBillAmount = category.monthlyBillAmount != nil ? String(format: "%.0f", category.monthlyBillAmount!) : ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isEditingTextFieldFocused = true
        }
    }
    
    private func saveEdit() {
        guard let category = editingCategory,
              !editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let goal = Double(editingGoalAmount.trimmingCharacters(in: .whitespacesAndNewlines))
        let bill = Double(editingMonthlyBillAmount.trimmingCharacters(in: .whitespacesAndNewlines))
        withAnimation(.spring()) {
            categoryVM.updateCategory(category, newName: editingText.trimmingCharacters(in: .whitespacesAndNewlines), goalAmount: goal, monthlyBillAmount: bill)
            editingCategory = nil
            editingText = ""
            editingGoalAmount = ""
            editingMonthlyBillAmount = ""
            isEditingTextFieldFocused = false
        }
    }
    
    private func cancelEdit() {
        withAnimation(.spring()) {
            editingCategory = nil
            editingText = ""
            editingGoalAmount = ""
            editingMonthlyBillAmount = ""
            isEditingTextFieldFocused = false
        }
    }
    
    // MARK: - Computed Properties
    private var totalAssignedBudget: Double {
        return categoryVM.categories.reduce(0) { $0 + $1.assignedBudget }
    }
    
    private var totalRemainingBudget: Double {
        return categoryVM.categories.reduce(0) { $0 + $1.remainingBalance }
    }
    
    private var totalSpent: Double {
        return categoryVM.categories.reduce(0) { $0 + ($1.assignedBudget - $1.remainingBalance) }
    }
}

// MARK: - Group Management View
struct GroupManagementView: View {
    @ObservedObject var categoryVM: CategoryViewModel
    @Binding var isPresented: Bool
    @State private var newGroupName = ""
    @State private var editingGroup: String?
    @State private var editingGroupText = ""
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isEditingTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Add new group section
                    addGroupSection
                    
                    // Groups list
                    groupsList
                }
            }
            .navigationTitle("Manage Groups")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private var addGroupSection: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("New group name", text: $newGroupName)
                    .textFieldStyle(CustomTextFieldStyle())
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        addGroup()
                    }
                
                Button(action: addGroup) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(newGroupName.isEmpty ? .gray : .green)
                }
                .disabled(newGroupName.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var groupsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(categoryVM.getAllAvailableGroups(), id: \.self) { group in
                    GroupManagementRowView(
                        group: group,
                        categoryCount: categoryVM.getCategoriesInGroup(group).count,
                        isDefault: categoryVM.isDefaultGroup(group),
                        isCustom: categoryVM.isCustomGroup(group),
                        isEditing: editingGroup == group,
                        editingText: $editingGroupText,
                        onEdit: {
                            startEditing(group)
                        },
                        onSave: {
                            saveEdit()
                        },
                        onCancel: {
                            cancelEdit()
                        },
                        onDelete: {
                            deleteGroup(group)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .scrollIndicators(.hidden)
    }
    
    private func addGroup() {
        guard !newGroupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        withAnimation(.spring()) {
            categoryVM.addCustomGroup(newGroupName.trimmingCharacters(in: .whitespacesAndNewlines))
            newGroupName = ""
            isTextFieldFocused = false
        }
    }
    
    private func startEditing(_ group: String) {
        editingGroup = group
        editingGroupText = group
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isEditingTextFieldFocused = true
        }
    }
    
    private func saveEdit() {
        guard let group = editingGroup,
              !editingGroupText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        withAnimation(.spring()) {
            if categoryVM.isCustomGroup(group) {
                categoryVM.editCustomGroup(group, newName: editingGroupText.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            editingGroup = nil
            editingGroupText = ""
            isEditingTextFieldFocused = false
        }
    }
    
    private func cancelEdit() {
        withAnimation(.spring()) {
            editingGroup = nil
            editingGroupText = ""
            isEditingTextFieldFocused = false
        }
    }
    
    private func deleteGroup(_ group: String) {
        withAnimation(.spring()) {
            categoryVM.removeCustomGroup(group)
        }
    }
}

// MARK: - Group Management Row View
struct GroupManagementRowView: View {
    let group: String
    let categoryCount: Int
    let isDefault: Bool
    let isCustom: Bool
    let isEditing: Bool
    @Binding var editingText: String
    let onEdit: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Group icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                isDefault ? Color.blue.opacity(0.2) : Color.purple.opacity(0.2),
                                isDefault ? Color.blue.opacity(0.1) : Color.purple.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: isDefault ? "star.fill" : "folder.fill")
                    .font(.title3)
                    .foregroundColor(isDefault ? .blue : .purple)
            }
            
            // Group name or editing field
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextField("Group name", text: $editingText)
                        .textFieldStyle(InlineTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            onSave()
                        }
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(group)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if isDefault {
                                Text("(Default)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text("\(categoryCount) categories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Action buttons
            if isEditing {
                HStack(spacing: 8) {
                    Button(action: onSave) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(editingText.isEmpty ? .gray : .green)
                    }
                    .disabled(editingText.isEmpty)
                    
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    if isCustom {
                        Button(action: onEdit) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue.opacity(0.7))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: onDelete) {
                            Image(systemName: "trash.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red.opacity(0.7))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(categoryCount > 0)
                    }
                }
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
}

// MARK: - Move Category View
struct MoveCategoryView: View {
    let category: Category
    @ObservedObject var categoryVM: CategoryViewModel
    @Binding var isPresented: Bool
    @State private var selectedGroup: String
    
    init(category: Category, categoryVM: CategoryViewModel, isPresented: Binding<Bool>) {
        self.category = category
        self.categoryVM = categoryVM
        self._isPresented = isPresented
        self._selectedGroup = State(initialValue: category.group)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Category info
                    VStack(spacing: 12) {
                        Text("Move Category")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(category.name)
                            .font(.headline)
                            .foregroundColor(.accentColor)
                        
                        Text("Currently in: \(category.group)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Group selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select New Group")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(categoryVM.getAllAvailableGroups(), id: \.self) { group in
                                    GroupSelectionRow(
                                        group: group,
                                        isSelected: selectedGroup == group,
                                        categoryCount: categoryVM.getCategoriesInGroup(group).count,
                                        onSelect: {
                                            selectedGroup = group
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button("Cancel") {
                            isPresented = false
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Move") {
                            moveCategory()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(selectedGroup == category.group)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func moveCategory() {
        withAnimation(.spring()) {
            categoryVM.updateCategoryGroup(category, newGroup: selectedGroup)
            isPresented = false
        }
    }
}

// MARK: - Group Selection Row
struct GroupSelectionRow: View {
    let group: String
    let isSelected: Bool
    let categoryCount: Int
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1),
                                    isSelected ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    } else {
                        Image(systemName: "folder.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(group)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(categoryCount) categories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Group Section View
struct GroupSectionView: View {
    let group: String
    let categories: [Category]
    let isExpanded: Bool
    let onToggle: () -> Void
    let onDelete: (Category) -> Void
    let onEdit: (Category) -> Void
    let onSave: () -> Void
    let onCancel: () -> Void
    let onTransfer: () -> Void
    let onMove: (Category) -> Void
    let editingCategory: Category?
    @Binding var editingText: String
    @Binding var editingGoalAmount: String
    @Binding var editingMonthlyBillAmount: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Group Header
            Button(action: onToggle) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(group)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("(\(categories.count))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Group budget summary
                        let groupBudget = getGroupBudget()
                        HStack {
                            Text("₺\(String(format: "%.0f", groupBudget.assigned)) assigned")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text("₺\(String(format: "%.0f", groupBudget.remaining)) remaining")
                                .font(.caption)
                                .foregroundColor(groupBudget.remaining > 0 ? .green : .red)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Categories in group
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                        CategoryRowView(
                            category: category,
                            index: index,
                            isEditing: editingCategory?.id == category.id,
                            editingText: $editingText,
                            editingGoalAmount: $editingGoalAmount,
                            editingMonthlyBillAmount: $editingMonthlyBillAmount,
                            onDelete: {
                                onDelete(category)
                            },
                            onEdit: {
                                onEdit(category)
                            },
                            onSave: {
                                onSave()
                            },
                            onCancel: {
                                onCancel()
                            },
                            onTransfer: {
                                onTransfer()
                            },
                            onMove: {
                                onMove(category)
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
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

// MARK: - Category Row View
struct CategoryRowView: View {
    let category: Category
    let index: Int
    let isEditing: Bool
    @Binding var editingText: String
    @Binding var editingGoalAmount: String
    @Binding var editingMonthlyBillAmount: String
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void
    let onTransfer: () -> Void
    let onMove: () -> Void
    
    @State private var isPressed = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Category icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.accentColor.opacity(0.2),
                                Color.accentColor.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                if isEditing {
                    Text(String(editingText.prefix(1)).uppercased())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text(String(category.name.prefix(1)).uppercased())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Category name or editing field
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextField("Category name", text: $editingText)
                        .textFieldStyle(InlineTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            onSave()
                        }
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                    HStack(spacing: 8) {
                        TextField("Goal (optional)", text: $editingGoalAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(InlineTextFieldStyle())
                        TextField("Monthly Bill (optional)", text: $editingMonthlyBillAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(InlineTextFieldStyle())
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Budget information
                        VStack(alignment: .leading, spacing: 2) {
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
                            if let goal = category.goalAmount {
                                Text("Goal: ₺\(String(format: "%.0f", goal))")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            if let bill = category.monthlyBillAmount {
                                Text("Monthly Bill: ₺\(String(format: "%.0f", bill))")
                                    .font(.caption2)
                                    .foregroundColor(.purple)
                            }
                            // Progress bar
                            ProgressView(value: category.assignedBudget > 0 ? (category.assignedBudget - category.remainingBalance) / category.assignedBudget : 0)
                                .progressViewStyle(LinearProgressViewStyle(tint: category.remainingBalance > 0 ? .green : .red))
                                .scaleEffect(y: 0.5)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            
            Spacer()
            
            // Action buttons
            if isEditing {
                HStack(spacing: 8) {
                    Button(action: onSave) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(editingText.isEmpty ? .gray : .green)
                    }
                    .disabled(editingText.isEmpty)
                    
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                HStack(spacing: 8) {
                    Button(action: onMove) {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onTransfer) {
                        Image(systemName: "arrow.left.arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.purple.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(category.remainingBalance <= 0)
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .transition(.scale.combined(with: .opacity))
            }
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
        .onTapGesture {
            if !isEditing {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
            }
        }
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Inline Text Field Style
struct InlineTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.accentColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Budget Summary Card Component
struct BudgetSummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Spacer()
            }
            
            Text("₺\(String(format: "%.0f", amount))")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.accentColor, .accentColor.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    CategoryView()
        .environmentObject(CategoryViewModel())
}
