//
//  ShoppingListRepository.swift
//  ShoppingListApp
//
//  Created by Md Mozammil on 16/02/26.
//

import Foundation
import SwiftData

protocol ShoppingListRepositoryDelegate {
    func fetchItems() async throws -> [ShoppingListItem]
    func addItem(name: String, category: ItemCategory) async throws -> ShoppingListItem
    func toggleCompletion(for item: ShoppingListItem) async throws
    func update(item: ShoppingListItem, name: String, category: ItemCategory) async throws
    func delete(item: ShoppingListItem) async throws
    func delete(items: [ShoppingListItem]) async throws
}

@MainActor
final class ShoppingListRepository: ShoppingListRepositoryDelegate {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchItems() async throws -> [ShoppingListItem] {
        var descriptor = FetchDescriptor<ShoppingListItem>()
        descriptor.sortBy = [
            SortDescriptor(\ShoppingListItem.categoryRawValue),
            SortDescriptor(\ShoppingListItem.name)
        ]
        return try modelContext.fetch(descriptor)
    }

    func addItem(name: String, category: ItemCategory) async throws -> ShoppingListItem {
        let newItem = ShoppingListItem(name: name, category: category)
        modelContext.insert(newItem)
        try modelContext.save()
        return newItem
    }

    func toggleCompletion(for item: ShoppingListItem) async throws {
        item.isCompleted.toggle()
        try modelContext.save()
    }

    func update(item: ShoppingListItem, name: String, category: ItemCategory) async throws {
        item.name = name
        item.category = category
        try modelContext.save()
    }

    func delete(item: ShoppingListItem) async throws {
        modelContext.delete(item)
        try modelContext.save()
    }

    func delete(items: [ShoppingListItem]) async throws {
        for item in items {
            modelContext.delete(item)
        }
        try modelContext.save()
    }
}
