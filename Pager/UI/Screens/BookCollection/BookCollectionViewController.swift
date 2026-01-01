//
//  BookCollectionViewController.swift
//  Pager
//
//  Created by Pradheep G on 01/12/25.
//





import UIKit

class BookCollectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ListViewControllerDelegate {
    
    let tableView = UITableView()
    var items: [BookCollection] = []
    let itemCellIdentifier = "ItemCell"
    let viewModel = BookCollectionViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "My Custom List"
       
        setupEditButton()
        loadData()
        setupTableView()
    }
    
    private func loadData() {
        let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
        items = allCollections.sorted { (first, second) -> Bool in
            return first.isDefault && !second.isDefault
        }
        //        items = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
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
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: itemCellIdentifier)
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
            var cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: itemCellIdentifier)
            }
            cell?.textLabel?.text = items[indexPath.row].name
            cell?.textLabel?.numberOfLines = 3
            cell?.accessoryType = .disclosureIndicator
            cell?.detailTextLabel?.text = String(items[indexPath.row].books?.count ?? 0)
            cell?.detailTextLabel?.textColor = AppColors.subtitle
            return cell ?? UITableViewCell()
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
        guard let _ = UserSession.shared.currentUser else { return }
        
        let result = viewModel.addNewCollection(as: name)
        
        switch result {
        case .success(let newCollection):
            
            Toast.show(message: "Collection created successfully", in: self.view)
            
            let newRowIndex = self.items.count
            self.items.append(newCollection)
            
            let newIndexPath = IndexPath(row: newRowIndex, section: 0)
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [newIndexPath], with: .automatic)
            self.tableView.endUpdates()
            
            self.tableView.scrollToRow(at: newIndexPath, at: .middle, animated: true)
        case .failure(let error):
            
            if case .alreadyExists = error as? CollectionError {
                showNameExistsAlert(name: name)
            } else {
                print("Generic creation error: \(error)")
            }
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == items.count {
            return nil
        }
        
        guard !items[indexPath.row].isDefault else {
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
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.row >= items.count {
                return nil
            }
        guard !items[indexPath.row].isDefault else {
            return nil
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                self?.showEditAlert(at: indexPath)
            }
            
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self?.deleteItem(at: indexPath)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        let collectionToDelete = items[indexPath.row]
        
        let result = viewModel.deleteCollection(collectionToDelete)
        
        switch result {
        case .success:
            items.remove(at: indexPath.row)
            Toast.show(message: "Collection \(collectionToDelete.name ?? "") is deleted", in: self.view)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.endUpdates()
            
        case .failure(let error):
            print("Delete failed: \(error.localizedDescription)")
            
            let alert = UIAlertController(
                title: "Delete Failed",
                message: "Could not delete the collection. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
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
                let vc = EmptyMyBooksViewController(message: "Your collection is empty!", isButtonNeeded: true)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = BookGridViewController(categoryTitle: collection.name ?? "", books: books as! [Book], currentCollection: collection)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        loadData()
        tableView.reloadData()
    }
    

    func showEditAlert(at indexPath: IndexPath) {
        let collection = items[indexPath.row]
        
        let alertController = UIAlertController(
            title: "Rename Collection",
            message: "Enter a new name for this collection.",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Collection Name"
            textField.text = collection.name
            textField.autocapitalizationType = .sentences
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alertController.textFields?.first?.text,
                  !text.isEmpty else {
                return
            }
            
            let newName = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard newName != collection.name else {
                return
            }
            
            let nameExists = self.items.contains { item in
                return item.name?.caseInsensitiveCompare(newName) == .orderedSame
            }
            
            if nameExists {
                self.showNameExistsAlert(name: newName)
                return
            }
            
            self.updateCollectionName(at: indexPath, with: newName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

    func updateCollectionName(at indexPath: IndexPath, with newName: String) {
        let collection = items[indexPath.row]
        
        let result = viewModel.renameCollection(collection, to: newName)
        
        switch result {
        case .success:
            tableView.reloadRows(at: [indexPath], with: .automatic)
            Toast.show(message: "Collection Renamed", in: self.view)
        case .failure(let error):
            print("Failed to rename: \(error.localizedDescription)")
            
            let alert = UIAlertController(title: "Error", message: "Could not save the new name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("this is the viewdidapoear")
    }
}
