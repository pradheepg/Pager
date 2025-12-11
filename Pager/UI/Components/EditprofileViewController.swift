//
//  EditprofileViewController.swift
//  Pager
//
//  Created by Pradheep G on 08/12/25.
//
import UIKit
import PhotosUI

struct ProfileOption {
    let title: String
    var value: String
}

class EditprofileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let badgeView = UIView()

    var isEditingMode: Bool = false{
        didSet {
            badgeView.isHidden = !isEditingMode
            setUpNavBarItem()
            tableView.reloadData()
        }
    }
    let profileImageView = UIImageView()
    var isProfileImageNil: Bool = true
    var personalData = [
        ProfileOption(title: "Name", value: UserSession.shared.currentUser?.profileName ?? "Guest"),
        ProfileOption(title: "Email", value: UserSession.shared.currentUser?.email ?? "No Email")
    ]
    
    var preferenceData = [
        ProfileOption(title: "Fav Genre", value: UserSession.shared.currentUser?.favoriteGenres ?? "Fiction")
    ]
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .systemGroupedBackground
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        title = "My Profile"
        tableView.keyboardDismissMode = .interactive
        
        setUpNavBarItem()
        setUpTableView()
        setupTableHeader()
    }
    
    func setUpNavBarItem() {
            let rightSystemItem: UIBarButtonItem.SystemItem = isEditingMode ? .done : .edit
            let rightButton = UIBarButtonItem(barButtonSystemItem: rightSystemItem, target: self, action: #selector(didTapToggleEdit))
            navigationItem.rightBarButtonItem = rightButton
            
            if isEditingMode {
                let xImage = UIImage(systemName: "xmark")
                let leftButton = UIBarButtonItem(image: xImage, style: .plain, target: self, action: #selector(didTapCancel))
                leftButton.tintColor = .label
                navigationItem.leftBarButtonItem = leftButton
                
                navigationItem.hidesBackButton = true
            } else {
                navigationItem.leftBarButtonItem = nil
                navigationItem.hidesBackButton = false
            }
        }
    
    func setUpTableView() {
        
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.frame = view.bounds
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(EditableProfileCell.self, forCellReuseIdentifier: "EditableCell")
        tableView.register(AppearanceSettingCell.self, forCellReuseIdentifier: AppearanceSettingCell.reuseKey)
        tableView.register(ChangePasswordLogoutCell.self, forCellReuseIdentifier: ChangePasswordLogoutCell.reuseKey)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    func setupTableHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 200))
        
        profileImageView.image = getImage()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 60
        //        profileImageView.layer.borderWidth = 2
        //        profileImageView.layer.borderColor = UIColor.systemGroupedBackground.cgColor
        profileImageView.isUserInteractionEnabled = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(profileImageView)
        
        badgeView.backgroundColor = .systemBlue
        badgeView.layer.cornerRadius = 16
        badgeView.layer.borderColor = UIColor.white.cgColor
        badgeView.layer.borderWidth = 2
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.isHidden = true
        
        // 3. CREATE THE PENCIL ICON
        let pencilIcon = UIImageView()
        pencilIcon.image = UIImage(systemName: "pencil")
        pencilIcon.tintColor = .white
        pencilIcon.contentMode = .scaleAspectFit
        pencilIcon.translatesAutoresizingMaskIntoConstraints = false
        
        // 4. ASSEMBLE HIERARCHY
        badgeView.addSubview(pencilIcon)
        headerView.addSubview(badgeView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        badgeView.addGestureRecognizer(tapGesture)
        
        // 6. LAYOUT CONSTRAINTS
        NSLayoutConstraint.activate([
            // A. Profile Image Center
            profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // B. Badge Size (The small circle)
            badgeView.widthAnchor.constraint(equalToConstant: 32),
            badgeView.heightAnchor.constraint(equalToConstant: 32),
            
            // C. Badge Position (Bottom-Right of profile image)
            badgeView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -5),
            badgeView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -5),
            
            // D. Pencil Icon Position (Centered inside the badge)
            pencilIcon.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            pencilIcon.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            pencilIcon.widthAnchor.constraint(equalToConstant: 16),
            pencilIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        // Assign the header to the table
        tableView.tableHeaderView = headerView
    }
    
    func setupTableHeaderr() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 200))
        
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 60
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = getImage()
        profileImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImageView.addGestureRecognizer(tapGesture)
        
        headerView.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func showDiscardChangesAlert() {
        let alert = UIAlertController(
            title: "Unsaved Changes",
            message: "You have unsaved changes. Are you sure you want to discard them?",
            preferredStyle: .actionSheet // or .alert
        )
        
        // Action: Keep Editing (Do nothing)
        let keepEditingAction = UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil)
        
        let discardAction = UIAlertAction(title: "Discard Changes", style: .destructive) { [weak self] _ in
            self?.isEditingMode = false
            
            // 2. Reload table to revert visual fields to labels
            
            // Note: To truly revert the *data* (text), you would need to
            // save a copy of 'personalData' before editing starts and restore it here.
        }
        
        alert.addAction(discardAction)
        alert.addAction(keepEditingAction)
        
        // iPad Crash Fix
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.leftBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return personalData.count
        case 1:
            return preferenceData.count
        case 2,3:
            return 1
        default:
            return 0
        }
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppearanceSettingCell.reuseKey, for: indexPath) as? AppearanceSettingCell else {
                return UITableViewCell()
            }
            return cell
            
        } else if indexPath.section == 3 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChangePasswordLogoutCell.reuseKey, for: indexPath) as? ChangePasswordLogoutCell else {
                return UITableViewCell()
            }
            
            cell.onChangePasswordTapped = { [weak self] in
                // NAVIGATE HERE
                let vc = ChangePasswordViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
            cell.onLogoutTapped = { [weak self] in
                // SHOW ALERT HERE
                self?.showLogoutAlert()
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditableCell", for: indexPath) as? EditableProfileCell else {
                return UITableViewCell()
            }
            
            let isSectionZero = indexPath.section == 0
            let data = isSectionZero ? personalData[indexPath.row] : preferenceData[indexPath.row]
            
            cell.titleLabel.text = data.title
            cell.inputTextView.text = data.value
            
            cell.onTextChange = { [weak self] newText in
                if isSectionZero {
                    self?.personalData[indexPath.row].value = newText
                } else {
                    self?.preferenceData[indexPath.row].value = newText
                }
            }
            cell.onResize = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            
            cell.setEditingMode(isEditingMode)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print(indexPath.section,indexPath.row)
    }

        @objc func didTapCancel() {
            if isEditingMode {
                showDiscardChangesAlert()
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    
    
    @objc func didTapToggleEdit() {
        if isEditingMode {
            let newName = personalData[0].value.trimmingCharacters(in: .whitespacesAndNewlines)
            let newEmail = personalData[1].value.trimmingCharacters(in: .whitespacesAndNewlines)
            let newGenre = preferenceData[0].value
            
            if newName.isEmpty {
                showAlert(message: "Name cannot be empty.")
                return
            }
            
            if newEmail.isEmpty {
                showAlert(message: "Email cannot be empty.")
                return
            }
            guard isValidEmail(newEmail) else {
                showAlert(message: "Please enter a valid email address.")
                return
            }
            print("Saving: \(newName), \(newEmail), \(newGenre)")
        }
        isEditingMode.toggle()
        
        setUpNavBarItem()
//        tableView.reloadData()
        
        // TODO: Call your UserSession.shared.updateUser(...) here
        //        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapProfileImage() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.openCamera()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default) { [weak self] _ in
            self?.openGallery()
        })
        
        if !isProfileImageNil {
            actionSheet.addAction(UIAlertAction(title: "Remove Photo", style: .destructive) { [weak self] _ in
                self?.removeImage()
            })
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(actionSheet, animated: true)
    }
    
    func openGallery() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            UserSession.shared.logout()
            let welcomeVC = WelcomeViewController()
            let nav = UINavigationController(rootViewController: welcomeVC)
            SceneDelegate.setRootViewController(nav)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            // Note: You need to add 'UINavigationControllerDelegate' conformance to your class
            present(picker, animated: true)
        } else {
            print("Camera not available on Simulator")
        }
    }
    
    func removeImage() {
        // Requires UIDocumentPickerViewController
        isProfileImageNil = true
        profileImageView.image = getImage(true)
        print("Open Files App Logic")
    }
    
    func getImage(_ isStatic: Bool = false) -> UIImage? {
        guard let user = UserSession.shared.currentUser else {
            return UIImage(systemName: "person.circle.fill")
        }
        
        if let imageData = user.profileImage, let image = UIImage(data: imageData), !isStatic {
            isProfileImageNil = false
            return image
        }
        
        isProfileImageNil = true
        let name = user.profileName ?? "?"
        let firstLetter = String(name.prefix(1)).uppercased()
        
        return UIImage.createImageWithLabel(text: firstLetter)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        return NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: email)
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
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension EditprofileViewController {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                
                DispatchQueue.main.async {
                    if let selectedImage = image as? UIImage {
                        self?.updateProfileImage(selectedImage)
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            
            updateProfileImage(image)
        }
    }
    
    private func updateProfileImage(_ image: UIImage) {
        if let header = tableView.tableHeaderView {
            for subview in header.subviews {
                if let imgView = subview as? UIImageView {
                    imgView.image = image
                    break
                }
            }
        }
        
        isProfileImageNil = false
        
        // TODO: Save 'image' to your backend or UserSession here
    }
}
