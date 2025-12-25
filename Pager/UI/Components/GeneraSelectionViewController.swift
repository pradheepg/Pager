//
//  generaSelectionViewController.swift
//  Pager
//
//  Created by Pradheep G on 18/12/25.
//

import UIKit

class GeneraSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    private let tableView: UITableView = UITableView()
    private var selectedRows = Set<Int>()
    var genreString: String
    var OnDone: ((_ genreString: String) -> ())? = nil
    
    init(genreString: String) {
        self.genreString = genreString
        let rawGenres = genreString.components(separatedBy: ",")

        for rawGenre in rawGenres {
            let cleanedGenre = rawGenre.trimmingCharacters(in: .whitespacesAndNewlines)
            if let category = CategoryEnum(rawValue: cleanedGenre),
               let index = CategoryEnum.allCases.firstIndex(of: category) {
                selectedRows.insert(index)
            }
        }
        self.genreString = ""
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        setupNavBar()
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
        super.viewDidLoad()
        
        
    }
    private func setupNavBar() {
        let clearButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))
        clearButton.tintColor = .systemRed
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        
        navigationItem.leftBarButtonItem = clearButton
        navigationItem.rightBarButtonItem = doneButton
    }
    
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapDone() {
        for i in selectedRows {
            genreString += CategoryEnum.allCases[i].rawValue + ", "
        }
        OnDone?(genreString)
        dismiss(animated: true)
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoryEnum.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = CategoryEnum.allCases[indexPath.row].rawValue
        if selectedRows.contains(indexPath.row) {
                cell.accessoryType = .checkmark
//            cell.tintColor = AppColors.title
            } else {
                cell.accessoryType = .none
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedRows.contains(indexPath.row) {
            selectedRows.remove(indexPath.row)
        } else {
            selectedRows.insert(indexPath.row)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}
