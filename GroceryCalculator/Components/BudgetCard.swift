//
//  BudgetCard.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-09.
//

import SwiftUI

struct BudgetCard: View {
    let budget: Decimal
    let remaining: Decimal
    let spent: Decimal
    @State private var isPresented: Bool
    
    init(budget: Decimal, remaining: Decimal, spent: Decimal, isPresented: Bool = true) {
        self.budget = budget
        self.remaining = remaining
        self.spent = spent
        _isPresented = State(initialValue: isPresented)
    }
    
    private func formattedAmount(_ value: Decimal) -> String {
        if !isPresented { return "••••" }
        let number = NSDecimalNumber(decimal: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        // Uses current locale currency symbol
        return formatter.string(from: number) ?? "$0.00"
    }
    
    var body: some View {
        VStack {
            // Top section
            HStack {
                VStack(alignment: .leading) {
                    Text("Budget")
                    Text(formattedAmount(budget))
                        .font(.title2.bold())
                        .foregroundStyle(.budgetBlue)
                }
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Remaining Funds")
                    Text(formattedAmount(remaining))
                        .font(.title2.bold())
                        .foregroundStyle(.remainingGreen)
                }
            }
            .padding(.bottom, 45)
            // Bottom section
            HStack {
                Spacer()
                HStack {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Image(systemName: isPresented ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.eyeGray)
                    }
                    Text(formattedAmount(spent))
                        .font(.system(size: 48).bold())
                }
            }
            
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
        }
    }
}

#Preview {
    ZStack {
        Color.primaryBg
        BudgetCard(budget: 200, remaining: 150, spent: 50, isPresented: true)
            .padding()
    }
}
