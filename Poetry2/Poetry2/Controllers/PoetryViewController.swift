//
//  PoetryViewController.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import UIKit

// PoetryViewController now acts as the View layer in MVVM
class PoetryViewController: UIViewController {
    private let poetryView = PoetryView() // The visual view component
    private let viewModel: PoetryViewModel // Holds the ViewModel

    // Inject the ViewModel
    init(viewModel: PoetryViewModel) {
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
        title = "Daily Poem"

        setupBindings() // Set up bindings to react to ViewModel changes

        // Kick off loading via the ViewModel
        viewModel.fetchRandomPoem()
    }

    // Bind ViewModel state changes to UI updates
    private func setupBindings() {
        viewModel.onPoemLoaded = { [weak self] poem in
            // This closure is called by the ViewModel when a poem is loaded
            DispatchQueue.main.async {
                if let poem = poem {
                    self?.updateView(with: poem) // Update the visual view
                } else {
                    // Handle error or no poem found
                    self?.poetryView.titleLabel.text = "Error"
                    self?.poetryView.authorLabel.text = ""
                    self?.poetryView.linesCountLabel.text = ""
                    self?.poetryView.poemLabel.text = "Could not load poem."
                }
            }
        }

        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            // This closure is called by the ViewModel when loading state changes
            DispatchQueue.main.async {
                if isLoading {
                    self?.poetryView.showLoading() // Show loading indicator
                } else {
                    self?.poetryView.hideLoading() // Hide loading indicator
                }
            }
        }
    }

    // Populate the visual view component with data from the ViewModel
    private func updateView(with poem: Poem) {
        poetryView.titleLabel.text = poem.title
        poetryView.authorLabel.text = "by \(poem.author)"
        poetryView.linesCountLabel.text = "\(poem.lines.count) lines"
        poetryView.poemLabel.text = poem.lines.joined(separator: "\n")
    }
}

