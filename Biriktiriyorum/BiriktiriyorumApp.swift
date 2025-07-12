//
//  BiriktiriyorumApp.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

@main
struct BiriktiriyorumApp: App {
    @StateObject var transactionVM = TransactionViewModel()
    @StateObject var categoryVM = CategoryViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(transactionVM)
                .environmentObject(categoryVM)
        }
    }
}
