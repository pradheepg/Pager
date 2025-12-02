//
//  TabBarViewController.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let libraryVC = LibraryViewController()
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        libraryNav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "books.vertical"), tag: 1)
        
        let bookStoreVC = BookStoreViewController()
        let bookStoreNav = UINavigationController(rootViewController: bookStoreVC)
        bookStoreNav.tabBarItem = UITabBarItem(title: "Book Store", image: UIImage(systemName: "bag"), tag: 2)
        
        let searchVC = SearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 3)
        viewControllers = [homeNav, libraryNav, bookStoreNav, searchNav]
    }

}

//
//import UIKit
//
//class MainTabBarController: UITabBarController {
//
//    // MARK: - UI Elements
//    private let floatingContainer = UIView()
//    private let capsuleView = UIView()
//    private let searchButton = UIButton()
//    private var tabButtons: [UIButton] = []
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // 1. Hide the native tab bar so we can use our custom one
//        tabBar.isHidden = true
//        
//        // 2. Setup the ViewControllers (Home, Library, etc.)
//        setupTabs()
//        
//        // 3. Build the Custom Interface
//        setupCustomTabBarUI()
//    }
//
//    // MARK: - Tab Setup
//    private func setupTabs() {
//        let homeVC = HomeViewController()
//        let homeNav = UINavigationController(rootViewController: homeVC)
//        // We set these item properties just in case, though our custom UI overrides the visuals
//        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
//        
//        let libraryVC = LibraryViewController()
//        let libraryNav = UINavigationController(rootViewController: libraryVC)
//        libraryNav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "books.vertical"), tag: 1)
//        
//        let bookStoreVC = BookStoreViewController()
//        let bookStoreNav = UINavigationController(rootViewController: bookStoreVC)
//        bookStoreNav.tabBarItem = UITabBarItem(title: "Book Store", image: UIImage(systemName: "bag"), tag: 2)
//        
//        let searchVC = SearchViewController()
//        let searchNav = UINavigationController(rootViewController: searchVC)
//        searchNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 3)
//        
//        viewControllers = [homeNav, libraryNav, bookStoreNav, searchNav]
//    }
//    
//    // MARK: - Custom UI Construction
//    private func setupCustomTabBarUI() {
//        // Add container to the view hierarchy
//        view.addSubview(floatingContainer)
//        floatingContainer.addSubview(capsuleView)
//        floatingContainer.addSubview(searchButton)
//        
//        floatingContainer.translatesAutoresizingMaskIntoConstraints = false
//        capsuleView.translatesAutoresizingMaskIntoConstraints = false
//        searchButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        // --- 1. Style the Capsule (Left Side) ---
//        capsuleView.backgroundColor = .secondarySystemBackground
//        capsuleView.layer.cornerRadius = 32 // Height is 64, so 32 makes it pill-shaped
//        
//        // Add subtle shadow to the capsule
//        capsuleView.layer.shadowColor = UIColor.black.cgColor
//        capsuleView.layer.shadowOpacity = 0.1
//        capsuleView.layer.shadowOffset = CGSize(width: 0, height: 4)
//        capsuleView.layer.shadowRadius = 8
//        
//        // --- 2. Style the Search Button (Right Side) ---
//        // This function handles the iOS 26 Liquid Glass logic
//        if #available(iOS 26, *) {
//            setupLiquidSearchButton()
//        } else {
//            // Fallback for iOS 25 and older (this code exists in your setupLiquidSearchButton's else block)
//            searchButton.backgroundColor = .secondarySystemBackground
//            searchButton.layer.cornerRadius = 32
//            searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
//            searchButton.tintColor = .label
//            searchButton.layer.shadowOpacity = 0.1
//            searchButton.layer.shadowRadius = 10
//            searchButton.layer.shadowOffset = CGSize(width: 0, height: 4)
//        }
//        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
//
//        // --- 3. Create Tab Buttons (Icons) ---
//        let icons = ["house.fill", "books.vertical.fill", "bag.fill"]
//        let titles = ["Home", "Library", "Store"]
//        
//        let buttonStack = UIStackView()
//        buttonStack.axis = .horizontal
//        buttonStack.distribution = .fillEqually
//        buttonStack.spacing = 10
//        buttonStack.translatesAutoresizingMaskIntoConstraints = false
//        
//        for (index, iconName) in icons.enumerated() {
//            let btn = createTabButton(icon: iconName, title: titles[index], index: index)
//            tabButtons.append(btn)
//            buttonStack.addArrangedSubview(btn)
//        }
//        
//        capsuleView.addSubview(buttonStack)
//        
//        // --- 4. Layout Constraints ---
//        NSLayoutConstraint.activate([
//            // Floating Container: Pinned to bottom, with padding
//            floatingContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            floatingContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            floatingContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
//            floatingContainer.heightAnchor.constraint(equalToConstant: 64),
//            
//            // Search Button: Fixed circle on the right
//            searchButton.trailingAnchor.constraint(equalTo: floatingContainer.trailingAnchor),
//            searchButton.topAnchor.constraint(equalTo: floatingContainer.topAnchor),
//            searchButton.bottomAnchor.constraint(equalTo: floatingContainer.bottomAnchor),
//            searchButton.widthAnchor.constraint(equalTo: searchButton.heightAnchor), // 1:1 Aspect Ratio (Circle)
//            
//            // Capsule: Fills the remaining space on the left
//            capsuleView.leadingAnchor.constraint(equalTo: floatingContainer.leadingAnchor),
//            capsuleView.topAnchor.constraint(equalTo: floatingContainer.topAnchor),
//            capsuleView.bottomAnchor.constraint(equalTo: floatingContainer.bottomAnchor),
//            capsuleView.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -15), // Gap between pill and circle
//            
//            // Stack View: Centered inside the capsule
//            buttonStack.leadingAnchor.constraint(equalTo: capsuleView.leadingAnchor, constant: 5),
//            buttonStack.trailingAnchor.constraint(equalTo: capsuleView.trailingAnchor, constant: -5),
//            buttonStack.topAnchor.constraint(equalTo: capsuleView.topAnchor, constant: 5),
//            buttonStack.bottomAnchor.constraint(equalTo: capsuleView.bottomAnchor, constant: -5)
//        ])
//        
//        // Set initial state (Select Home)
//        updateButtonSelection(selectedIndex: 0)
//    }
//    
//    // MARK: - iOS 26 Liquid Glass Logic
//    @available(iOS 26, *)
//    private func setupLiquidSearchButton() {
//        var config = UIButton.Configuration.prominentGlass()
//        config.image = UIImage(systemName: "magnifyingglass")
//        config.baseForegroundColor = .label
//        config.cornerStyle = .capsule
//        
//        searchButton.configuration = config
//        
//        // The compiler can now find the UILiquidHoverInteraction type only if iOS 26 is available
//        searchButton.addInteraction(UILiquidHoverInteraction())
//
//    }
//    
//    
//    // MARK: - Helper Methods
//    private func createTabButton(icon: String, title: String, index: Int) -> UIButton {
//        let button = UIButton()
//        var config = UIButton.Configuration.plain()
//        config.image = UIImage(systemName: icon)
//        config.imagePadding = 5
//        config.imagePlacement = .top
//        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
//        
//        button.configuration = config
//        button.tintColor = .systemGray // Default unselected color
//        button.tag = index
//        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
//        return button
//    }
//
//    private func updateButtonSelection(selectedIndex: Int) {
//        // 1. Reset all capsule buttons to Gray
//        for btn in tabButtons {
//            btn.tintColor = .systemGray
//        }
//        
//        // 2. Reset Search Button visuals (if needed)
//        if #available(iOS 26, *) {
//            searchButton.configuration?.baseForegroundColor = .label
//        } else {
//            searchButton.tintColor = .label
//            searchButton.backgroundColor = .secondarySystemBackground
//        }
//        
//        // 3. Apply Active State
//        if selectedIndex == 3 {
//            // Search Tab Selected
//            if #available(iOS 26, *) {
//                searchButton.configuration?.baseForegroundColor = .systemBlue
//            } else {
//                searchButton.backgroundColor = .systemBlue
//                searchButton.tintColor = .white
//            }
//        } else {
//            // Capsule Tab Selected
//            if selectedIndex < tabButtons.count {
//                tabButtons[selectedIndex].tintColor = .systemBlue
//            }
//        }
//    }
//    
//    // MARK: - Actions
//    @objc private func tabButtonTapped(_ sender: UIButton) {
//        let index = sender.tag
//        selectedIndex = index
//        updateButtonSelection(selectedIndex: index)
//    }
//    
//    @objc private func searchButtonTapped() {
//        let searchIndex = 3
//        selectedIndex = searchIndex
//        updateButtonSelection(selectedIndex: searchIndex)
//    }
//}
