//
//  ChangePasswordViewController.swift
//  Pager
//
//  Created by Pradheep G on 09/12/25.
//

import UIKit
struct PasswordOption {
    let title: String
    var placeholder: String
    var value: String
}

class ChangePasswordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var currentPassword = [
        PasswordOption(title: "Current", placeholder: "Required", value: ""),
    ]
    
    var newPassword = [
        PasswordOption(title: "New", placeholder: "Enter password", value: ""),
        PasswordOption(title: "Verify", placeholder: "Re-enter password", value: "")
    ]
    
    var currentPasswordString: String = ""
    var newPasswordString: String = ""
    var verifyPasswordString: String = ""
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .systemGroupedBackground
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Change password"
        view.backgroundColor = AppColors.background
        
        setUpTableView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return currentPassword.count
        } else {
            return newPassword.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditableCell", for: indexPath) as? EditableProfileCell else {
            return UITableViewCell()
        }
        let isSectionZero = indexPath.section == 0
        let data = isSectionZero ? currentPassword[indexPath.row] : newPassword[indexPath.row]
        
        cell.titleLabel.text = data.title
        cell.inputTextField.placeholder = data.placeholder
        cell.inputTextField.text = data.value
        cell.inputTextField.isSecureTextEntry = true

        
        cell.onTextChange = { [weak self] newText in
            if isSectionZero {
                self?.currentPassword[indexPath.row].value = newText
            } else {
                self?.newPassword[indexPath.row].value = newText
            }
        }
        
        return cell
    }
    
    
    private func setUpTableView() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        doneButton.tintColor = AppColors.background
        navigationItem.rightBarButtonItem = doneButton
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.frame = view.bounds
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(EditableProfileCell.self, forCellReuseIdentifier: "EditableCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    @objc func didTapCancel() {
        navigationController?.popViewController(animated: true)

    }
    
    @objc func didTapDone() {
        print(currentPassword[0].value,newPassword[0].value,newPassword[1].value)
        navigationController?.popViewController(animated: true)

    }
    
    func prefersLargeTitles(_ bool: Bool){
        if #available(iOS 17.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = bool
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prefersLargeTitles(false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        prefersLargeTitles(true)
    }
    
}
