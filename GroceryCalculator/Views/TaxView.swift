//
//  TaxView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-05-05.
//

import SwiftUI

struct TaxView: View {
    @Environment(SettingsStore.self) private var settingsStore
    @State private var taxPercentageText: String = ""
    @FocusState private var isPercentageFocused: Bool

    var body: some View {
        ZStack {
            Color.primaryBg
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                taxCard
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                Spacer()
            }
        }
        .navigationTitle("Tax")
        .onAppear {
            loadPercentageText()
        }
    }

    private var taxCard: some View {
        VStack(spacing: 0) {
            // Tax inclusive toggle
            HStack {
                Text("Tax Inclusive")
                Spacer()
                Toggle("", isOn: Bindable(settingsStore).taxInclusive)
                    .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            Divider()
                .padding(.leading, 16)

            // Tax percentage row
            HStack {
                Text("Tax Percentage")
                    .foregroundStyle(settingsStore.taxInclusive ? .primary : .secondary)
                Spacer()
                if settingsStore.taxInclusive {
                    HStack(spacing: 2) {
                        TextField("0", text: $taxPercentageText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($isPercentageFocused)
                            .frame(width: 50)
                            .onChange(of: taxPercentageText) { _, newValue in
                                if let value = Double(newValue) {
                                    settingsStore.taxPercentage = value
                                } else if newValue.isEmpty {
                                    settingsStore.taxPercentage = 0
                                }
                            }
                        Text("%")
                    }
                } else {
                    Text("%")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
        }
    }

    private func loadPercentageText() {
        guard settingsStore.taxPercentage > 0 else { return }
        let value = settingsStore.taxPercentage
        taxPercentageText = value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(value)
    }
}

#Preview("Tax Off") {
    NavigationStack {
        TaxView()
            .environment(SettingsStore())
    }
}
