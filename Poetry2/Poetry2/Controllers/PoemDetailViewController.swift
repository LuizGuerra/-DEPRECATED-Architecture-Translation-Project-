//
//  PoemDetailViewController.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import UIKit

// PoemDetailViewController now acts as the View layer in MVVM
class PoemDetailViewController: UIViewController {
    private let poetryView = PoetryView() // The visual view component
    private let viewModel: PoemDetailViewModel // Holds the ViewModel

    // Inject the ViewModel
    init(viewModel: PoemDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = poetryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.poem.title // Configure UI based on ViewModel data

        setupFavoriteButton() // Setup the favorite button
        setupBindings() // Set up bindings to react to ViewModel changes
        updateView(with: viewModel.poem) // Populate view initially
    }

    // Configure the favorite button based on ViewModel state
    private func setupFavoriteButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: viewModel.isFavorite ? "heart.fill" : "heart"), // Get state from ViewModel
            style: .plain,
            target: self,
            action: #selector(toggleFavoriteTapped) // Action calls ViewController method
        )
    }

    // Populate the visual view component with data from the ViewModel
    private func updateView(with poem: Poem) {
        poetryView.titleLabel.text = poem.title
        poetryView.authorLabel.text = "by \(poem.author)"
        poetryView.linesCountLabel.text = "\(poem.lines.count) lines"
        poetryView.poemLabel.text = poem.lines.joined(separator: "\n")
    }

    // Bind ViewModel state changes to UI updates
    private func setupBindings() {
        viewModel.onFavoriteStatusChanged = { [weak self] isFavorite in
            // This closure is called by the ViewModel when favorite status changes
            DispatchQueue.main.async {
                self?.navigationItem.rightBarButtonItem?.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
            }
        }
    }

    // User action delegated to ViewModel
    @objc private func toggleFavoriteTapped() {
        viewModel.toggleFavoriteStatus() // Ask ViewModel to handle the action
    }
}

