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

class ChangePasswordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    let viewModel = ChangePasswordViewModel()

    var currentPassword = [
        PasswordOption(title: "Current", placeholder: "Required", value: ""),
    ]
    
    var newPassword = [
        PasswordOption(title: "New", placeholder: "Enter new password", value: ""),
        PasswordOption(title: "Verify", placeholder: "Re-enter new password", value: ""),
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
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return "Password must be at least 6 characters long"
        }
        return nil
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textColor = .systemRed
            footer.textLabel?.font = UIFont.systemFont(ofSize: 14)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditableCell", for: indexPath) as? ChangePasswordCell else {
            return UITableViewCell()
        }
        if indexPath.section == 0 {
            cell.inputTextField.tag = 0
            cell.inputTextField.returnKeyType = .next
            cell.inputTextField.delegate = self
        } else {
            let tag = indexPath.row + 1
            cell.inputTextField.tag = tag
            cell.inputTextField.delegate = self

            if indexPath.row == newPassword.count - 1 {
                cell.inputTextField.returnKeyType = .done
            } else {
                cell.inputTextField.returnKeyType = .next
            }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            let nextTag = textField.tag + 1
            
            if let nextResponder = view.viewWithTag(nextTag) {
                nextResponder.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
                didTapDone()
            }
            
            return true
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
        
        tableView.register(ChangePasswordCell.self, forCellReuseIdentifier: "EditableCell")
        tableView.separatorStyle = .none

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
        let currentInput = currentPassword[0].value
        let newInput = newPassword[0].value
        let confirmInput = newPassword[1].value

        guard !currentInput.isEmpty, !newInput.isEmpty, !confirmInput.isEmpty else {
            showAlert(title: "Missing Input", message: "Please fill in all password fields.")
            return
        }

        guard newInput.count >= 6 else {
            showAlert(title: "Weak Password", message: "New password must be at least 6 characters long.")
            return
        }

        guard newInput == confirmInput else {
            showAlert(title: "Password Mismatch", message: "The new password and confirmation do not match.")
            return
        }
        
        guard PasswordHashing.hashFuntion(password: currentInput) == UserSession.shared.currentUser?.password else {
            showAlert(title: "Incorrect Password", message: "The current password you entered is incorrect.")
            return
        }
//        self.resignFirstResponder()
        viewModel.changePassword(currentInput, newInput)
        showToast(title: "Success", message: "Password Changed!") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    @objc func didTapDonee() {
        
        guard PasswordHashing.hashFuntion(password: currentPassword[0].value) == UserSession.shared.currentUser?.password else {
            
            let alert = UIAlertController(
                title: "Incorrect Password",
                message: "The current password you entered is incorrect.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard !newPassword[0].value.isEmpty else //|| newPassword[0].value.count < 6 else
        {
            let alert = UIAlertController(
                title: "Missing Input",
                message: "The password fields cannot be empty. Please fill in both.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard newPassword[0].value == newPassword[1].value, !newPassword[0].value.isEmpty else
        {
            let alert = UIAlertController(
                title: "Password Mismatch",
                message: "The new password and confirm password do not match. Please try again.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        

        
        viewModel.changePassword(currentPassword[0].value, newPassword[0].value)
        
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
