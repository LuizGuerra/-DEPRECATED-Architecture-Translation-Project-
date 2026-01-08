import SwiftUI

struct DailyView: View {
    // Observe the ViewModel which handles state and data fetching
    @StateObject private var viewModel = DailyViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Display based on the ViewModel's state
                if viewModel.isLoading {
                    ProgressView("Loading Poem...")
                } else if let error = viewModel.error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                } else if let poem = viewModel.poem {
                    // Poem Title - Tappable
                    // Action will be implemented later to navigate to Poem Detail
                    Text(poem.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        // .onTapGesture { /* Navigate to Poem Detail */ } // Future

                    // Author Name - Tappable
                    // Action will be implemented later to navigate to Author's Poems List
                    Text("by \(poem.author)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        // .onTapGesture { /* Navigate to Author's Poems */ } // Future

                    Divider()

                    // Poem Lines
                    // Action will be implemented later to navigate to Poem Detail (if tapping text)
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(poem.lines.indices, id: \.self) { index in
                            Text(poem.lines[index])
                        }
                    }
                    // .onTapGesture { /* Navigate to Poem Detail */ } // Future

                } else {
                    // Initial state or no poem loaded
                    Text("Tap 'Daily' to load a poem.")
                        .foregroundColor(.gray)
                }

                Spacer() // Push content to the top
            }
            .padding()
        }
        .navigationTitle("Daily Verse") // Title for the NavigationStack
        .onAppear {
            // Trigger the data load when the view appears
            viewModel.loadOrCreateDailyPoem()
        }
    }
}

#Preview {
    // Provide the Core Data context for the preview
    DailyView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
