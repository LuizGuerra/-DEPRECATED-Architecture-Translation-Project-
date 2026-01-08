```swift
//
//  AppDelegate.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // This is for older iOS versions or when not using SceneDelegate
        // If using SceneDelegate, this window setup is typically done there.
        // Keeping it here for completeness based on the original code,
        // but SceneDelegate will likely override it on modern iOS.
        if #available(iOS 13.0, *) {
            // SceneDelegate handles window setup
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = MainTabBarController()
            window?.makeKeyAndVisible()
        }
        return true
    }

    // MARK: UISceneSession lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

```

# File MainTabBarController.swift

```swift
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

```

# File SceneDelegate.swift

```swift
//
//  SceneDelegate.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = MainTabBarController() // Use the refactored MainTabBarController
        window?.makeKeyAndVisible()

    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        
        // (UIApplication.shared.delegate as? AppDelegate)?.saveContext() // Original comment, not relevant to this project
    }


}


```

# File Controllers/FavoritesViewController.swift

```swift
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

```

# File Controllers/PoemDetailViewController.swift

```swift
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

```

# File Controllers/PoetryViewController.swift

```swift
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

```

# File Controllers/SearchViewController.swift

```swift
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

```

# File Models/Poem.swift

```swift
//
//  Poem.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import Foundation

// Model remains the same
struct Poem: Codable, Equatable {
    let title: String
    let author: String
    let lines: [String]

    static func == (lhs: Poem, rhs: Poem) -> Bool {
        // Simple equality check based on content
        return lhs.title == rhs.title && lhs.author == rhs.author && lhs.lines == rhs.lines
    }
}

```

# File Services/FavoritesService.swift

```swift
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

```

# File Services/PoetryService.swift

```swift
//
//  PoetryService.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import Foundation

// Service remains the same, used by ViewModels
class PoetryService {
    func fetchRandomPoem(completion: @escaping (Poem?) -> Void) {
        guard let url = URL(string: "https://poetrydb.org/random") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                  error == nil,
                  let poems = try? JSONDecoder().decode([Poem].self, from: data),
                  let poem = poems.first
            else {
                completion(nil)
                return
            }
            completion(poem)
        }.resume()
    }

    func searchPoems(byTitle title: String, completion: @escaping ([Poem]) -> Void) {
        let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://poetrydb.org/title/\(encoded)") else {
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let poems = try? JSONDecoder().decode([Poem].self, from: data)
            else {
                completion([])
                return
            }
            completion(poems)
        }.resume()
    }

    func searchPoems(byAuthor author: String, completion: @escaping ([Poem]) -> Void) {
        let encoded = author.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://poetrydb.org/author/\(encoded)") else {
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let poems = try? JSONDecoder().decode([Poem].self, from: data)
            else {
                completion([])
                return
            }
            completion(poems)
        }.resume()
    }

    func searchPoems(byLineCount count: Int, completion: @escaping ([Poem]) -> Void) {
        guard let url = URL(string: "https://poetrydb.org/lines/\(count)") else {
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let poems = try? JSONDecoder().decode([Poem].self, from: data)
            else {
                completion([])
                return
            }
            completion(poems)
        }.resume()
    }
}

```

# File View/PoetryView.swift

```swift
//
//  PoetryView.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//titleLabel.numberOfLines = 0

import UIKit

// PoetryView remains the visual component, configured by the ViewController (which gets data from ViewModel)
class PoetryView: UIView {
    // MARK: - Subviews
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let cardView = UIView()
    private var gradientLayer: CAGradientLayer?

    let titleLabel = UILabel()
    let authorLabel = UILabel()
    let linesCountLabel = UILabel()
    let poemLabel = UILabel()
    
    let loadingIndicator: UIActivityIndicatorView = {
        let iv = UIActivityIndicatorView(style: .large)
        iv.color = .white
        iv.hidesWhenStopped = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupGradientBackground()
        setupSubviews()
        setupLoadingIndicator()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }

    // MARK: - Background
    private func setupGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemPink.cgColor,
            UIColor.systemOrange.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }

    // MARK: - Layout
    private func setupSubviews() {
        // Scroll hierarchy
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Card container
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        // Configure labels
        titleLabel.font = .systemFont(ofSize: 28, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label

        authorLabel.font = .systemFont(ofSize: 18, weight: .medium)
        authorLabel.numberOfLines = 1
        authorLabel.textColor = .secondaryLabel

        linesCountLabel.font = .systemFont(ofSize: 16)
        linesCountLabel.textColor = .tertiaryLabel

        poemLabel.font = .systemFont(ofSize: 18)
        poemLabel.numberOfLines = 0
        poemLabel.textColor = .label

        // Apply paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        poemLabel.attributedText = NSAttributedString(string: "", attributes: [.paragraphStyle: paragraphStyle])

        // Stack
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            authorLabel,
            linesCountLabel,
            poemLabel
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stack)

        // Constraints
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            // contentView
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // cardView
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            // stack inside card
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupLoadingIndicator() {
        addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // convenience methods to show/hide loader - controlled by ViewController based on ViewModel state
    func showLoading() {
        // hide the content card while loading, if you like:
        cardView.alpha = 0.5
        loadingIndicator.startAnimating()
    }

    func hideLoading() {
        loadingIndicator.stopAnimating()
        cardView.alpha = 1.0
    }
}

```

# File View/SearchView.swift

```swift
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

```

# File ViewModels/FavoritesViewModel.swift

```swift
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

```

# File ViewModels/PoemDetailViewModel.swift

```swift
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

```

# File ViewModels/PoetryViewModel.swift

```swift
//
//  PoetryViewModel.swift
//  Poetry2
//
//  Created by Luiz Pedro Franciscatto Guerra on 2025-04-22.
//

import Foundation

// ViewModel for the Daily Poem screen
class PoetryViewModel {
    private let poetryService: PoetryService // Dependency

    // State exposed to the View (ViewController)
    private(set) var currentPoem: Poem? {
        didSet {
            // Notify the View whenever the poem data changes
            onPoemLoaded?(currentPoem)
        }
    }

    private(set) var isLoading: Bool = false {
        didSet {
            // Notify the View whenever the loading state changes
            onLoadingStateChanged?(isLoading)
        }
    }

    // Binding closures to notify the View
    var onPoemLoaded: ((Poem?) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    // Inject dependencies
    init(poetryService: PoetryService) {
        self.poetryService = poetryService
    }

    // MARK: - Actions/Logic

    // Called by the View (ViewController) when it's ready to load
    func fetchRandomPoem() {
        isLoading = true // Update state, triggers binding
        poetryService.fetchRandomPoem { [weak self] poem in
            // Ensure updates happen on the main thread as they affect UI state
            DispatchQueue.main.async {
                self?.currentPoem = poem // Update state, triggers binding
                self?.isLoading = false // Update state, triggers binding
            }
        }
    }
}

```

# File ViewModels/SearchViewModel.swift

```swift
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
                    self?.errorMessage = "Please enter a valid number of lines." // Update state, triggers binding
                    self?.isLoading = false // Stop loading
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

```