//
//  ShoppingListAppApp.swift
//  ShoppingListApp
//
//  Created by Md Mozammil on 16/02/26.
//

import SwiftUI
import SwiftData

@main
struct ShoppingListAppApp: App {
    private let modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: ShoppingListItem.self)
        } catch {
            fatalError("Could not create SwiftData container: \(error)")
        }
    }()
    var body: some Scene {
        WindowGroup {
            ShoppingListHomePage(modelContext: modelContainer.mainContext)
        }
        .modelContainer(modelContainer)
    }
}
