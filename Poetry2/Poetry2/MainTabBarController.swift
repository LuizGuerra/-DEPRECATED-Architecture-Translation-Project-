//
//  MainTabBarController.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .systemPink
        tabBar.backgroundColor = .systemBackground

        // Instantiate ViewControllers and their corresponding ViewModels
        let poetryViewModel = PoetryViewModel(poetryService: PoetryService())
        let poetryVC = PoetryViewController(viewModel: poetryViewModel)
        poetryVC.tabBarItem = UITabBarItem(title: "Poem", image: UIImage(systemName: "book"), tag: 0)
        let poetryNav = UINavigationController(rootViewController: poetryVC)

        let searchViewModel = SearchViewModel(poetryService: PoetryService())
        let searchVC = SearchViewController(viewModel: searchViewModel)
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        let searchNav = UINavigationController(rootViewController: searchVC)

        let favoritesViewModel = FavoritesViewModel(favoritesService: FavoritesService.shared)
        let favoritesVC = FavoritesViewController(viewModel: favoritesViewModel)
        favoritesVC.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart.fill"), tag: 2)
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)

        viewControllers = [poetryNav, searchNav, favoritesNav]
    }
}

