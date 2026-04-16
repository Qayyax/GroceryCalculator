//
//  ListsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import SwiftUI


struct ListsView: View {
    @State private var isPresentingNewList = false
    @State private var searchQuery: String = ""
    @Environment(ListsStore.self) var listStore
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBg
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search", text: $searchQuery)
                    }
                        .padding(7)
                        .foregroundStyle(.itemAmountGray)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.buttonStrokeGray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)

                    // list of items goes here
                    if !listStore.lists.isEmpty {
                        List {
                            ForEach(listStore.lists) { list in
                                NavigationLink(destination: ListDetailsView(groceryListID: list.id)) {
                                    GroceryListView(title: list.title, date: list.dateModified)
                                }
                            }
                            .onDelete { indexSet in
                                listStore.deleteLists(at: indexSet)
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            Text("No Lists Yet")
                                .font(.title2.bold())
                            Text("Tap the + button to create your first grocery list")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            Spacer()
                        }
                    }
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
                listStore.addList(title: title, budget: Decimal(budget))
            }
        }
    }
}

#Preview {
    ListsView()
        .environment(ListsStore())
}
