//
//  AddToCollectionViewController.swift
//  Pager
//
//  Created by Pradheep G on 05/01/26.
//
//
//import UIKit
//import CoreData
//
//class AddToCollectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate {
//
//    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
//    private let searchBar = UISearchBar()
//    
//    private var allItems: [BookCollection] = []
//    private var items: [BookCollection] = []
//    private let book: Book
//    
//    private let viewModel: AddToCollectionViewModel
//    private let cellIdentifier = "CollectionSelectionCell"
//    private var isOwned: Bool = false
//    init(book: Book) {
//        self.book = book
//        self.viewModel = AddToCollectionViewModel()
//        if let records = UserSession.shared.currentUser?.owned?.allObjects as? [UserBookRecord] {
//            if records.contains(where: { $0.book == book }) {
//                isOwned = true
//            }
//        }
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        title = "Add to Collection"
//        
//        setupNavBar()
//        setUpSearchBar()
//        setupTableView()
//        
//        loadCollections()
//    }
//    
//    private func loadCollections() {
//        let fetchedCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
//        self.allItems = fetchedCollections
//        
//        sortCollections()
//    }
//    
//    private func sortCollections() {
//        var filteredCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
//        let shouldShowFinished = isOwned
//        
//        if !shouldShowFinished {
//            filteredCollections.removeAll { $0.isDefault && $0.name == DefaultsName.finiahed }
//        }
//        
//        self.allItems = filteredCollections
//
//        self.allItems.sort { (first, second) -> Bool in
//            if first.isDefault != second.isDefault {
//                return first.isDefault
//            }
//            
//            let date1 = first.createdAt ?? Date.distantPast
//            let date2 = second.createdAt ?? Date.distantPast
//            
//            if date1 != date2 {
//                return date1 < date2
//            }
//            
//            return (first.name ?? "") < (second.name ?? "")
//        }
//        
//        filterContentForSearchText(searchBar.text)
//    }
//
//    private func setupNavBar() {
//        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didTapAddButton))
//        navigationItem.rightBarButtonItem = addButton
//        
//        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
//        navigationItem.leftBarButtonItem = closeButton
//    }
//    
//    @objc private func didTapClose() {
//        dismiss(animated: true)
//    }
//
//    private func setUpSearchBar() {
//        searchBar.placeholder = "Search Collections..."
//        searchBar.searchBarStyle = .minimal
//        searchBar.delegate = self
//        searchBar.sizeToFit()
//        tableView.tableHeaderView = searchBar
//    }
//
//    private func setupTableView() {
//        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
//        
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
//        tableView.keyboardDismissMode = .onDrag
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return items.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
//        let collection = items[indexPath.row]
//        
//        cell.textLabel?.text = collection.name
//        
//        let isPresent = viewModel.isBook(book, in: collection)
//        
//        cell.accessoryType = isPresent ? .checkmark : .none
//        cell.tintColor = AppColors.systemBlue
//        
//        cell.textLabel?.textColor = AppColors.title
//        
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let collection = items[indexPath.row]
//        let result = viewModel.toggleBook(book, in: collection)
//        
//        switch result {
//        case .success:
//            Haptics.shared.play(.light)
//            
//            let isNowInCollection = viewModel.isBook(book, in: collection)
//            
//            if let cell = tableView.cellForRow(at: indexPath) {
//                cell.accessoryType = isNowInCollection ? .checkmark : .none
//            }
//            
//            let message = isNowInCollection ? "Added to \(collection.name ?? "Collection")" : "Removed from \(collection.name ?? "Collection")"
//            Toast.show(message: message, in: self.view)
//            
//        case .failure(let error):
//            Haptics.shared.notify(.error)
//            Toast.show(message: "Error: \(error.localizedDescription)", in: self.view)
//        }
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        filterContentForSearchText(searchText)
//    }
//    
//
//
//    func filterContentForSearchText(_ searchText: String?) {
//        guard let text = searchText, !text.isEmpty else {
//            self.items = self.allItems
//            self.tableView.reloadData()
//            return
//        }
//        
//        self.items = self.allItems.filter { collection in
//            let name = collection.name ?? ""
//            return name.range(of: text, options: [.caseInsensitive, .diacriticInsensitive]) != nil
//        }
//        self.tableView.reloadData()
//    }
//
//    @objc func didTapAddButton() {
//        let alertController = UIAlertController(title: "New Collection", message: "Enter a name for this collection.", preferredStyle: .alert)
//        alertController.addTextField { textField in
//            textField.placeholder = "Collection Name"
//            textField.delegate = self
//            textField.autocapitalizationType = .sentences
//        }
//        
//        let addAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
//            guard let self = self, let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
//            self.createNewCollection(name: text)
//        }
//        
//        alertController.addAction(addAction)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(alertController, animated: true)
//    }
//    
//    func createNewCollection(name: String) {
//        let result = viewModel.createCollection(as: name)
//        
//        switch result {
//        case .success(let newCollection):
//            switch viewModel.toggleBook(book, in: newCollection) {
//            case .success():
//                loadCollections()
//                Haptics.shared.play(.light)
//                Toast.show(message: "Collection created & book added!", in: self.view)
//            case .failure(let error):
////                Toast.show(message: "Failed to add book to collection", in: self.view)
//                print("Error: \(error)")
//            }
//
//            
//        case .failure(let error):
////            Toast.show(message: "Failed to create collection", in: self.view)
//            print("Error: \(error)")
//        }
//    }
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let currentString = (textField.text ?? "") as NSString
//        let newString = currentString.replacingCharacters(in: range, with: string)
//        return newString.count <= ContentLimits.collectionMaxNameLength
//    }
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        
//        if let text = searchBar.text, text.isEmpty {
//             searchBar.setShowsCancelButton(false, animated: true)
//        }
//    }
//    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(true, animated: true)
//    }
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.text = ""
//        searchBar.resignFirstResponder()
//        filterContentForSearchText("")
//        searchBar.setShowsCancelButton(false, animated: true)
////        tableView.reloadData()
//    }
//}
import UIKit
import CoreData

class AddToCollectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate {

    struct CollectionSection {
        let title: String
        var items: [BookCollection]
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchBar = UISearchBar()
    
    private var allItems: [BookCollection] = []
    
    private var sections: [CollectionSection] = []
    
    private let book: Book
    private let viewModel: AddToCollectionViewModel
    private let cellIdentifier = "CollectionSelectionCell"
    private var isOwned: Bool = false
    
    init(book: Book) {
        self.book = book
        self.viewModel = AddToCollectionViewModel()
        if let records = UserSession.shared.currentUser?.owned?.allObjects as? [UserBookRecord] {
            if records.contains(where: { $0.book == book }) {
                isOwned = true
            }
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Add to Collection"
        
        setupNavBar()
        setUpSearchBar()
        setupTableView()
        
        loadCollections()
    }
    
    private func loadCollections() {
        var fetchedCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
        
        if !isOwned {
            fetchedCollections.removeAll { $0.isDefault && $0.name == DefaultsName.finiahed }
        }
        
        fetchedCollections.sort { (first, second) -> Bool in
            let date1 = first.createdAt ?? Date.distantPast
            let date2 = second.createdAt ?? Date.distantPast
            
            if date1 != date2 {
                return date1 < date2
            }
            return (first.name ?? "") < (second.name ?? "")
        }
        
        self.allItems = fetchedCollections
        
        updateSections(with: self.allItems)
    }
    
    private func updateSections(with collections: [BookCollection]) {
        var newSections: [CollectionSection] = []
        
        let defaults = collections.filter { $0.isDefault }
        if !defaults.isEmpty {
            newSections.append(CollectionSection(title: "", items: defaults))
        }
        
        let userCreated = collections.filter { !$0.isDefault }
        if !userCreated.isEmpty {
            newSections.append(CollectionSection(title: "", items: userCreated))
        }
        
        self.sections = newSections
        self.tableView.reloadData()
    }

    private func setupNavBar() {
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItem = addButton
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    private func setUpSearchBar() {
        searchBar.placeholder = "Search Collections..."
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.keyboardDismissMode = .onDrag
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let collection = sections[indexPath.section].items[indexPath.row]
        
        cell.textLabel?.text = collection.name
        
        let isPresent = viewModel.isBook(book, in: collection)
        
        cell.accessoryType = isPresent ? .checkmark : .none
        cell.tintColor = AppColors.systemBlue
        cell.textLabel?.textColor = AppColors.title
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let collection = sections[indexPath.section].items[indexPath.row]
        let result = viewModel.toggleBook(book, in: collection)
        
        switch result {
        case .success:
            Haptics.shared.play(.light)
            
            let isNowInCollection = viewModel.isBook(book, in: collection)
            
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = isNowInCollection ? .checkmark : .none
            }
            
            let message = isNowInCollection ? "Added to \(collection.name ?? "Collection")" : "Removed from \(collection.name ?? "Collection")"
            Toast.show(message: message, in: self.view)
            
        case .failure(let error):
            Haptics.shared.notify(.error)
            Toast.show(message: "Error: \(error.localizedDescription)", in: self.view)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    func filterContentForSearchText(_ searchText: String?) {
        guard let text = searchText, !text.isEmpty else {
            updateSections(with: self.allItems)
            return
        }
        
        let filteredItems = self.allItems.filter { collection in
            let name = collection.name ?? ""
            return name.range(of: text, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
        
        updateSections(with: filteredItems)
    }
    
    @objc func didTapAddButton() {
        let alertController = UIAlertController(title: "New Collection", message: "Enter a name for this collection.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Collection Name"
            textField.delegate = self
            textField.autocapitalizationType = .sentences
        }
        
        let addAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self, let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            self.createNewCollection(name: text)
        }
        
        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    func createNewCollection(name: String) {
        let result = viewModel.createCollection(as: name)
        
        switch result {
        case .success(let newCollection):
            switch viewModel.toggleBook(book, in: newCollection) {
            case .success():
                loadCollections()
                Haptics.shared.play(.light)
                Toast.show(message: "Collection created & book added!", in: self.view)
            case .failure(let error):
                print("Error: \(error)")
            }

        case .failure(let error):
            print("Error: \(error)")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= ContentLimits.collectionMaxNameLength
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let text = searchBar.text, text.isEmpty {
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterContentForSearchText("")
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
