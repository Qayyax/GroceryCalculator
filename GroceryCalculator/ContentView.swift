//
//  ContentView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import SwiftUI

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
                Text("Settings page")
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(ListsStore())
}

