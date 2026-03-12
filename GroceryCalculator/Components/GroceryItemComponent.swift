//
//  GroceryItemComponent.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-09.
//

import SwiftUI

struct GroceryItemComponent: View {
    let item: GroceryItem
    let onQuantityChange: (Int) -> Void
    
    @State private var itemCount: Int
    
    init(item: GroceryItem, onQuantityChange: @escaping (Int) -> Void = { _ in }) {
        self.item = item
        self.onQuantityChange = onQuantityChange
        _itemCount = State(initialValue: item.quantity)
    }
    
    private func formattedAmount(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: number) ?? "$0.00"
    }
    
    private var currentTotal: Decimal {
        item.unitPrice * Decimal(itemCount)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.title2.weight(.semibold))
                    Text(formattedAmount(item.unitPrice))
                        .foregroundStyle(.itemAmountGray)
                }
                Spacer()
                Text(formattedAmount(currentTotal))
                    .font(.title2.bold())
            }
            .padding(.bottom, 14)
            HStack {
                CustomStepper(value: $itemCount, range: 1...1000)
                    .onChange(of: itemCount) { _, newValue in
                        onQuantityChange(newValue)
                    }
                Spacer()
            }
        
        }
    }
}

#Preview {
    GroceryItemComponent(
        item: GroceryItem(
            name: "Apples",
            unitPrice: 2.99,
            quantity: 3
        )
    )
    .padding()
}
