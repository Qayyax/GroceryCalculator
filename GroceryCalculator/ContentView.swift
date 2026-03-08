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
            Tab("Lists", systemImage: "list.bullet") {
                Text("List page")
            }
            Tab("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90") {
                Text("History page")
            }
            Tab("Settings", systemImage: "gearshape") {
                Text("Settings page")
            }
        }
    }
}

#Preview {
    ContentView()
}
