//
//  MainTabView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var authViewModel: UserAuthViewModel
    @EnvironmentObject var planVM: PlanViewModel
    
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
            }
            .tabItem {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
        .onReceive(planVM.$currentPlanId) { id in
            categoryVM.setPlan(id)
            transactionVM.setPlan(id)
        }
    }
}

// New MoreView for the More tab
struct MoreView: View {
    @EnvironmentObject var authViewModel: UserAuthViewModel
    @EnvironmentObject var planVM: PlanViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel
    @State private var newPlanName: String = ""
    @State private var showingDeleteAlert: Bool = false
    @State private var planToDelete: Plan?
    @State private var showingResetAlert: Bool = false
    var body: some View {
        List {
            Section(header: Text("Plans")) {
                if let current = planVM.currentPlan {
                    HStack {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                        Text("Current: \(current.name)")
                    }
                }
                ForEach(planVM.plans) { plan in
                    HStack {
                        Text(plan.name)
                        Spacer()
                        if planVM.currentPlanId == plan.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        planVM.switchToPlan(plan)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            planToDelete = plan
                            showingDeleteAlert = true
                        } label: { Label("Delete", systemImage: "trash") }
                    }
                }
                HStack {
                    TextField("New plan name", text: $newPlanName)
                    Button("Add") {
                        planVM.createPlan(named: newPlanName)
                        newPlanName = ""
                    }
                    .disabled(newPlanName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                Button(role: .destructive) {
                    showingResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle")
                        Text("Planı Sıfırla")
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
        .alert("Delete Plan", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let p = planToDelete {
                    planVM.deletePlan(p)
                }
            }
        } message: {
            Text("This will remove the plan and its data from this device.")
        }
        .alert("Planı Sıfırla", isPresented: $showingResetAlert) {
            Button("Vazgeç", role: .cancel) { }
            Button("Sıfırla", role: .destructive) {
                categoryVM.resetCurrentPlan()
                transactionVM.resetCurrentPlan()
            }
        } message: {
            Text("Mevcut plandaki tüm kategoriler ve harcamalar silinecek. Bu işlem geri alınamaz.")
        }
    }
}
