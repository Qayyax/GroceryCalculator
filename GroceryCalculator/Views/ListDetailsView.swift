//
//  ListDetailsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-09.
//

import SwiftUI

struct ListDetailsView: View {
    let groceryList: GroceryList

    var body: some View {
        ZStack {
            Color.primaryBg.ignoresSafeArea()
            VStack {
                BudgetCard(
                    budget: groceryList.budget,
                    remaining: groceryList.remaining,
                    spent: groceryList.amountSpent,
                )
                Spacer()
            }
            .padding()
        }
        .navigationTitle(groceryList.title)
    }
}
#Preview {
    ListDetailsView(groceryList: GroceryList(id: UUID(), title: "Fish", budget: 200.34))
}
