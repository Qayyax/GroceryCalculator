//
//  GroceryListModel.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import Foundation
import Observation
import SwiftUI

// MARK: - Grocery Item
public struct GroceryItem: Identifiable, Hashable, Codable {
    public let id: UUID
    public var name: String
    public var unitPrice: Decimal
    public var quantity: Int
    public init(id: UUID = UUID(), name: String, unitPrice: Decimal, quantity: Int) {
        self.id = id
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
    }

    public var total: Decimal { unitPrice * Decimal(quantity) }
}

// MARK: - Grocery List
public struct GroceryList: Identifiable, Hashable, Codable {
    public let id: UUID
    public var title: String
    public var dateCreated: Date
    public var dateModified: Date
    public var budget: Decimal
    public var items: [GroceryItem]
    public var notesData: Data?

    public init(
        id: UUID = UUID(),
        title: String,
        dateCreated: Date = Date(),
        dateModified: Date = Date(),
        budget: Decimal,
        items: [GroceryItem] = [],
        notesData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.budget = budget
        self.items = items
        self.notesData = notesData
    }

    // Derived value to avoid drift; compute from items
    public var amountSpent: Decimal { items.reduce(0) { $0 + $1.total } }
    public var remaining: Decimal { budget - amountSpent }
}

// MARK: - Observable Store for Lists
@Observable
public final class ListsStore {
    public var lists: [GroceryList]

    public init(lists: [GroceryList] = []) {
        self.lists = lists
    }

    // CRUD Operations
    @MainActor
    public func addList(title: String, budget: Decimal) {
        let now = Date()
        let new = GroceryList(title: title, dateCreated: now, dateModified: now, budget: budget, items: [])
        lists.append(new)
    }

    @MainActor
    public func deleteLists(at offsets: IndexSet) {
        lists.remove(atOffsets: offsets)
    }

    @MainActor
    public func addItem(to listID: GroceryList.ID, name: String, unitPrice: Decimal, quantity: Int) {
        guard let idx = lists.firstIndex(where: { $0.id == listID }) else { return }
        lists[idx].items.append(GroceryItem(name: name, unitPrice: unitPrice, quantity: quantity))
        lists[idx].dateModified = Date()
    }

    @MainActor
    public func updateItem(in listID: GroceryList.ID, itemID: GroceryItem.ID, name: String? = nil, unitPrice: Decimal? = nil, quantity: Int? = nil) {
        guard let lIdx = lists.firstIndex(where: { $0.id == listID }) else { return }
        guard let iIdx = lists[lIdx].items.firstIndex(where: { $0.id == itemID }) else { return }
        if let name { lists[lIdx].items[iIdx].name = name }
        if let unitPrice { lists[lIdx].items[iIdx].unitPrice = unitPrice }
        if let quantity { lists[lIdx].items[iIdx].quantity = quantity }
        lists[lIdx].dateModified = Date()
    }

    @MainActor
    public func removeItems(from listID: GroceryList.ID, at offsets: IndexSet) {
        guard let idx = lists.firstIndex(where: { $0.id == listID }) else { return }
        lists[idx].items.remove(atOffsets: offsets)
        lists[idx].dateModified = Date()
    }

    @MainActor
    public func clearItems(from listID: GroceryList.ID) {
        guard let idx = lists.firstIndex(where: { $0.id == listID }) else { return }
        lists[idx].items.removeAll()
        lists[idx].dateModified = Date()
    }

    @MainActor
    public func updateNotes(for listID: GroceryList.ID, data: Data?) {
        guard let idx = lists.firstIndex(where: { $0.id == listID }) else { return }
        lists[idx].notesData = data
        lists[idx].dateModified = Date()
    }

    @MainActor
    public func updateListMeta(_ listID: GroceryList.ID, title: String? = nil, budget: Decimal? = nil) {
        guard let idx = lists.firstIndex(where: { $0.id == listID }) else { return }
        if let title { lists[idx].title = title }
        if let budget { lists[idx].budget = budget }
        lists[idx].dateModified = Date()
    }
}

