//
//  ContentView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    var body: some View {
        TabView {
            Tab(Constants.Tabs.listPageTitle, systemImage: Constants.Tabs.listPageIcon) {
                ListsView()
            }
            Tab(Constants.Tabs.historyPageTitle, systemImage: Constants.Tabs.historyPageIcon) {
                HistoryView()
            }
            Tab(Constants.Tabs.settingsPageTitle, systemImage: Constants.Tabs.settingsPageIcon) {
                SettingsView()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GroceryList.self, GroceryItem.self, configurations: config)
    ContentView()
        .modelContainer(container)
        .environment(ListsStore(modelContext: container.mainContext))
        .environment(SettingsStore())
}

