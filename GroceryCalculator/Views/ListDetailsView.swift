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
        Group {
            if let list = groceryList {
                listContent(for: list)
            } else {
                ContentUnavailableView(
                    "List Not Found",
                    systemImage: "list.bullet.clipboard",
                    description: Text("This grocery list may have been deleted.")
                )
            }
        }
        .background(Color.primaryBg.ignoresSafeArea())
        .navigationTitle(groceryList?.title ?? "Grocery List")
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
        .overlay(alignment: .bottomTrailing) {
            floatingButtons
        }
    }
    
    @ViewBuilder
    private func listContent(for list: GroceryList) -> some View {
        VStack(spacing: 0) {
            BudgetCard(
                budget: list.budget,
                remaining: list.remaining,
                spent: list.amountSpent
            )
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 16)
            
            if list.items.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(list.items) { item in
                        GroceryItemComponent(item: item) { newQuantity in
                            listStore.updateItem(
                                in: groceryListID,
                                itemID: item.id,
                                quantity: newQuantity
                            )
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        listStore.removeItems(from: groceryListID, at: indexSet)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No Items Yet")
                .font(.title2.bold())
            Text("Tap the + button to add your first item")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var floatingButtons: some View {
        VStack(spacing: 12) {
            Button {
                showingAddItem = true
            } label: {
                BtnOverlayComponent(imageName: "plus")
            }
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
}
#Preview {
    let store = ListsStore()
    let sampleList = GroceryList(id: UUID(), title: "Fish", budget: 200.34)
    store.lists.append(sampleList)
    
    return ListDetailsView(groceryListID: sampleList.id)
        .environment(store)
}
