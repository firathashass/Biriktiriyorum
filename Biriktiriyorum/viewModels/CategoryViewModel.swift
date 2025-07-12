//
//  CategoryViewModel.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import Foundation

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var customGroups: [String] = []
    
    // Predefined groups
    static let defaultGroups = ["Essentials", "Lifestyle", "Savings"]
    
    init() {
        loadCategories()
        loadCustomGroups()
        if categories.isEmpty {
            // Initialize with default grouped categories if none exist
            categories = [
                // Essentials
                Category(name: "Rent", assignedBudget: 3000, remainingBalance: 3000, group: "Essentials"),
                Category(name: "Groceries", assignedBudget: 1000, remainingBalance: 800, group: "Essentials"),
                Category(name: "Transportation", assignedBudget: 500, remainingBalance: 300, group: "Essentials"),
                
                // Lifestyle
                Category(name: "Dining", assignedBudget: 400, remainingBalance: 250, group: "Lifestyle"),
                Category(name: "Entertainment", assignedBudget: 300, remainingBalance: 200, group: "Lifestyle"),
                
                // Savings
                Category(name: "Emergency Fund", assignedBudget: 1000, remainingBalance: 1000, group: "Savings"),
                Category(name: "Travel", assignedBudget: 800, remainingBalance: 800, group: "Savings")
            ]
            saveCategories()
        }
    }
    
    func addCategory(name: String, group: String = "Other") {
        guard !name.isEmpty else { return }
        let new = Category(name: name, group: group)
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
        categories[index] = Category(name: newName, assignedBudget: category.assignedBudget, remainingBalance: category.remainingBalance, group: category.group)
        saveCategories()
    }
    
    func updateCategoryGroup(_ category: Category, newGroup: String) {
        guard let index = categories.firstIndex(of: category) else { return }
        categories[index] = Category(name: category.name, assignedBudget: category.assignedBudget, remainingBalance: category.remainingBalance, group: newGroup)
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
    
    // MARK: - Group Management
    
    func getGroupedCategories() -> [String: [Category]] {
        let grouped = Dictionary(grouping: categories) { $0.group }
        return grouped.sorted { $0.key < $1.key }.reduce(into: [:]) { result, element in
            result[element.key] = element.value.sorted { $0.name < $1.name }
        }
    }
    
    func getAllGroups() -> [String] {
        let groups = Set(categories.map { $0.group })
        return Array(groups).sorted()
    }
    
    func getCategoriesInGroup(_ group: String) -> [Category] {
        return categories.filter { $0.group == group }.sorted { $0.name < $1.name }
    }
    
    func getGroupBudget(_ group: String) -> (assigned: Double, remaining: Double, spent: Double) {
        let groupCategories = getCategoriesInGroup(group)
        let assigned = groupCategories.reduce(0) { $0 + $1.assignedBudget }
        let remaining = groupCategories.reduce(0) { $0 + $1.remainingBalance }
        let spent = assigned - remaining
        return (assigned, remaining, spent)
    }
    
    // MARK: - Custom Group Management
    
    func addCustomGroup(_ groupName: String) {
        guard !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !customGroups.contains(trimmedName) && !CategoryViewModel.defaultGroups.contains(trimmedName) {
            customGroups.append(trimmedName)
            saveCustomGroups()
        }
    }
    
    func removeCustomGroup(_ groupName: String) {
        guard let index = customGroups.firstIndex(of: groupName) else { return }
        
        // Move all categories from this group to "Other"
        for category in categories where category.group == groupName {
            updateCategoryGroup(category, newGroup: "Other")
        }
        
        customGroups.remove(at: index)
        saveCustomGroups()
    }
    
    func editCustomGroup(_ oldName: String, newName: String) {
        guard let index = customGroups.firstIndex(of: oldName),
              !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmedNewName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Update all categories in this group
        for category in categories where category.group == oldName {
            updateCategoryGroup(category, newGroup: trimmedNewName)
        }
        
        customGroups[index] = trimmedNewName
        saveCustomGroups()
    }
    
    func getAllAvailableGroups() -> [String] {
        var allGroups = CategoryViewModel.defaultGroups
        allGroups.append(contentsOf: customGroups)
        allGroups.append("Other")
        return allGroups
    }
    
    func isDefaultGroup(_ groupName: String) -> Bool {
        return CategoryViewModel.defaultGroups.contains(groupName)
    }
    
    func isCustomGroup(_ groupName: String) -> Bool {
        return customGroups.contains(groupName)
    }
    
    func canDeleteGroup(_ groupName: String) -> Bool {
        return isCustomGroup(groupName) && getCategoriesInGroup(groupName).isEmpty
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
    
    private func saveCustomGroups() {
        if let encoded = try? JSONEncoder().encode(customGroups) {
            UserDefaults.standard.set(encoded, forKey: "SavedCustomGroups")
        }
    }
    
    private func loadCustomGroups() {
        if let data = UserDefaults.standard.data(forKey: "SavedCustomGroups"),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            customGroups = decoded
        }
    }
}
