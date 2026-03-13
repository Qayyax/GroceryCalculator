//
//  AddItemComponent.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-12.
//

import SwiftUI

struct AddItemComponent: View {
    let onAddItem: (GroceryItem) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var price: Decimal = 0
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        price > 0
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
                    
                    TextField("0.00", value: $price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
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
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let newItem = GroceryItem(name: trimmedName, unitPrice: price, quantity: 1)
        onAddItem(newItem)
        dismiss()
    }
}

#Preview {
    AddItemComponent { item in
        print("Added item: \(item.name) - \(item.unitPrice)")
    }
}
