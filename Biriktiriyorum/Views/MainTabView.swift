//
//  MainTabView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var planVM = PlanViewModel()
    @StateObject private var categoryVM: CategoryViewModel
    @StateObject private var transactionVM: TransactionViewModel
    @EnvironmentObject var authViewModel: UserAuthViewModel
    
    init() {
        let plan = PlanViewModel()
        _planVM = StateObject(wrappedValue: plan)
        _categoryVM = StateObject(wrappedValue: CategoryViewModel(planViewModel: plan))
        _transactionVM = StateObject(wrappedValue: TransactionViewModel(planViewModel: plan))
    }

    var body: some View {
        TabView {
            NavigationView {
                HomeView()
                    .environmentObject(categoryVM)
                    .environmentObject(transactionVM)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            AddTransactionView()
                .environmentObject(categoryVM)
                .environmentObject(transactionVM)
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }

            CategoryView()
                .environmentObject(categoryVM)
                .tabItem {
                    Label("Categories", systemImage: "folder.fill")
                }

            AssignIncomeView()
                .environmentObject(categoryVM)
                .tabItem {
                    Label("Income", systemImage: "dollarsign.circle.fill")
                }

            HistoryView()
                .environmentObject(transactionVM)
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            ReflectionView()
                .environmentObject(transactionVM)
                .tabItem {
                    Label("Reflection", systemImage: "person.fill.questionmark")
                }

            NavigationView {
                MoreView()
                    .environmentObject(planVM)
            }
            .tabItem {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
        .tint(AppTheme.accent)
    }
}

// New MoreView for the More tab
struct MoreView: View {
    @EnvironmentObject var authViewModel: UserAuthViewModel
    @EnvironmentObject var planVM: PlanViewModel
    var body: some View {
        List {
            Section {
                NavigationLink(destination: PlansView().environmentObject(planVM)) {
                    HStack {
                        Image(systemName: "list.bullet.rectangle.portrait")
                        Text("Plans")
                    }
                }
            }
            Section {
                Button(role: .destructive) {
                    authViewModel.signOut()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                }
            }
        }
        .navigationTitle("More")
        .listStyle(InsetGroupedListStyle())
    }
}
