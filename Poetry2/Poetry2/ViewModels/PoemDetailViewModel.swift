//
//  PoemDetailViewModel.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import Foundation

// ViewModel for the Poem Detail screen
class PoemDetailViewModel {
    // State exposed to the View (ViewController)
    let poem: Poem // The poem data itself
    private(set) var isFavorite: Bool {
        didSet {
            // Notify the View whenever the favorite status changes
            onFavoriteStatusChanged?(isFavorite)
        }
    }

    private let favoritesService: FavoritesService // Dependency

    // Binding closure to notify the View
    var onFavoriteStatusChanged: ((Bool) -> Void)?

    // Inject dependencies and initial data
    init(poem: Poem, favoritesService: FavoritesService) {
        self.poem = poem
        self.favoritesService = favoritesService
        // Determine initial favorite status
        self.isFavorite = favoritesService.isFavorite(poem)
    }

    // MARK: - Actions/Logic

    // Called by the View (ViewController) when the favorite button is tapped
    func toggleFavoriteStatus() {
        if isFavorite {
            favoritesService.remove(poem)
        } else {
            favoritesService.add(poem)
        }
        // Update the internal state, which triggers the binding
        isFavorite = favoritesService.isFavorite(poem)
    }
}

