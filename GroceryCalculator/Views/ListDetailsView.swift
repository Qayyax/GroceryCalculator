//
//  ListDetailsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-09.
//

import SwiftUI

struct ListDetailsView: View {
    let groceryListID: GroceryList.ID
    
    @State private var showingAddItem = false
    @Environment(ListsStore.self) private var listStore
    
    // Computed property to get the current list from the store
    private var groceryList: GroceryList? {
        listStore.lists.first(where: { $0.id == groceryListID })
    }

    var body: some View {
        ZStack {
            Color.primaryBg.ignoresSafeArea()
            VStack {
                if let list = groceryList {
                    BudgetCard(
                        budget: list.budget,
                        remaining: list.remaining,
                        spent: list.amountSpent,
                    )
                    .padding(.bottom, 24)
                    
                    if !list.items.isEmpty {
                        List(list.items) { item in
                           GroceryItemComponent(item: item)
                        }
                    }
                } else {
                    Text("List not found")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            // might put it here or as over lay
            // the two buttons
            GeometryReader{ geometry in
                VStack(spacing: 10) {
                    Button {
                        
                    } label: {
                        BtnOverlayComponent(imageName: "list.bullet.clipboard")
                    }
                    Button {
                        showingAddItem = true
                    } label: {
                        BtnOverlayComponent(imageName: "plus")
                    }
                }
                .position(x: geometry.size.width + 155, y: geometry.size.height + 250)

            }
            .frame(width: 0, height: 0)
        }
        .navigationTitle(groceryList?.title ?? "List")
        .sheet(isPresented: $showingAddItem) {
            AddItemComponent { item in
                listStore.addItem(
                    to: groceryListID,
                    name: item.name,
                    unitPrice: item.unitPrice,
                    quantity: item.quantity
                )
            }
        }
        // navigationActionButton
    }
}
#Preview {
    let store = ListsStore()
    let sampleList = GroceryList(id: UUID(), title: "Fish", budget: 200.34)
    store.lists.append(sampleList)
    
    return ListDetailsView(groceryListID: sampleList.id)
        .environment(store)
}
