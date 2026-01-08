//
//  PoetryViewModel.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import Foundation

// ViewModel for the Daily Poem screen
class PoetryViewModel {
    private let poetryService: PoetryService // Dependency

    // State exposed to the View (ViewController)
    private(set) var currentPoem: Poem? {
        didSet {
            // Notify the View whenever the poem data changes
            onPoemLoaded?(currentPoem)
        }
    }

    private(set) var isLoading: Bool = false {
        didSet {
            // Notify the View whenever the loading state changes
            onLoadingStateChanged?(isLoading)
        }
    }

    // Binding closures to notify the View
    var onPoemLoaded: ((Poem?) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    // Inject dependencies
    init(poetryService: PoetryService) {
        self.poetryService = poetryService
    }

    // MARK: - Actions/Logic

    // Called by the View (ViewController) when it's ready to load
    func fetchRandomPoem() {
        isLoading = true // Update state, triggers binding
        poetryService.fetchRandomPoem { [weak self] poem in
            // Ensure updates happen on the main thread as they affect UI state
            DispatchQueue.main.async {
                self?.currentPoem = poem // Update state, triggers binding
                self?.isLoading = false // Update state, triggers binding
            }
        }
    }
}

