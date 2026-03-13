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
                .padding(.bottom, 24)
                
                // resume here
                // button to add new items to list, so that they can show up here
                if !groceryList.items.isEmpty {
                    List(groceryList.items) { item in
                       GroceryItemComponent(item: item)
                    }
                }
                
                Spacer()
            }
            .padding()
            // might put it here or as over lay
            // the two buttons
        }
        .navigationTitle(groceryList.title)
        // navigationActionButton
    }
}
#Preview {
    ListDetailsView(groceryList: GroceryList(id: UUID(), title: "Fish", budget: 200.34))
}
