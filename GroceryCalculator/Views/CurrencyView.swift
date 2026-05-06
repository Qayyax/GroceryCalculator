//
//  CurrencyView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-05-05.
//

import SwiftUI

struct CurrencyView: View {
    @Environment(SettingsStore.self) private var settingsStore
    @State private var showingAddCurrency = false
    @State private var newCurrencyCode = ""

    var body: some View {
        ZStack {
            Color.primaryBg
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                currencyCard
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                Spacer()
            }
        }
        .navigationTitle("Currency")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddCurrency = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.accent)
                }
            }
        }
        .alert("Add Currency", isPresented: $showingAddCurrency) {
            TextField("EUR, JPY, AUD...", text: $newCurrencyCode)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
            Button("Add") {
                addCurrency()
            }
            Button("Cancel", role: .cancel) {
                newCurrencyCode = ""
            }
        } message: {
            Text("Enter a currency code (e.g. EUR, JPY)")
        }
    }

    private var currencyCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(settingsStore.currencies.enumerated()), id: \.element) { index, currency in
                Button {
                    settingsStore.selectedCurrency = currency
                } label: {
                    HStack {
                        Text(currency)
                            .foregroundStyle(.primary)
                        Spacer()
                        if settingsStore.selectedCurrency == currency {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.accent)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                if index < settingsStore.currencies.count - 1 {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
        }
    }

    private func addCurrency() {
        let code = newCurrencyCode
            .trimmingCharacters(in: .whitespaces)
            .uppercased()
        guard !code.isEmpty, !settingsStore.currencies.contains(code) else {
            newCurrencyCode = ""
            return
        }
        settingsStore.currencies.append(code)
        settingsStore.selectedCurrency = code
        newCurrencyCode = ""
    }
}

#Preview {
    NavigationStack {
        CurrencyView()
            .environment(SettingsStore())
    }
}
