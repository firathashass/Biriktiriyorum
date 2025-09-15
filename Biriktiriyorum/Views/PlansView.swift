//
//  PlansView.swift
//  Biriktiriyorum
//
//  Created by AI Assistant on 15.09.2025.
//

import SwiftUI

struct PlansView: View {
    @EnvironmentObject var planVM: PlanViewModel
    @State private var newPlanName: String = ""
    @State private var showDeleteAlert: Plan?
    
    var body: some View {
        List {
            Section(header: Text("Active Plan")) {
                if let active = planVM.activePlan {
                    HStack {
                        Text(active.name)
                        Spacer()
                        Text("Active")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Section(header: Text("Create New Plan"), footer: Text("Yeni plan oluşturduğunda bütün kategoriler ve geçmiş sıfırdan başlar. Eski planlara istediğin zaman geri dönebilirsin.")) {
                HStack {
                    TextField("Plan adı", text: $newPlanName)
                    Button("Oluştur") {
                        let name = newPlanName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        planVM.createPlan(named: name)
                        newPlanName = ""
                    }
                }
            }
            
            Section(header: Text("Tüm Planlar")) {
                ForEach(planVM.plans, id: \.id) { plan in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(plan.name)
                            Text(plan.createdAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if planVM.activePlanId == plan.id {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        } else {
                            Button("Seç") {
                                planVM.switchToPlan(plan)
                            }
                        }
                        Button(role: .destructive) {
                            showDeleteAlert = plan
                        } label: {
                            Image(systemName: "trash")
                        }
                        .disabled(planVM.plans.count <= 1)
                    }
                }
            }
        }
        .navigationTitle("Plans")
        .alert(item: $showDeleteAlert) { plan in
            Alert(
                title: Text("Planı Sil"),
                message: Text("\"\(plan.name)\" planını ve tüm verilerini silmek istediğine emin misin?"),
                primaryButton: .destructive(Text("Sil")) {
                    planVM.deletePlan(plan)
                },
                secondaryButton: .cancel()
            )
        }
    }
}

