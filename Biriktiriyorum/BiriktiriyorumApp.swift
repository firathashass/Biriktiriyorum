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
    @StateObject var transactionVM = TransactionViewModel()
    @StateObject var categoryVM = CategoryViewModel()
    @StateObject var authViewModel = UserAuthViewModel()
    @State private var showSignUp: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(transactionVM)
                    .environmentObject(categoryVM)
                    .environmentObject(authViewModel)
            } else {
                SignInView(authViewModel: authViewModel)
            }
        }
    }
}
