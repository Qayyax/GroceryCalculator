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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(listStore)
        }
    }
}
