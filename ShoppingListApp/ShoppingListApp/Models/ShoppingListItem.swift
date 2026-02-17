//
//  ShoppingListItem.swift
//  ShoppingListApp
//
//  Created by Md Mozammil on 16/02/26.
//

import Foundation
import SwiftData

enum ItemCategory: String, CaseIterable, Codable, Identifiable {
    case milk = "Milk"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case breads = "Breads"
    case meats = "Meats"

    var id: String {
        rawValue
    }
}

@Model
final class ShoppingListItem {
    var id: UUID
    var name: String
    var categoryRawValue: String
    var isCompleted: Bool

    var category: ItemCategory {
        get {
            ItemCategory(rawValue: categoryRawValue) ?? .milk
        }
        set {
            categoryRawValue = newValue.rawValue
        }
    }

    init(id: UUID = UUID(), name: String, category: ItemCategory, isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.categoryRawValue = category.rawValue
        self.isCompleted = isCompleted
    }
}

enum CategoryFilter: Equatable {
    case category(ItemCategory)

    var title: String {
        switch self {
        case let .category(category):
            return category.rawValue
        }
    }

    func includes(_ item: ShoppingListItem) -> Bool {
        switch self {
        case let .category(category):
            return item.category == category
        }
    }
}

