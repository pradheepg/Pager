//
//  ProfileViewController.swift
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

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let viewModel = ProfileViewModel()
    
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
//    let date = UserSession.shared.currentUser?.dob ?? Date()
//
//    let formatter = DateFormatter().dateFormat = "dd/MM/yyyy"
//
//    let dateString = formatter.string(from: date)
    var personalData = [
        ProfileOption(title: "Name", value: UserSession.shared.currentUser?.profileName ?? "Guest"),
        ProfileOption(title: "Email", value: UserSession.shared.currentUser?.email ?? "No Email"),
        ProfileOption(title: "Date of Brith", value: UserSession.shared.currentUser?.formattedDOB ?? "NA" )
    ]
    
    var preferenceData = [
        ProfileOption(title: "Fav Genre", value: UserSession.shared.currentUser?.favoriteGenres ?? "")
    ]
    
    var tempPersonalData: [ProfileOption] = []
    var tempPreferenceData: [ProfileOption] = []
    var tempImageData: UIImage? = nil
    var tempImageIsNil: Bool = true
    
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
        setupTabGesture()
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
        tableView.register(LogoutCell.self, forCellReuseIdentifier: LogoutCell.resueKey)
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
        
        let pencilIcon = UIImageView()
        pencilIcon.image = UIImage(systemName: "pencil")
        pencilIcon.tintColor = .white
        pencilIcon.contentMode = .scaleAspectFit
        pencilIcon.translatesAutoresizingMaskIntoConstraints = false
        
        badgeView.addSubview(pencilIcon)
        headerView.addSubview(badgeView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        badgeView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            badgeView.widthAnchor.constraint(equalToConstant: 32),
            badgeView.heightAnchor.constraint(equalToConstant: 32),
            
            badgeView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -5),
            badgeView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -5),
            
            pencilIcon.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            pencilIcon.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            pencilIcon.widthAnchor.constraint(equalToConstant: 16),
            pencilIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
        
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
            preferredStyle: .actionSheet
        )
        
        let keepEditingAction = UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil)
        
        let discardAction = UIAlertAction(title: "Discard Changes", style: .destructive) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.isEditingMode = false
            self.personalData = self.tempPersonalData
            self.preferenceData = self.tempPreferenceData
            self.profileImageView.image = self.tempImageData
            self.isProfileImageNil = self.tempImageIsNil
            
        }
        
        alert.addAction(discardAction)
        alert.addAction(keepEditingAction)
        
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
        case 2:
            return 1
        case 3:
            return 2
        default:
            return 0
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isEditingMode {
            return 2
        }
        return 4
    }
    
    private func setupTabGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppearanceSettingCell.reuseKey, for: indexPath) as? AppearanceSettingCell else {
                return UITableViewCell()
            }
            return cell
            
        } else if indexPath.section == 3 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
                return UITableViewCell()
            }
            cell.accessoryType = .disclosureIndicator
            if indexPath.row == 0{
                cell.textLabel?.text = "Change Password"
                cell.textLabel?.textColor = .systemBlue
            } else {
                cell.textLabel?.text = "Logout"
                cell.textLabel?.textColor = .systemRed
            }
            return cell
