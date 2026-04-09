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
    
    private func formattedAmount(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: number) ?? "$0.00"
    }
    
    private var currentTotal: Decimal {
        item.unitPrice * Decimal(item.quantity)
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
                StepperView(
                    value: item.quantity,
                    range: 1...1000,
                    onIncrement: {
                        let newValue = item.quantity + 1
                        if newValue <= 1000 {
                            onQuantityChange(newValue)
                        }
                    },
                    onDecrement: {
                        let newValue = item.quantity - 1
                        if newValue >= 1 {
                            onQuantityChange(newValue)
                        }
                    }
                )
                Spacer()
            }
        
        }
    }
}

#Preview {
    GroceryItemComponent(
        item: GroceryItem(
            name: "Apples",
            unitPrice: 2.99 as Decimal,
            quantity: 3
        ),
        onQuantityChange: { newQuantity in
            print("Quantity changed to: \(newQuantity)")
        }
    )
    .padding()
}
// MARK: - StepperView (Non-Binding Version)
private struct StepperView: View {
    let value: Int
    let range: ClosedRange<Int>
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                onDecrement()
            } label: {
                Text("-")
                    .bold()
                    .foregroundStyle(.itemAmountGray)
                    .frame(width: 40, height: 40)
            }
            .background {
                UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 0, topTrailingRadius: 0)
                    .stroke(.buttonStrokeGray, lineWidth: 0.5)
            }
            .disabled(value <= range.lowerBound)
            
            Text("\(value)")
                .foregroundStyle(.itemAmountGray)
                .frame(width: 60, height: 40)
                .background{
                    Rectangle()
                        .stroke(.buttonStrokeGray, lineWidth: 0.5)
                }

            Button {
                onIncrement()
            } label: {
                Text("+")
                    .bold()
                    .foregroundStyle(.itemAmountGray)
                    .frame(width: 40, height: 40)
            }
            .background {
                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 10, topTrailingRadius: 10)
                    .stroke(.buttonStrokeGray, lineWidth: 0.5)
            }
            .disabled(value >= range.upperBound)
        }
    }
}

