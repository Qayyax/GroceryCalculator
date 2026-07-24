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
        if #available(iOS 18.0, *) {
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
        } else {
            // Fallback for iOS < 18 using classic .tabItem API
            TabView {
                ListsView()
                    .tabItem {
                        Image(systemName: Constants.Tabs.listPageIcon)
                        Text(Constants.Tabs.listPageTitle)
                    }

                HistoryView()
                    .tabItem {
                        Image(systemName: Constants.Tabs.historyPageIcon)
                        Text(Constants.Tabs.historyPageTitle)
                    }

                SettingsView()
                    .tabItem {
                        Image(systemName: Constants.Tabs.settingsPageIcon)
                        Text(Constants.Tabs.settingsPageTitle)
                    }
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

