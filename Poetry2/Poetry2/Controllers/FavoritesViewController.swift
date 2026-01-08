//
//  FavoritesViewController.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import UIKit

// FavoritesViewController now acts as the View layer in MVVM
class FavoritesViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel: FavoritesViewModel // Holds the ViewModel

    // Inject the ViewModel
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        view.backgroundColor = .white

        setupTableView()
        setupBindings() // Set up bindings to react to ViewModel changes
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites() // Ask ViewModel to load data
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }

    // Bind ViewModel state to UI updates
    private func setupBindings() {
        viewModel.onFavoritesUpdated = { [weak self] in
            // This closure is called by the ViewModel when favorites change
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

// Data Source and Delegate now get data from the ViewModel
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favorites.count // Get data from ViewModel
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let poem = viewModel.favorites[indexPath.row] // Get data from ViewModel
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(poem.title) by \(poem.author) (\(poem.lines.count) lines)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let poem = viewModel.favorites[indexPath.row] // Get data from ViewModel
        // Instantiate the detail VC with its ViewModel
        let detailViewModel = PoemDetailViewModel(poem: poem, favoritesService: FavoritesService.shared)
        let detailVC = PoemDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delegate the deletion logic to the ViewModel
            viewModel.removeFavorite(at: indexPath.row)
            // The table view reload will be triggered by the ViewModel's binding
        }
    }
}

