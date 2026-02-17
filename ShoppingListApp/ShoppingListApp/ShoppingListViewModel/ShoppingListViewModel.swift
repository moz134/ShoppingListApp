//
//  ShoppingListViewModel.swift
//  ShoppingListApp
//
//  Created by Md Mozammil on 16/02/26.
//

import Foundation
import SwiftData
import Combine


@MainActor
final class ShoppingListViewModel: ObservableObject {
    @Published private(set) var items: [ShoppingListItem] = []
    @Published var itemName = ""
    @Published var itemCategory: ItemCategory = .milk
    @Published var selectedFilter: CategoryFilter = .category(.milk)
    @Published var editingItem: ShoppingListItem?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: ShoppingListRepositoryDelegate

    init(repository: ShoppingListRepositoryDelegate) {
        self.repository = repository
        Task {
            await loadItems()
        }
    }

    var visibleItems: [ShoppingListItem] {
        items
            .filter { selectedFilter.includes($0) }
            .sorted { lhs, rhs in
                if lhs.category == rhs.category {
                    if lhs.isCompleted != rhs.isCompleted {
                        return !lhs.isCompleted && rhs.isCompleted
                    }
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
                return lhs.category.rawValue < rhs.category.rawValue
            }
    }

    var groupedVisibleItems: [(category: ItemCategory, items: [ShoppingListItem])] {
        let grouped = Dictionary(grouping: visibleItems, by: \.category)
        return ItemCategory.allCases.compactMap { category in
            guard let values = grouped[category], !values.isEmpty else { return nil }
            return (category, values)
        }
    }

    func loadItems() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await repository.fetchItems()
            errorMessage = nil
        } catch {
            errorMessage = "Could not load items. \(error.localizedDescription)"
        }
    }

    func addItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Item name cannot be empty."
            return
        }

        Task {
            do {
                _ = try await repository.addItem(name: trimmedName, category: itemCategory)
                items = try await repository.fetchItems()
                itemName = ""
                errorMessage = nil
            } catch {
                errorMessage = "Could not add item. \(error.localizedDescription)"
            }
        }
    }

    func toggleCompletion(for item: ShoppingListItem) {
        Task {
            do {
                try await repository.toggleCompletion(for: item)
                items = try await repository.fetchItems()
                errorMessage = nil
            } catch {
                errorMessage = "Could not update item. \(error.localizedDescription)"
            }
        }
    }

    func deleteItems(at offsets: IndexSet, in category: ItemCategory) {
        let categoryItems = groupedVisibleItems.first(where: { $0.category == category })?.items ?? []
        let idsToDelete = offsets.compactMap { index -> UUID? in
            guard categoryItems.indices.contains(index) else { return nil }
            return categoryItems[index].id
        }

        let itemsToDelete = items.filter { idsToDelete.contains($0.id) }
        Task {
            do {
                try await repository.delete(items: itemsToDelete)
                items = try await repository.fetchItems()
                errorMessage = nil
            } catch {
                errorMessage = "Could not delete items. \(error.localizedDescription)"
            }
        }
    }

    func delete(item: ShoppingListItem) {
        Task {
            do {
                try await repository.delete(item: item)
                items = try await repository.fetchItems()
                errorMessage = nil
            } catch {
                errorMessage = "Could not delete item. \(error.localizedDescription)"
            }
        }
    }

    func requestEdit(for item: ShoppingListItem) {
        editingItem = item
    }

    func applyEdit(name: String, category: ItemCategory) {
        guard let editing = editingItem else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Item name cannot be empty."
            return
        }

        Task {
            do {
                try await repository.update(item: editing, name: trimmedName, category: category)
                items = try await repository.fetchItems()
                editingItem = nil
                errorMessage = nil
            } catch {
                errorMessage = "Could not update item. \(error.localizedDescription)"
            }
        }
    }

    func cancelEdit() {
        editingItem = nil
    }

    func clearError() {
        errorMessage = nil
    }
}
