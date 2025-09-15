//
//  BiriktiriyorumApp.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication,

                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    FirebaseApp.configure()

    return true

  }

}

@main
struct BiriktiriyorumApp: App {
    @StateObject var planVM = PlanViewModel()
    @StateObject var transactionVM = TransactionViewModel(planId: nil)
    @StateObject var categoryVM = CategoryViewModel(planId: nil)
    @StateObject var authViewModel = UserAuthViewModel()
    @State private var showSignUp: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(planVM)
                    .environmentObject(transactionVM)
                    .environmentObject(categoryVM)
                    .environmentObject(authViewModel)
                    .onReceive(planVM.$currentPlanId) { id in
                        transactionVM.setPlan(id)
                        categoryVM.setPlan(id)
                    }
            } else {
                SignInView(authViewModel: authViewModel)
            }
        }
    }
}
