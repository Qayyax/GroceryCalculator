//
//  SettingsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-05-05.
//

import SwiftUI
import SwiftData

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
                        .foregroundStyle(.itemAmountGray)
                        .bold()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.itemAmountGray)
                }
                .foregroundStyle(.black)
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
                        .foregroundStyle(.black)
                    Spacer()
                    Text(settingsStore.taxInclusive ? "Inclusive" : "Off")
                        .foregroundStyle(.itemAmountGray)
                        .bold()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.itemAmountGray)
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GroceryList.self, GroceryItem.self, configurations: config)
    SettingsView()
        .modelContainer(container)
        .environment(SettingsStore())
        .environment(ListsStore(modelContext: container.mainContext))
}
