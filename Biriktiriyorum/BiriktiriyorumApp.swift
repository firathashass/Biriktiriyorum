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

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(transactionVM) // Share the ViewModel
        }
    }
}
