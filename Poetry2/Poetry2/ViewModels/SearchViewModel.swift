//
//  SearchViewModel.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import Foundation

// ViewModel for the Search screen
class SearchViewModel {
    private let poetryService: PoetryService // Dependency

    // State exposed to the View (ViewController)
    private(set) var searchResults: [Poem] = [] {
        didSet {
            // Notify the View whenever the search results change
            onSearchResultsUpdated?(searchResults)
        }
    }

    private(set) var isLoading: Bool = false {
        didSet {
            // Notify the View whenever the loading state changes
            onLoadingStateChanged?(isLoading)
        }
    }

    private(set) var errorMessage: String? {
        didSet {
            // Notify the View whenever an error message is set
            onErrorMessage?(errorMessage)
        }
    }

    // Binding closures to notify the View
    var onSearchResultsUpdated: (([Poem]) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onErrorMessage: ((String?) -> Void)?

    // Inject dependencies
    init(poetryService: PoetryService) {
        self.poetryService = poetryService
    }

    // MARK: - Actions/Logic

    // Called by the View (ViewController) when the search button is tapped
    func performSearch(type: SearchType, query: String) {
        // Clear previous state and show loading
        searchResults = [] // Clear results immediately
        errorMessage = nil // Clear previous error
        isLoading = true // Update state, triggers binding

        let completion: ([Poem]) -> Void = { [weak self] results in
            // Ensure updates happen on the main thread as they affect UI state
            DispatchQueue.main.async {
                self?.searchResults = results // Update state, triggers binding
                self?.isLoading = false // Update state, triggers binding
                // If results are empty, the View might show a "No results" message
                // This logic can live in the View or be driven by another ViewModel state property
            }
        }

        switch type {
        case .title:
            poetryService.searchPoems(byTitle: query, completion: completion)
        case .author:
            poetryService.searchPoems(byAuthor: query, completion: completion)
        case .lines:
            if let count = Int(query) {
                poetryService.searchPoems(byLineCount: count, completion: completion)
            } else {
                // Handle invalid input
                DispatchQueue.main.async {
                    self.errorMessage = "Please enter a valid number of lines." // Update state, triggers binding
                    self.isLoading = false // Stop loading
                }
            }
        }
    }

    // Called by the View (ViewController) for table view data source
    func poem(at index: Int) -> Poem? {
        guard index >= 0, index < searchResults.count else { return nil }
        return searchResults[index]
    }
}

