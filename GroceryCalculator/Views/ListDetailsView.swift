//
//  ListDetailsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-09.
//

import SwiftUI
import SwiftData

struct ListDetailsView: View {
    let groceryList: GroceryList

    @State private var showingAddItem = false
    @State private var showingNotes = false
    @State private var showingSetBudget = false
    @Environment(ListsStore.self) private var listStore
    @Environment(SettingsStore.self) private var settingsStore

    private var isHistoryItem: Bool {
        groceryList.isHistory
    }

    private var effectiveSpent: Double {
        groceryList.amountSpent * settingsStore.taxMultiplier
    }

    private var effectiveRemaining: Double {
        groceryList.budget - effectiveSpent
    }

    var body: some View {
        listContent
            .background(Color.primaryBg.ignoresSafeArea())
            .navigationTitle(groceryList.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if isHistoryItem {
                            Button {
                                listStore.restoreToList(groceryList)
                            } label: {
                                Label("Send to List", systemImage: "arrow.uturn.left.circle")
                            }
                        } else {
                            Button {
                                showingSetBudget = true
                            } label: {
                                Label("Set Budget", systemImage: "pencil")
                            }
                            Menu {
                                Section("This list will be saved as a reference and used to track your spending. It won't be editable after saving.") {
                                    Button("Save to History") {
                                        listStore.saveToHistory(groceryList)
                                    }
                                }
                            } label: {
                                Label("Save to History", systemImage: "clock.arrow.circlepath")
                            }
                            Divider()
                            Menu {
                                Section("This will remove all items from the list and can't be undone.") {
                                    Button("Clear List", role: .destructive) {
                                        listStore.clearItems(from: groceryList)
                                    }
                                }
                            } label: {
                                Label("Clear List", systemImage: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemComponent { name, unitPrice in
                    listStore.addItem(to: groceryList, name: name, unitPrice: unitPrice)
                }
            }
            .sheet(isPresented: $showingNotes) {
                NotesPerListView(list: groceryList)
            }
            .sheet(isPresented: $showingSetBudget) {
                SetBudgetComponent(list: groceryList)
                    .environment(listStore)
            }
            .overlay(alignment: .bottomTrailing) {
                floatingButtons
            }
    }

    private var listContent: some View {
        VStack(spacing: 0) {
            BudgetCard(
                budget: groceryList.budget,
                remaining: effectiveRemaining,
                spent: effectiveSpent
            )
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 16)

            if groceryList.items.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(groceryList.items) { item in
                        GroceryItemComponent(item: item) { newQuantity in
                            listStore.updateQuantity(of: item, in: groceryList, quantity: newQuantity)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        listStore.removeItems(from: groceryList, at: indexSet)
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
                showingNotes = true
            } label: {
                BtnOverlayComponent(imageName: "note.text")
            }
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GroceryList.self, GroceryItem.self, configurations: config)
    let list = GroceryList(title: "Fish", budget: 200.34)
    container.mainContext.insert(list)

    return ListDetailsView(groceryList: list)
        .modelContainer(container)
        .environment(ListsStore(modelContext: container.mainContext))
        .environment(SettingsStore())
}
