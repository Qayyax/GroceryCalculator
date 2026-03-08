//
//  ListsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import SwiftUI


//@State  var  listStore = ListsStore()
struct ListsView: View {
    @State private var isPresentingNewList = false
    @Environment(ListsStore.self) var listStore
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBg
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    Text("Search component goes here")
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    
                    // list of items goes here
                    // the View should handle tlhe class
//                    List(ListDemo) { list in
//                        GroceryListView(title: list.title, date: list.date)
//                    }
                    Spacer()
                }
            }
            .navigationTitle("Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingNewList = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.accent)
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingNewList) {
            NewList { title, budget in
                // Convert Double? from NewList to Decimal expected by ListsStore
                let decimalBudget = Decimal(budget ?? 0)
                listStore.addList(title: title, budget: decimalBudget)
            }
        }
    }
}

#Preview {
    ListsView()
        .environment(ListsStore())
}
