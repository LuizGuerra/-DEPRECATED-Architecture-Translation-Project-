//
//  Persistence.swift
//  Poetry
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-21.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    // Container for the Core Data stack
        let container: NSPersistentContainer

        // Private initializer to enforce singleton
        private init(inMemory: Bool = false) {
            container = NSPersistentContainer(name: "VerseExplorerModel") // Use the name of your .xcdatamodeld file

            if inMemory {
                // Use this for testing or previews
                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }

            container.loadPersistentStores { storeDescription, error in
                if let error = error as NSError? {
                    // Handle the error appropriately in a real app
                    // For now, print and potentially crash during development
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }

            // Automatically merge changes from different contexts (important for concurrency)
            container.viewContext.automaticallyMergesChangesFromParent = true
        }

        // --- Preview Data for Canvas ---
        static var preview: PersistenceController = {
            let manager = PersistenceController(inMemory: true)
            // You could add some preview data here if needed
            let context = manager.container.viewContext
            // Example: Add a preview DailyPoemEntity
            let newPoem = DailyPoemEntity(context: context)
            newPoem.date = Date()
            newPoem.title = "Preview Poem"
            newPoem.author = "Preview Author"
            if let linesData = try? JSONEncoder().encode(["Line 1", "Line 2"]) {
                newPoem.lines = linesData
            }
            try? context.save()

            return manager
        }()


        // --- Save and Load Functions for Daily Poem ---

        func saveDailyPoem(poem: Poem, date: Date, context: NSManagedObjectContext) {
            // Delete any existing DailyPoemEntity before saving the new one
            let fetchRequest: NSFetchRequest<DailyPoemEntity> = NSFetchRequest(entityName: "DailyPoemEntity")
             if let result = try? context.fetch(fetchRequest) {
                 for object in result {
                     context.delete(object)
                 }
             }


            let dailyPoemEntity = DailyPoemEntity(context: context)
            dailyPoemEntity.date = date
            dailyPoemEntity.title = poem.title
            dailyPoemEntity.author = poem.author
            // Encode the lines array to Data
            if let linesData = try? JSONEncoder().encode(poem.lines) {
                dailyPoemEntity.lines = linesData
            } else {
                print("Error encoding poem lines for saving.")
                dailyPoemEntity.lines = nil // Save nil if encoding fails
            }

            saveContext(context: context)
        }

        func loadDailyPoem(context: NSManagedObjectContext) -> DailyPoemEntity? {
            let request: NSFetchRequest<DailyPoemEntity> = DailyPoemEntity.fetchRequest()
            request.fetchLimit = 1 // We only expect one daily poem

            do {
                let results = try context.fetch(request)
                return results.first // Return the single daily poem if found
            } catch {
                print("Error fetching daily poem from Core Data: \(error)")
                return nil
            }
        }

        // Helper function to save the context
        func saveContext(context: NSManagedObjectContext) {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Handle the error appropriately
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    
}
