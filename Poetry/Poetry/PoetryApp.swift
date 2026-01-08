//
//  PoetryApp.swift
//  Poetry
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-21.
//

import SwiftUI

@main
struct PoetryApp: App {
    let coreDataManager = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.container.viewContext)
        }
    }
}
