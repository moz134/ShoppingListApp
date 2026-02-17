//
//  EditItemView.swift
//  ShoppingListApp
//
//  Created by Md Mozammil on 16/02/26.
//


import SwiftUI

struct EditItemView: View {
    @State private var name: String
    @State private var category: ItemCategory

    let onSave: (String, ItemCategory) -> Void
    let onCancel: () -> Void

    init(item: ShoppingListItem, onSave: @escaping (String, ItemCategory) -> Void, onCancel: @escaping () -> Void) {
        _name = State(initialValue: item.name)
        _category = State(initialValue: item.category)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("Item name", text: $name)
                        .textInputAutocapitalization(.words)
                }
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, category)
                    }
                }
            }
        }
    }
}
