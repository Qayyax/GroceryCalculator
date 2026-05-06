//
//  GroceryCalculatorApp.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import SwiftUI
import SwiftData

@main
struct GroceryCalculatorApp: App {
    private let container: ModelContainer
    @State private var listStore: ListsStore
    @State private var settingsStore = SettingsStore()

    init() {
        do {
            container = try ModelContainer(for: GroceryList.self, GroceryItem.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        _listStore = State(initialValue: ListsStore(modelContext: container.mainContext))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .environment(listStore)
                .environment(settingsStore)
                .preferredColorScheme(.light)
        }
    }
}
