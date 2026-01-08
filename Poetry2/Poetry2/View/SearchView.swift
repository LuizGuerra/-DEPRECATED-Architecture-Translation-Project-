//
//  SearchView.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import UIKit

// SearchViewDelegate remains, used by the ViewController to forward actions to the ViewModel
protocol SearchViewDelegate: AnyObject {
    func didTapSearch(type: SearchType, query: String)
}

enum SearchType {
    case title, author, lines
}

// SearchView remains the visual component, configured by the ViewController (which gets data/state from ViewModel)
class SearchView: UIView {
    let segmentedControl = UISegmentedControl(items: ["Title", "Author", "Lines"])
    let textField = UITextField()
    let searchButton = UIButton(type: .system)
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    let statusLabel = UILabel()
    let tableView = UITableView() // TableView is part of the view, data source/delegate handled by ViewController
    weak var delegate: SearchViewDelegate? // Delegate to notify ViewController of user actions


    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        segmentedControl.selectedSegmentIndex = 0
        textField.placeholder = "Enter search"
        textField.borderStyle = .roundedRect
        searchButton.setTitle("Search", for: .normal)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 16)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.isHidden = true // Initially hidden

        let inputStack = UIStackView(arrangedSubviews: [textField, searchButton, activityIndicator])
        inputStack.axis = .horizontal
        inputStack.spacing = 8
        inputStack.distribution = .fillProportionally
        inputStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [segmentedControl, inputStack, statusLabel, tableView])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32),
            searchButton.widthAnchor.constraint(equalToConstant: 80)
        ])

        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.isHidden = true // Initially hide table view
    }
    
    // MARK: – State Updates (Controlled by ViewController based on ViewModel)

    func showLoading() {
        searchButton.isEnabled = false
        activityIndicator.startAnimating()
        statusLabel.isHidden = true // Hide status/error message
        tableView.isHidden = true // Hide results table
    }

    func hideLoading() {
        searchButton.isEnabled = true
        activityIndicator.stopAnimating()
    }
    
    // MARK: – Actions (Delegate to ViewController)

    @objc private func searchTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        // Notify the delegate (ViewController) of the user action
        delegate?.didTapSearch(type: searchType(), query: text)
        textField.resignFirstResponder()
    }

    private func searchType() -> SearchType {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return .title
        case 1: return .author
        default: return .lines
        }
    }
    
    // MARK: – Display Results/Errors (Controlled by ViewController based on ViewModel)

    func showResults(_ poems: [Poem]) {
        // This method is called by the ViewController after ViewModel updates
        activityIndicator.stopAnimating() // Ensure loading is stopped
        if poems.isEmpty {
            statusLabel.text = "No results found."
            statusLabel.isHidden = false // Show status message
            tableView.isHidden = true // Hide table
        } else {
            statusLabel.isHidden = true // Hide status message
            tableView.isHidden = false // Show table
        }
    }

    func showError(_ message: String) {
        // This method is called by the ViewController after ViewModel updates
        activityIndicator.stopAnimating() // Ensure loading is stopped
        statusLabel.text = message
        statusLabel.isHidden = false // Show error message
        tableView.isHidden = true // Hide table
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

