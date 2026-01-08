import Foundation
import SwiftUI // Needed for @Environment and @Published
import CoreData

class DailyViewModel: ObservableObject {
    // Observable properties to update the View
    @Published var poem: Poem?
    @Published var isLoading = false
    @Published var error: Error?

    // Access Core Data context
    @Environment(\.managedObjectContext) private var viewContext

    private let apiService = APIService()
    private let coreDataManager = PersistenceController.shared // Use the shared instance

    init() {
        // ViewModel is created when the view appears,
        // loadOrCreateDailyPoem will be called in .onAppear
    }

    func loadOrCreateDailyPoem() {
        isLoading = true
        error = nil

        let today = Calendar.current.startOfDay(for: Date()) // Get today's date without time

        // 1. Try to load the saved daily poem from Core Data
        if let savedPoemEntity = coreDataManager.loadDailyPoem(context: viewContext),
           let savedDate = savedPoemEntity.date,
           let savedTitle = savedPoemEntity.title,
           let savedAuthor = savedPoemEntity.author,
           let savedLinesData = savedPoemEntity.lines {

            let savedPoemDate = Calendar.current.startOfDay(for: savedDate)

            // Check if the saved poem is from today
            if savedPoemDate == today {
                // It's today's poem, load it from Core Data
                print("Loading poem from Core Data for today.")
                do {
                    let lines = try JSONDecoder().decode([String].self, from: savedLinesData)
                    self.poem = Poem(title: savedTitle, author: savedAuthor, lines: lines)
                    isLoading = false
                } catch {
                    // Handle decoding error from Core Data
                    print("Error decoding saved poem lines: \(error)")
                    self.error = error
                    isLoading = false
                    // Optionally, try fetching a new one if decoding fails
                }
                return // Found today's poem, stop here
            }
        }

        // 2. If no poem saved or saved poem is from a previous day, fetch a new one
        print("Fetching a new random poem.")
        apiService.fetchRandomPoem { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let poems):
                    if let newPoem = poems.first {
                        self.poem = newPoem
                        // 3. Save the newly fetched poem to Core Data
                        self.coreDataManager.saveDailyPoem(poem: newPoem, date: Date(), context: self.viewContext)
                        print("Fetched and saved a new daily poem.")
                    } else {
                        // API returned success but no poems (unlikely for random)
                         self.error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "API returned no poem."])
                    }
                case .failure(let apiError):
                    self.error = apiError
                    print("API Error fetching random poem: \(apiError)")
                }
            }
        }
    }

    // Future functions to load Author's poems or specific poem for navigation
    /*
    func getPoemsByAuthor(_ author: String) -> [Poem] { ... }
    func getPoemByTitle(_ title: String, author: String) -> Poem? { ... }
    */
}
