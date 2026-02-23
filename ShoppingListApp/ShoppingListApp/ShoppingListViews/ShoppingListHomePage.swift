//
//  ShoppingListHomePage.swift
//  ShoppingListApp
//
//  Created by Md Mozammil on 16/02/26.
//

import SwiftUI
import SwiftData

struct ShoppingListHomePage: View {
    @StateObject private var viewModel: ShoppingListViewModel
    @State private var itemToDelete: ShoppingListItem?
    let characterLimit = 20

    init(modelContext: ModelContext) {
        let repository = ShoppingListRepository(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ShoppingListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection()
                    inputCardSection()
                    listContentSection()
                        .padding(.horizontal)
                }
            }
            .background(Color.gray.opacity(0.08))
            .sheet(item: $viewModel.editingItem) { item in
                EditItemView(item: item,
                    onSave: { name, category in
                        viewModel.applyEdit(name: name, category: category)
                    },
                    onCancel: {
                        viewModel.cancelEdit()
                    }
                )
            }
            .alert("Delete Item", isPresented: Binding(
                get: {
                    itemToDelete != nil
                },
                set: {
                    isPresented in
                    if !isPresented {
                        itemToDelete = nil
                    }
                }
            )) {
                Button("Delete", role: .destructive) {
                    if let item = itemToDelete {
                        viewModel.delete(item: item)
                    }
                    itemToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    itemToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this item?")
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented { viewModel.clearError() }
                }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private func headerSection() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "cart.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(Color.blue)
                .cornerRadius(40)
            Text("Grocery List")
                .font(.system(size: 30, weight: .bold))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text("Add items to your shopping list")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private func inputCardSection() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Add New Item")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(alignment: .leading, spacing: 10) {
                Text("Item Name")
                    .font(.system(size: 18, weight: .bold))

                TextField("Enter grocery item...", text: $viewModel.itemName)
                    .font(.system(size: 19, weight: .medium))
                    .padding(14)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .textInputAutocapitalization(.words)
                    .onChange(of: viewModel.itemName) { updatedValue, _ in
                        if updatedValue.count > characterLimit {
                            viewModel.itemName = String(updatedValue.prefix(characterLimit))
                        }
                    }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Category")
                    .font(.system(size: 18, weight: .bold))

                HStack(spacing: 8) {
                    ForEach(ItemCategory.allCases) { category in
                        categoryChip(for: category)
                    }
                }
            }

            Button {
                viewModel.addItem()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                    Text("Add Item")
                        .font(.system(size: 24, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(.white)
                .background(addButtonColor())
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func listContentSection() -> some View {
        if viewModel.isLoading {
            ProgressView("Loading...")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
        } else if viewModel.items.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "cart")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .padding(.bottom, 4)
                Text("Your grocery list is empty")
                    .font(.system(size: 24, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Text("Add items above to get started")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        } else if viewModel.visibleItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                filterSection()
                VStack(spacing: 10) {
                    Text("No items in \(viewModel.selectedFilter.title)")
                        .font(.system(size: 30, weight: .medium))
                        .multilineTextAlignment(.center)

                    Text("Try a different category filter or add a new item.")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            }
            .padding(.bottom, 20)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                filterSection()
                ForEach(viewModel.groupedVisibleItems, id: \.category) { group in
                    Text(group.category.rawValue)
                        .font(.system(size: 22, weight: .bold))
                        .padding(.top, 4)

                    ForEach(group.items) { item in
                        ShoppingListItemRow(
                            item: item,
                            onToggleCompletion: {
                                viewModel.toggleCompletion(for: item)
                            },
                            onEdit: {
                                viewModel.requestEdit(for: item)
                            },
                            onDelete: {
                                itemToDelete = item
                            }
                        )
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }

    private func filterSection() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ItemCategory.allCases) { category in
                    filterChip(title: category.rawValue, filter: .category(category))
                }
            }
        }
    }

    private func categoryChip(for category: ItemCategory) -> some View {
        let isSelected = viewModel.itemCategory == category

        return Button {
            viewModel.itemCategory = category
        } label: {
            VStack(spacing: 5) {
                Text(categoryEmoji(for: category))
                    .font(.system(size: 24))
                Text(category.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .foregroundStyle(isSelected ? Color.white : Color.black)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func addButtonColor() -> Color {
        let hasName = !viewModel.itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if hasName {
            return Color.blue
        }
        return Color.gray
    }

    private func filterChip(title: String, filter: CategoryFilter) -> some View {
        let isSelected = viewModel.selectedFilter == filter

        return Button {
            viewModel.selectedFilter = filter
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundStyle(isSelected ? Color.white : Color.black)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func categoryEmoji(for category: ItemCategory) -> String {
        switch category {
        case .milk: return "🥛"
        case .vegetables: return "🥕"
        case .fruits: return "🍎"
        case .breads: return "🍞"
        case .meats: return "🥩"
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: ShoppingListItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    ShoppingListHomePage(modelContext: container.mainContext)
        .modelContainer(container)
}
