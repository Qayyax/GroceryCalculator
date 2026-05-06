//
//  ListsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import SwiftUI
import SwiftData

struct ListsView: View {
    @State private var isPresentingNewList = false
    @State private var searchQuery: String = ""
    @Environment(ListsStore.self) var listStore

    @Query(filter: #Predicate<GroceryList> { $0.isHistory == false },
           sort: \GroceryList.dateModified, order: .reverse)
    private var allLists: [GroceryList]

    private var filteredLists: [GroceryList] {
        if searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            return allLists
        }
        return allLists.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery)
        }
    }

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

                    if !filteredLists.isEmpty {
                        List {
                            ForEach(filteredLists) { list in
                                NavigationLink(destination: ListDetailsView(groceryList: list)) {
                                    GroceryListView(title: list.title, date: list.dateModified)
                                }
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { listStore.archiveList(filteredLists[$0]) }
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
                        .frame(maxWidth: .infinity)
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
                listStore.addList(title: title, budget: budget)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GroceryList.self, GroceryItem.self, configurations: config)
    return ListsView()
        .modelContainer(container)
        .environment(ListsStore(modelContext: container.mainContext))
        .environment(SettingsStore())
}
