//
//  AddItemComponent.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-12.
//

import SwiftUI

struct AddItemComponent: View {
    let onAddItem: (String, Double) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var priceText: String = ""

    private var priceValue: Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let cleaned = priceText.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")

        if cleaned.isEmpty { return nil }

        if let number = formatter.number(from: cleaned) {
            return number.doubleValue
        }
        return nil
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        (priceValue ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBg
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Product Name")

                    TextField("Cereal, Bacon, Eggs...", text: $name)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        }

                    Text("Price")

                    TextField("0.00", text: $priceText)
                        .keyboardType(.decimalPad)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        }

                    HStack(alignment: .center) {
                        Button {
                            addItem()
                        } label: {
                            Text("Add Item")
                                .foregroundStyle(isFormValid ? Color.white : Color.itemAmountGray)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isFormValid ? Color.budgetBlue : Color.buttonStrokeGray)
                                }
                        }
                        .disabled(!isFormValid)
                    }
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add item")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }

    private func addItem() {
        guard let price = priceValue else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        onAddItem(trimmedName, price)
        dismiss()
    }
}

#Preview {
    AddItemComponent { name, price in
        print("Added: \(name) - \(price)")
    }
}
