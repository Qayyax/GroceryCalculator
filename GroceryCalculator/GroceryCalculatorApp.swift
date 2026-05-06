//
//  GroceryCalculatorApp.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import SwiftUI

@main
struct GroceryCalculatorApp: App {
    @State private var listStore = ListsStore()
    @State private var settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(listStore)
                .environment(settingsStore)
                .preferredColorScheme(.light) // Force light mode at app level
        }
    }
}
