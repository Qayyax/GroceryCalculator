//
//  SettingsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-05-05.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var settingsStore
    @Environment(ListsStore.self) private var listStore
    @State private var showingClearHistoryAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBg
                    .ignoresSafeArea()

                VStack(alignment: .leading) {
                    settingsCard
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    Spacer()
                }
            }
            .navigationTitle("Settings")
            .alert("Clear History", isPresented: $showingClearHistoryAlert) {
                Button("Clear", role: .destructive) {
                    listStore.clearHistory()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all saved history. This can't be undone.")
            }
        }
    }

    private var settingsCard: some View {
        VStack(spacing: 0) {
            NavigationLink {
                CurrencyView()
            } label: {
                HStack {
                    Text("Currency")
                    Spacer()
                    Text(settingsStore.selectedCurrency)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }

            Divider()
                .padding(.leading, 16)

            NavigationLink {
                TaxView()
            } label: {
                HStack {
                    Text("Tax")
                    Spacer()
                    Text(settingsStore.taxInclusive ? "Inclusive" : "Off")
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }

            Divider()
                .padding(.leading, 16)

            Button(role: .destructive) {
                showingClearHistoryAlert = true
            } label: {
                HStack {
                    Text("Clear History")
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
        }
    }
}

#Preview {
    SettingsView()
        .environment(SettingsStore())
        .environment(ListsStore())
}
