//
//  HomeView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel
    @State private var showingTransferView = false
    
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
                        
                        // Budget Overview Section
                        budgetOverviewSection
                        
                        // Category Budgets Section
                        categoryBudgetsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Biriktiriyorum")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingTransferView = true
                    }) {
                        Image(systemName: "arrow.left.arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingTransferView) {
                TransferView()
                    .environmentObject(categoryVM)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Budget Overview")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Track your spending and stay within budget")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Budget Overview Section
    private var budgetOverviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.green)
                Text("Budget Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                // Total Assigned
                BudgetCard(
                    title: "Total Assigned",
                    amount: totalAssignedBudget,
                    color: .blue,
                    icon: "dollarsign.circle.fill"
                )
                
                // Total Remaining
                BudgetCard(
                    title: "Total Remaining",
                    amount: totalRemainingBudget,
                    color: totalRemainingBudget >= 0 ? .green : .red,
                    icon: "creditcard.fill"
                )
                
                // Total Spent
                BudgetCard(
                    title: "Total Spent",
                    amount: totalSpent,
                    color: .orange,
                    icon: "cart.fill"
                )
                
                // This Week
                BudgetCard(
                    title: "This Week",
                    amount: weeklySpent,
                    color: .purple,
                    icon: "calendar.circle.fill"
                )
            }
        }
    }
    
    // MARK: - Category Budgets Section
    private var categoryBudgetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.orange)
                Text("Category Budgets")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(categoryVM.categories) { category in
                    CategoryBudgetRow(category: category)
                }
            }
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
        return transactionVM.getTotalSpent()
    }
    
    private var weeklySpent: Double {
        return transactionVM.getWeeklyTotal()
    }
}

// MARK: - Budget Card Component
struct BudgetCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text("₺\(String(format: "%.0f", amount))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Category Budget Row Component
struct CategoryBudgetRow: View {
    let category: Category
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                HStack {
                    Text("Assigned: ₺\(String(format: "%.0f", category.assignedBudget))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("Spent: ₺\(String(format: "%.0f", category.assignedBudget - category.remainingBalance))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("₺\(String(format: "%.0f", category.remainingBalance))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(category.remainingBalance > 0 ? .green : .red)
                
                Text("Remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
    HomeView()
        .environmentObject(CategoryViewModel())
        .environmentObject(TransactionViewModel(accountViewModel: AccountViewModel()))
}
