//
//  CategoryViewModel.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import Foundation

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    
    init() {
        loadCategories()
        if categories.isEmpty {
            // Initialize with default categories if none exist
            categories = [
                Category(name: "Food", assignedBudget: 1000, remainingBalance: 800),
                Category(name: "Rent", assignedBudget: 3000, remainingBalance: 3000),
                Category(name: "Transportation", assignedBudget: 500, remainingBalance: 300),
                Category(name: "Entertainment", assignedBudget: 300, remainingBalance: 200),
                Category(name: "Health", assignedBudget: 400, remainingBalance: 400),
                Category(name: "Other", assignedBudget: 200, remainingBalance: 150)
            ]
            saveCategories()
        }
    }
    
    func addCategory(name: String) {
        guard !name.isEmpty else { return }
        let new = Category(name: name)
        if !categories.contains(new) {
            categories.append(new)
            saveCategories()
        }
    }
    
    func removeCategory(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
        saveCategories()
    }
    
    func updateCategory(_ category: Category, newName: String) {
        guard let index = categories.firstIndex(of: category) else { return }
        categories[index] = Category(name: newName, assignedBudget: category.assignedBudget, remainingBalance: category.remainingBalance)
        saveCategories()
    }
    
    func updateCategoryBudget(_ category: Category, assignedBudget: Double) {
        guard let index = categories.firstIndex(of: category) else { return }
        categories[index].assignedBudget = assignedBudget
        categories[index].remainingBalance = assignedBudget
        saveCategories()
    }
    
    func updateCategoryRemainingBalance(_ category: Category, remainingBalance: Double) {
        guard let index = categories.firstIndex(of: category) else { return }
        categories[index].remainingBalance = remainingBalance
        saveCategories()
    }
    
    func subtractFromCategoryBalance(_ categoryName: String, amount: Double) -> Bool {
        guard let index = categories.firstIndex(where: { $0.name == categoryName }) else { return false }
        
        if categories[index].remainingBalance >= amount {
            categories[index].remainingBalance -= amount
            saveCategories()
            return true
        }
        return false
    }
    
    func getCategoryByName(_ name: String) -> Category? {
        return categories.first { $0.name == name }
    }
    
    func transferMoney(from sourceCategory: Category, to destinationCategory: Category, amount: Double) -> Bool {
        guard let sourceIndex = categories.firstIndex(where: { $0.id == sourceCategory.id }),
              let destinationIndex = categories.firstIndex(where: { $0.id == destinationCategory.id }),
              sourceIndex != destinationIndex,
              amount > 0,
              categories[sourceIndex].remainingBalance >= amount else {
            return false
        }
        
        // Transfer the money
        categories[sourceIndex].remainingBalance -= amount
        categories[destinationIndex].remainingBalance += amount
        
        saveCategories()
        return true
    }
    
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "SavedCategories")
        }
    }
    
    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: "SavedCategories"),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            categories = decoded
        }
    }
}
