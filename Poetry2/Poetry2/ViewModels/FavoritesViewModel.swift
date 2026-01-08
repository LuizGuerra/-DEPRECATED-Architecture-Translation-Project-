//
//  FavoritesViewModel.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import Foundation

// ViewModel for the Favorites screen
class FavoritesViewModel {
    private let favoritesService: FavoritesService // Dependency

    // State exposed to the View (ViewController)
    private(set) var favorites: [Poem] = [] {
        didSet {
            // Notify the View whenever the favorites list changes
            onFavoritesUpdated?()
        }
    }

    // Binding closure to notify the View
    var onFavoritesUpdated: (() -> Void)?

    // Inject dependencies
    init(favoritesService: FavoritesService) {
        self.favoritesService = favoritesService
    }

    // MARK: - Actions/Logic

    // Called by the View (ViewController) when it appears
    func loadFavorites() {
        favorites = favoritesService.getFavorites()
        // The didSet observer will trigger onFavoritesUpdated?()
    }

    // Called by the View (ViewController) on swipe-to-delete
    func removeFavorite(at index: Int) {
        guard index >= 0, index < favorites.count else { return }
        let poemToRemove = favorites[index]
        favoritesService.remove(poemToRemove)
        // Reload favorites from service to ensure state is consistent
        // This will update the 'favorites' property and trigger the binding
        loadFavorites()
    }

    // Called by the View (ViewController) for table view data source
    func poem(at index: Int) -> Poem? {
        guard index >= 0, index < favorites.count else { return nil }
        return favorites[index]
    }
}

