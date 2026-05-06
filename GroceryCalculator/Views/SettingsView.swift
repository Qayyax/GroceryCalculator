//
//  SettingsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-05-05.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBg
                    .ignoresSafeArea()
                
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
