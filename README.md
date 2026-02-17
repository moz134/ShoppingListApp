# ShoppingListApp

A simple grocery/shopping list app built with **SwiftUI** and **SwiftData**.

## What this app does

- Add grocery items with category
- Mark items as completed
- Edit item name/category
- Delete items (with confirmation)
- Filter items by category
- Save data locally so items remain after app restart

## Tech used

- SwiftUI (UI)
- SwiftData (local persistence). Core Data or File Storage could also be done.
- iOS: 17.0+
- Xcode: 26

## Prerequisites

1. macOS with Xcode installed
2. iOS Simulator runtime installed in Xcode

## Run the app (Beginner friendly)

1. Open Finder and go to:
   - `~/ShoppingListApp/ShoppingListApp.xcodeproj`
2. Double-click:
   - `ShoppingListApp.xcodeproj`
3. Wait for Xcode to finish indexing the project.
4. At top of Xcode, select the scheme:
   - `ShoppingListApp`
5. Choose a simulator device:
   - Example: `iPhone 16` (or any iOS 17+ simulator)
6. Press the **Run** button (triangle) or `Cmd + R`.
7. The app will launch in the simulator.

## If build fails because of signing

For simulator, usually no signing is needed. If Xcode still asks:

1. Open project in Xcode.
2. Click the blue project icon in left sidebar.
3. Select target: `ShoppingListApp`.
4. Open tab: **Signing & Capabilities**.
5. Enable **Automatically manage signing**.
6. Select your Apple ID team (Personal Team is fine).
7. Try `Cmd + R` again.

## How to use the app

1. Type item name in **Item Name** field.
2. Select a category chip.
3. Tap **Add Item**.
4. Use the circle icon on row to mark complete.
5. Tap the `...` menu on a row:
   - **Edit** to change name/category
   - **Delete** to remove (with confirmation)

## Data persistence

- The app uses SwiftData.
- Your items are automatically stored on device/simulator.
- Closing and reopening app keeps your data.
