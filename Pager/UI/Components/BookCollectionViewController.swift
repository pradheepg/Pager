////
////  BookCollectionViewController.swift
////  Pager
////
////  Created by Pradheep G on 01/12/25.
////
//
//import UIKit
//
//class BookCollectionViewController: UIViewController, UITableViewDelegate {
//
//    private let booksTableView: UITableView = UITableView()
//    private let collections: [Collection] = []
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setUpTableView()
//    }
//    
//    func setUpTableView() {
//        
//    }
////    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return collections.count + 1
////    }
////    
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        
////    }
//    
//    
//}
//




import UIKit

class BookCollectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ListViewControllerDelegate {
    
    let tableView = UITableView()
    var items: [BookCollection] = []//["First Item", "Second Item", "Third Item"]
    let itemCellIdentifier = "ItemCell"
        
    lazy var collectionRepo: CollectionRepository = CollectionRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "My Custom List"
       
        setupEditButton()
        loadData()
        setupTableView()
    }
    
    private func loadData() {
        items = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
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
        
        tableView.register(AddButtonCell.self, forCellReuseIdentifier: AddButtonCell.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: itemCellIdentifier)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == items.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddButtonCell.reuseIdentifier, for: indexPath) as! AddButtonCell
            
            cell.delegate = self
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath)
            cell.textLabel?.text = items[indexPath.row].name
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    func didTapAddButton() {
        showAddItemAlert()
    }
        
    func showAddItemAlert() {
        let alertController = UIAlertController(
            title: "Add New Collection",
            message: "Enter the name for the new Collection.",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Collection name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alertController.textFields?.first?.text,
                  !text.isEmpty else {
                return
            }
            
            self.addNewItem(name: text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func addNewItem(name: String) {
        guard let currentUser = UserSession.shared.currentUser else {
            return
        }
        
        let newRowIndex = items.count

        let result = collectionRepo.createCollection(name: name, description: nil, owner: currentUser)
        switch result {
        case .success(let newCollection):
            items.append(newCollection)
        case .failure(let error):
            switch error {
            case .alreadyExists:
                showNameExistsAlert(name:name)
                return
            default:
                return
            }
        }

        let newIndexPath = IndexPath(row: newRowIndex, section: 0)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        tableView.endUpdates()
        
        tableView.scrollToRow(at: newIndexPath, at: .middle, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.row == items.count {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            self.deleteItem(at: indexPath)
            
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func showNameExistsAlert(name: String) {
        let alertController = UIAlertController(
            title: "Collection Already Exists!",
            message: "The Collection '\(name)' is already in your list. Please enter a different collection name.",
            preferredStyle: .alert
        )
        
        let dismissAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        collectionRepo.deleteCollection(items[indexPath.row])
        items.remove(at: indexPath.row)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .left) // Use .left or .fade for animation
        tableView.endUpdates()
    }
    private func setupEditButton() {
        let editButton = self.editButtonItem
        navigationItem.rightBarButtonItem = editButton
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < items.count {
            let collection = items[indexPath.row]
            handleCollectionTap(for: collection)
        }
    }

    private func handleCollectionTap(for collection: BookCollection) {        
        if let books = collection.books?.allObjects {
            if books.isEmpty {
                let detailVC = EmptyMyBooksViewController(message: "Your collection is empty!", isButtonNeeded: true)
                navigationController?.pushViewController(detailVC, animated: true)
            } else {
                let detailVC = BookGridViewController(categoryTitle: collection.name ?? "", books: books as! [Book])
                navigationController?.pushViewController(detailVC, animated: true)
            }
        } else {
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}
