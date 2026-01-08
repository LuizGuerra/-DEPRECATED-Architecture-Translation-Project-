//
//  SearchViewController.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import UIKit

// SearchViewController now acts as the View layer in MVVM
class SearchViewController: UIViewController {
    private let searchView = SearchView() // The visual view component
    private let viewModel: SearchViewModel // Holds the ViewModel

    // Inject the ViewModel
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = searchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"

        // Configure the visual view component
        searchView.delegate = self // SearchViewDelegate calls ViewController
        searchView.tableView.dataSource = self // TableView DataSource/Delegate remain in ViewController
        searchView.tableView.delegate = self

        setupBindings() // Set up bindings to react to ViewModel changes
    }

    // Bind ViewModel state changes to UI updates
    private func setupBindings() {
        viewModel.onSearchResultsUpdated = { [weak self] poems in
            // This closure is called by the ViewModel when search results are ready
            DispatchQueue.main.async {
                self?.searchView.tableView.reloadData() // Reload table view
                self?.searchView.showResults(poems) // Update SearchView's status/visibility
            }
        }

        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            // This closure is called by the ViewModel when loading state changes
            DispatchQueue.main.async {
                if isLoading {
                    self?.searchView.showLoading() // Show loading indicator in SearchView
                } else {
                    self?.searchView.hideLoading() // Hide loading indicator in SearchView
                }
            }
        }

        viewModel.onErrorMessage = { [weak self] message in
            // This closure is called by the ViewModel when an error occurs
            DispatchQueue.main.async {
                if let msg = message {
                    self?.searchView.showError(msg) // Show error message in SearchView
                } else {
                    // Hide error message if needed (e.g., on new search)
                    self?.searchView.statusLabel.isHidden = true
                }
            }
        }
    }
}

// SearchViewDelegate now calls the ViewModel via the ViewController
extension SearchViewController: SearchViewDelegate {
    func didTapSearch(type: SearchType, query: String) {
        // Delegate the search action to the ViewModel
        viewModel.performSearch(type: type, query: query)
    }
}

// TableView DataSource and Delegate get data from the ViewModel
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResults.count // Get data from ViewModel
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let poem = viewModel.searchResults[indexPath.row] // Get data from ViewModel
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(poem.title) by \(poem.author) (\(poem.lines.count) lines)"
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let poem = viewModel.searchResults[indexPath.row] // Get data from ViewModel
        // Instantiate the detail VC with its ViewModel
        let detailViewModel = PoemDetailViewModel(poem: poem, favoritesService: FavoritesService.shared)
        let detailVC = PoemDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

