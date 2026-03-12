//
//  AddItemComponent.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-12.
//

import SwiftUI

struct AddItemComponent: View {
    let listID: GroceryList.ID
    let store: ListsStore
    
    @State private var name: String = ""
    @State private var priceText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !priceText.trimmingCharacters(in: .whitespaces).isEmpty &&
        priceValue != nil
    }
    
    private var priceValue: Decimal? {
        // Remove dollar sign and other formatting if present
        let cleaned = priceText.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        return Decimal(string: cleaned)
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
                    
                    TextField("$0.00", text: $priceText)
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
                                        .fill(isFormValid ? Color.budgetBlue : Color.gray)
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
            .navigationBarTitleDisplayMode(.inline)
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
        store.addItem(to: listID, name: trimmedName, unitPrice: price, quantity: 1)
        dismiss()
    }
}

#Preview {
    @Previewable @State var store = ListsStore(lists: [
        GroceryList(title: "Weekly Groceries", budget: 150.00)
    ])
    
    return AddItemComponent(listID: store.lists[0].id, store: store)
}
