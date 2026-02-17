//
//  ShoppingListItemRow.swift
//  ShoppingListApp
//
//  Created by Md Mozammil on 16/02/26.
//

import SwiftUI

struct ShoppingListItemRow: View {
    let item: ShoppingListItem
    let onToggleCompletion: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggleCompletion) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
                    .font(.title2)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 18, weight: .semibold))
                    .strikethrough(item.isCompleted, color: .secondary)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)

                Text(item.category.rawValue)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Menu {
                Button("Edit", action: onEdit)
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

//#Preview {
//    ShoppingListItemRow(item: ShoppingListItem(id: "", name: "", category: ItemCategory(from: ), isCompleted: false), onToggleCompletion: {})
//}
