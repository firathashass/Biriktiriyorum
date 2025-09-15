//
//  PlanViewModel.swift
//  Biriktiriyorum
//
//  Created by Assistant on 15.09.2025.
//

import Foundation

class PlanViewModel: ObservableObject {
    @Published private(set) var plans: [Plan] = []
    @Published var currentPlanId: UUID? {
        didSet { saveCurrentPlanId() }
    }
    
    private let plansKey = "SavedPlans"
    private let currentPlanKey = "CurrentPlanId"
    
    init() {
        loadPlans()
        loadCurrentPlanId()
        ensureDefaultPlan()
    }
    
    var currentPlan: Plan? {
        guard let id = currentPlanId else { return nil }
        return plans.first(where: { $0.id == id })
    }
    
    func createPlan(named name: String) -> Plan {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let plan = Plan(name: trimmed.isEmpty ? defaultPlanName(for: plans.count + 1) : trimmed)
        plans.append(plan)
        savePlans()
        currentPlanId = plan.id
        return plan
    }
    
    func renamePlan(_ plan: Plan, to newName: String) {
        guard let idx = plans.firstIndex(of: plan) else { return }
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        plans[idx].name = trimmed.isEmpty ? plans[idx].name : trimmed
        savePlans()
    }
    
    func deletePlan(_ plan: Plan) {
        guard let idx = plans.firstIndex(of: plan) else { return }
        plans.remove(at: idx)
        savePlans()
        if currentPlanId == plan.id {
            currentPlanId = plans.first?.id
        }
    }
    
    func switchToPlan(_ plan: Plan) {
        currentPlanId = plan.id
    }
    
    private func ensureDefaultPlan() {
        if plans.isEmpty {
            let first = Plan(name: defaultPlanName(for: 1))
            plans = [first]
            currentPlanId = first.id
            savePlans()
        } else if currentPlanId == nil {
            currentPlanId = plans.first?.id
        }
    }
    
    private func defaultPlanName(for index: Int) -> String {
        return "Plan \(index)"
    }
    
    // MARK: - Persistence
    private func savePlans() {
        if let encoded = try? JSONEncoder().encode(plans) {
            UserDefaults.standard.set(encoded, forKey: plansKey)
        }
    }
    
    private func loadPlans() {
        if let data = UserDefaults.standard.data(forKey: plansKey),
           let decoded = try? JSONDecoder().decode([Plan].self, from: data) {
            plans = decoded
        }
    }
    
    private func saveCurrentPlanId() {
        if let id = currentPlanId {
            UserDefaults.standard.set(id.uuidString, forKey: currentPlanKey)
        } else {
            UserDefaults.standard.removeObject(forKey: currentPlanKey)
        }
    }
    
    private func loadCurrentPlanId() {
        if let idStr = UserDefaults.standard.string(forKey: currentPlanKey),
           let id = UUID(uuidString: idStr) {
            currentPlanId = id
        } else {
            currentPlanId = nil
        }
    }
}

