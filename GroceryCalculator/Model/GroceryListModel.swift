//
//  GroceryListModel.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import Foundation
import Observation
import SwiftData

// MARK: - Grocery Item

@Model
final class GroceryItem {
    var name: String
    var unitPrice: Double
    var quantity: Int

    init(name: String, unitPrice: Double, quantity: Int) {
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
    }

    var total: Double { unitPrice * Double(quantity) }
}

// MARK: - Grocery List

@Model
final class GroceryList {
    var title: String
    var dateCreated: Date
    var dateModified: Date
    var budget: Double
    var isHistory: Bool
    var notesData: Data?
    @Relationship(deleteRule: .cascade) var items: [GroceryItem] = []

    init(
        title: String,
        dateCreated: Date = Date(),
        dateModified: Date = Date(),
        budget: Double,
        isHistory: Bool = false,
        notesData: Data? = nil
    ) {
        self.title = title
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.budget = budget
        self.isHistory = isHistory
        self.notesData = notesData
    }

    var amountSpent: Double { items.reduce(0) { $0 + $1.total } }
    var remaining: Double { budget - amountSpent }
}

// MARK: - Store

@Observable
final class ListsStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: List CRUD

    func addList(title: String, budget: Double) {
        let now = Date()
        let list = GroceryList(title: title, dateCreated: now, dateModified: now, budget: budget)
        modelContext.insert(list)
    }

    func deleteList(_ list: GroceryList) {
        modelContext.delete(list)
    }

    // MARK: Item CRUD

    func addItem(to list: GroceryList, name: String, unitPrice: Double, quantity: Int = 1) {
        let item = GroceryItem(name: name, unitPrice: unitPrice, quantity: quantity)
        modelContext.insert(item)
        list.items.append(item)
        list.dateModified = Date()
    }

    func updateQuantity(of item: GroceryItem, in list: GroceryList, quantity: Int) {
        item.quantity = quantity
        list.dateModified = Date()
    }

    func removeItems(from list: GroceryList, at offsets: IndexSet) {
        let toDelete = offsets.map { list.items[$0] }
        list.items.remove(atOffsets: offsets)
        toDelete.forEach { modelContext.delete($0) }
        list.dateModified = Date()
    }

    func clearItems(from list: GroceryList) {
        list.items.forEach { modelContext.delete($0) }
        list.items.removeAll()
        list.dateModified = Date()
    }

    // MARK: History

    func saveToHistory(_ list: GroceryList) {
        list.isHistory = true
        list.dateModified = Date()
    }

    func restoreToList(_ list: GroceryList) {
        list.isHistory = false
        list.dateModified = Date()
    }

    func clearHistory() {
        let descriptor = FetchDescriptor<GroceryList>(predicate: #Predicate { $0.isHistory })
        let historyLists = (try? modelContext.fetch(descriptor)) ?? []
        historyLists.forEach { modelContext.delete($0) }
    }

    // MARK: Metadata

    func updateNotes(for list: GroceryList, data: Data?) {
        list.notesData = data
        list.dateModified = Date()
    }

    func updateListMeta(_ list: GroceryList, title: String? = nil, budget: Double? = nil) {
        if let title { list.title = title }
        if let budget { list.budget = budget }
        list.dateModified = Date()
    }
}
