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
