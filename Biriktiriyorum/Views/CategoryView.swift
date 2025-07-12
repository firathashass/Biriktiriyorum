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
    @State private var isAddingCategory = false
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: Category?
    @State private var editingCategory: Category?
    @State private var editingText = ""
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isEditingTextFieldFocused: Bool
    
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
                ToolbarItem(placement: .navigationBarTrailing) {
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
            
            Divider()
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Categories List
    private var categoriesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(categoryVM.categories.enumerated()), id: \.element.id) { index, category in
                    CategoryRowView(
                        category: category,
                        index: index,
                        isEditing: editingCategory?.id == category.id,
                        editingText: $editingText,
                        onDelete: {
                            categoryToDelete = category
                            showingDeleteAlert = true
                        },
                        onEdit: {
                            startEditing(category)
                        },
                        onSave: {
                            saveEdit()
                        },
                        onCancel: {
                            cancelEdit()
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
                        isTextFieldFocused = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helper Methods
    private func addCategory() {
        guard !newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        withAnimation(.spring()) {
            categoryVM.addCategory(name: newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines))
            newCategoryName = ""
            isAddingCategory = false
            isTextFieldFocused = false
        }
    }
    
    private func startEditing(_ category: Category) {
        editingCategory = category
        editingText = category.name
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isEditingTextFieldFocused = true
        }
    }
    
    private func saveEdit() {
        guard let category = editingCategory,
              !editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        withAnimation(.spring()) {
            categoryVM.updateCategory(category, newName: editingText.trimmingCharacters(in: .whitespacesAndNewlines))
            editingCategory = nil
            editingText = ""
            isEditingTextFieldFocused = false
        }
    }
    
    private func cancelEdit() {
        withAnimation(.spring()) {
            editingCategory = nil
            editingText = ""
            isEditingTextFieldFocused = false
        }
    }
}

// MARK: - Category Row View
struct CategoryRowView: View {
    let category: Category
    let index: Int
    let isEditing: Bool
    @Binding var editingText: String
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void
    
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
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Category \(index + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
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

#Preview {
    CategoryView()
        .environmentObject(CategoryViewModel())
}