//            if indexPath.row == 0 {
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: ChangePasswordLogoutCell.reuseKey, for: indexPath) as? ChangePasswordLogoutCell else {
//                    return UITableViewCell()
//                }
//                cell.onChangePasswordTapped = { [weak self] in
//                    let vc = ChangePasswordViewController()
//                    self?.navigationController?.pushViewController(vc, animated: true)
//                }
//                
//                cell.onLogoutTapped = { [weak self] in
//                    self?.showLogoutAlert()
//                }
//                
//                return cell
//            } else {
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: LogoutCell.resueKey, for: indexPath) as? LogoutCell else {
//                    return UITableViewCell()
//                }
//                cell.onLogoutTapped = { [weak self] in
//                    self?.showLogoutAlert()
//                }
//                return cell
//            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditableCell", for: indexPath) as? EditableProfileCell else {
                return UITableViewCell()
            }
            
            let isSectionZero = indexPath.section == 0
            let data = isSectionZero ? personalData[indexPath.row] : preferenceData[indexPath.row]
            if !isSectionZero || indexPath.row == personalData.count-1 {
                cell.inputTextView.isEditable = false
                cell.inputTextView.isUserInteractionEnabled = false
                cell.setEditingMode(isEditingMode, onlyChangeColor: true)
                if !isSectionZero {
                    cell.accessoryType = .disclosureIndicator
                } else {
                    cell.accessoryType = .none
                }
            } else {
                cell.setEditingMode(isEditingMode)
                cell.inputTextView.returnKeyType = .done
                cell.accessoryType = .none

                
                if indexPath.row == 1 {
                    cell.inputTextView.keyboardType = .emailAddress
                    
                }
            }
            cell.titleLabel.text = data.title
            cell.inputTextView.text = data.value == "" ? "None" : data.value
            
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
            
            
            return cell
        }
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let myViewController = GeneraSelectionViewController(genreString: self.preferenceData[indexPath.row].value)
            myViewController.OnDone = {[weak self] genreString in
                guard let self = self else {
                    return
                }
                self.preferenceData[indexPath.row].value = genreString
                self.genreSeleted()//driver
                self.tableView.reloadData()
            }
            
            let navigationController = UINavigationController(rootViewController: myViewController)
            
            //                navigationController.modalPresentationStyle = .popover
            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = false
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            self.present(navigationController, animated: true, completion: nil)
        } else if indexPath.section == 0 && indexPath.row == (personalData.count - 1) && isEditingMode{
            let myViewController = DOBselectionViewController(currentDate: UserSession.shared.currentUser?.dob)
            myViewController.onDone = {[weak self] seletedDOB in
                guard let self = self else {
                    return
                }
                dobSelected(date: seletedDOB)//driver
                personalData[indexPath.row].value = UserSession.shared.currentUser?.formattedDOB ?? "None"
                tableView.reloadData()
            }
            
            let navigationController = UINavigationController(rootViewController: myViewController)
            
            //                navigationController.modalPresentationStyle = .popover
            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = false
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            self.present(navigationController, animated: true, completion: nil)
        } else if indexPath.section == 3 {
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.row == 0 {
                let vc = ChangePasswordViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showLogoutAlert()
            }
        }
    }
    
    func dobSelected(date: Date) {
        viewModel.saveUserDOB(date: date)
    }
    
    @objc func didTapCancel() {
        if isEditingMode {
            showDiscardChangesAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func genreSeleted() {
        let newName = personalData[0].value.trimmingCharacters(in: .whitespacesAndNewlines)
        let newEmail = personalData[1].value.trimmingCharacters(in: .whitespacesAndNewlines)
        let newGenre = preferenceData[0].value
        viewModel.saveUserChange(newName, newEmail, newGenre)
    }
    
//    @objc func didTapToggleEdit() {
//        if isEditingMode {
//            let newName = personalData[0].value.trimmingCharacters(in: .whitespacesAndNewlines)
//            let newEmail = personalData[1].value.trimmingCharacters(in: .whitespacesAndNewlines)
//            let newGenre = preferenceData[0].value
//            
//            if newName.isEmpty {
//                showAlert(message: "Name cannot be empty.")
//                return
//            }
//            
//            if newEmail.isEmpty {
//                showAlert(message: "Email cannot be empty.")
//                return
//            }
//            guard isValidEmail(newEmail) else {
//                showAlert(message: "Please enter a valid email address.")
//                return
//            }
//            viewModel.saveUserChange(newName, newEmail, newGenre)
//            viewModel.saveUserProfieImage(image: profileImageView.image)
////            if !isProfileImageNil && (isProfileImageNil != tempImageIsNil) {
////                print("Save user profile\(profileImageView.image)")
////
////                viewModel.saveUserProfieImage(image: profileImageView.image)
//
////                if let header = tableView.tableHeaderView {
////                    for subview in header.subviews {
////                        if let imgView = subview as? UIImageView {
////                            print("Save user profile")
////                            viewModel.saveUserProfieImage(image: imgView.image)
////                        }
////                    }
////                }
////            }
//        } else {
//            tempPersonalData = personalData
//            tempPreferenceData = preferenceData
//            tempImageData = profileImageView.image
//            tempImageIsNil = isProfileImageNil
//        }
//        
//        isEditingMode.toggle()
//        setUpNavBarItem()
//        
//    }
    
    @objc func didTapToggleEdit() {
        if isEditingMode {
            let newName = personalData[0].value.trimmingCharacters(in: .whitespacesAndNewlines)
            let newEmail = personalData[1].value.trimmingCharacters(in: .whitespacesAndNewlines)
            let newGenre = preferenceData[0].value
            
            if newName.count < ContentLimits.userMinNameLength ||
               newName.count > ContentLimits.userMaxNameLength {
                
                showAlert(message: "Name must be between \(ContentLimits.userMinNameLength) and \(ContentLimits.userMaxNameLength) characters.")
                return
            }
            
            guard isValidEmail(newEmail) else {
                showAlert(message: "Please enter a valid email address.")
                return
            }

            viewModel.saveUserChange(newName, newEmail, newGenre)
            
            if !isProfileImageNil && (isProfileImageNil != tempImageIsNil) || (profileImageView.image != tempImageData) {
                 viewModel.saveUserProfieImage(image: profileImageView.image)
            }
            
        } else {
            tempPersonalData = personalData
            tempPreferenceData = preferenceData
            tempImageData = profileImageView.image
            tempImageIsNil = isProfileImageNil
        }
        
        isEditingMode.toggle()
        setUpNavBarItem()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // 0 = Name, 1 = Email (based on your personalData array order)
        if textView.tag == 0 {
            return updatedText.count <= ContentLimits.userMaxNameLength
        } else if textView.tag == 1 {
            return updatedText.count <= ContentLimits.userMaxEmailLength
        }
        
        return true
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
            present(picker, animated: true)
        } else {
            print("Camera not available on Simulator")
        }
    }
    
    func removeImage() {
        isProfileImageNil = true
        profileImageView.image = getImage(true)
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
        if email.count < ContentLimits.userMinEmailLength ||
           email.count > ContentLimits.userMaxEmailLength {
            return false
        }
        let regex = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        return NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    func prefersLargeTitles(_ bool: Bool){
        if #available(iOS 16, *) {
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

extension ProfileViewController {
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
        profileImageView.image = image
        
        isProfileImageNil = false
        
    }
}
