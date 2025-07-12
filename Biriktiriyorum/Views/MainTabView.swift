//
//  MainTabView.swift
//  Biriktiriyorum
//
//  Created by Fırat Haşhaş on 12.07.2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            AddTransactionView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }

            CategoryView()
                .tabItem {
                    Label("Categories", systemImage: "folder.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            ReflectionView()
                .tabItem {
                    Label("Reflection", systemImage: "person.fill.questionmark")
                }
        }
    }
}
