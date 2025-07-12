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
    @FocusState private var isTextFieldFocused: Bool
    
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
                    // Header with stats
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
                            if isAddingCategory {
                                isTextFieldFocused = true
                            }
                        }
                    }) {
                        Image(systemName: isAddingCategory ? "minus.circle.fill" : "plus.circle.fill")
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
                        withAnimation(.easeInOut(duration: 0.3)) {
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
                        .foregroundColor(.primary)
                    Text("Total Categories")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Category icon
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "folder.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
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
                ForEach(categoryVM.categories) { category in
                    CategoryRowView(category: category) {
                        categoryToDelete = category
                        showingDeleteAlert = true
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Add Category Section
    private var addCategorySection: some View {
        VStack(spacing: 0) {
            if isAddingCategory {
                VStack(spacing: 16) {
                    Divider()
                        .padding(.horizontal, 20)
                    
                    HStack(spacing: 12) {
                        TextField("Enter category name", text: $newCategoryName)
                            .textFieldStyle(CustomTextFieldStyle())
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                addCategory()
                            }
                        
                        Button(action: addCategory) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                        .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.bottom, 20)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isAddingCategory)
    }
    
    // MARK: - Helper Methods
    private func addCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            categoryVM.addCategory(name: trimmedName)
            newCategoryName = ""
            isAddingCategory = false
            isTextFieldFocused = false
        }
    }
}

// MARK: - Category Row View
struct CategoryRowView: View {
    let category: Category
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "folder")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
            
            // Category name
            Text(category.name)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.1))
                    )
            }
            .buttonStyle(PlainButtonStyle())
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

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .font(.body)
    }
}

// MARK: - Preview
#Preview {
    CategoryView()
        .environmentObject(CategoryViewModel())
}
