import SwiftUI

struct ContentView: View {
    var body: some View {
        // Use TabView to structure the main screens
        TabView {
            // Daily View Tab
            // Embed in NavigationStack for future navigation
            NavigationStack {
                DailyView()
            }
            .tabItem {
                Label("Daily", systemImage: "book")
            }

            // Search & Browse View Tab (Placeholder)
            NavigationStack {
                Text("Search View Placeholder")
                    .navigationTitle("Search")
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            // Favorites View Tab (Placeholder)
            NavigationStack {
                Text("Favorites View Placeholder")
                    .navigationTitle("Favorites")
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }
        }
    }
}

#Preview {
    // Provide a mock Core Data context for the preview
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
