//
//  PlanViewModel.swift
//  Biriktiriyorum
//
//  Created by AI Assistant on 15.09.2025.
//

import Foundation

class PlanViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    @Published var activePlanId: String? {
        didSet { saveActivePlanId() }
    }

    private let plansKey = "SavedPlans"
    private let activePlanKey = "ActivePlanId"

    init() {
        loadPlans()
        loadActivePlanId()
        ensureDefaultPlan()
    }

    var activePlan: Plan? {
        get { plans.first(where: { $0.id == activePlanId }) }
    }

    func createPlan(named name: String) {
        let newPlan = Plan(name: name)
        plans.append(newPlan)
        savePlans()
        // Switch immediately to the new plan
        activePlanId = newPlan.id
    }

    func renamePlan(_ plan: Plan, to newName: String) {
        guard let index = plans.firstIndex(of: plan) else { return }
        plans[index].name = newName
        savePlans()
    }

    func switchToPlan(_ plan: Plan) {
        activePlanId = plan.id
    }

    func deletePlan(_ plan: Plan) {
        // Prevent deleting the last plan
        guard plans.count > 1 else { return }

        // If deleting the active plan, move active to the first remaining plan
        let deletingActive = (plan.id == activePlanId)

        plans.removeAll { $0.id == plan.id }
        savePlans()

        if deletingActive {
            activePlanId = plans.first?.id
        }

        // Also clear plan-scoped data keys
        clearDataForPlan(planId: plan.id)
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

    private func saveActivePlanId() {
        UserDefaults.standard.set(activePlanId, forKey: activePlanKey)
        NotificationCenter.default.post(name: .activePlanChanged, object: activePlanId)
    }

    private func loadActivePlanId() {
        activePlanId = UserDefaults.standard.string(forKey: activePlanKey)
    }

    private func ensureDefaultPlan() {
        if plans.isEmpty {
            let defaultPlan = Plan(name: "Default Plan")
            plans = [defaultPlan]
            activePlanId = defaultPlan.id
            savePlans()
        } else if activePlanId == nil {
            activePlanId = plans.first?.id
        }
    }

    private func clearDataForPlan(planId: String) {
        let keys = [
            scopedKey(base: "SavedTransactions", planId: planId),
            scopedKey(base: "SavedCategories", planId: planId),
            scopedKey(base: "SavedCustomGroups", planId: planId)
        ]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    func scopedKey(base: String, planId: String? = nil) -> String {
        let pid = planId ?? activePlanId ?? "default"
        return "\(base)_\(pid)"
    }
}

extension Notification.Name {
    static let activePlanChanged = Notification.Name("activePlanChanged")
}

