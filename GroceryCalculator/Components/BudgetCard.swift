//
//  BudgetCard.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-09.
//

import SwiftUI

struct BudgetCard: View {
    @State var budget: Decimal = 0.00
    @State var isPresented: Bool = false
    var body: some View {
        VStack {
            // Top section
            HStack {
                VStack(alignment: .leading) {
                    Text("Budget")
                    Text("$200.00")
                        .font(.title2.bold())
                        .foregroundStyle(.budgetBlue)
                }
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Remaining Funds")
                    Text("$200.00")
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
                    Text("$000")
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
        BudgetCard()
            .padding()
    }
}
