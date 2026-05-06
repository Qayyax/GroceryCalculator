//
//  HistoryView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-04-16.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @State private var searchQuery: String = ""
    @Environment(ListsStore.self) var listStore

    @Query(filter: #Predicate<GroceryList> { $0.isHistory == true },
           sort: \GroceryList.dateModified, order: .reverse)
    private var allHistory: [GroceryList]

    private var filteredHistory: [GroceryList] {
        if searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            return allHistory
        }
        return allHistory.filter {
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

                    if !filteredHistory.isEmpty {
                        List {
                            ForEach(filteredHistory) { list in
                                NavigationLink(destination: ListDetailsView(groceryList: list)) {
                                    GroceryListView(title: list.title, date: list.dateModified)
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            Text("No History Yet")
                                .font(.title2.bold())
                            Text("Lists you save to history will appear here")
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
            .navigationTitle("History")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GroceryList.self, GroceryItem.self, configurations: config)
    return HistoryView()
        .modelContainer(container)
        .environment(ListsStore(modelContext: container.mainContext))
        .environment(SettingsStore())
}
