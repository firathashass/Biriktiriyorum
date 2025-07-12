//
//  CategoryViewModel.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import Foundation

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = [
        Category(name: "Food"),
        Category(name: "Rent"),
        Category(name: "Transportation"),
        Category(name: "Entertainment"),
        Category(name: "Health"),
        Category(name: "Other")
    ]
    
    func addCategory(name: String) {
        guard !name.isEmpty else { return }
        let new = Category(name: name)
        if !categories.contains(new) {
            categories.append(new)
        }
    }
    
    func removeCategory(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
    }
    
    func updateCategory(_ category: Category, newName: String) {
        guard let index = categories.firstIndex(of: category) else { return }
        categories[index] = Category(name: newName)
    }
}
