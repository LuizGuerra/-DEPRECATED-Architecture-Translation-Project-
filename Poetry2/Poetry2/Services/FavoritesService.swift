//
//  FavoritesService.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import Foundation

// Service remains the same, used by ViewModels
class FavoritesService {
    static let shared = FavoritesService()
    private let key = "favoritedPoems"
    private init() {}

    func getFavorites() -> [Poem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let poems = try? JSONDecoder().decode([Poem].self, from: data) else {
            return []
        }
        return poems
    }

    func isFavorite(_ poem: Poem) -> Bool {
        return getFavorites().contains(poem)
    }

    func add(_ poem: Poem) {
        var current = getFavorites()
        if !current.contains(poem) {
            current.append(poem)
            save(current)
        }
    }

    func remove(_ poem: Poem) {
        var current = getFavorites()
        current.removeAll { $0 == poem }
        save(current)
    }

    private func save(_ poems: [Poem]) {
        if let data = try? JSONEncoder().encode(poems) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

