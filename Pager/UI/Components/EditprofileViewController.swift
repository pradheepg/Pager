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
        title = "Edit Profile"
        tableView.keyboardDismissMode = .interactive

        
        setUpTableView()
        setupTableHeader()
    }
    
    func setUpTableView() {
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
        
        let badgeView = UIView()
        badgeView.backgroundColor = .systemBlue
        badgeView.layer.cornerRadius = 16
        badgeView.layer.borderColor = UIColor.white.cgColor
        badgeView.layer.borderWidth = 2
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. CREATE THE PENCIL ICON
        let pencilIcon = UIImageView()
        pencilIcon.image = UIImage(systemName: "pencil")
        pencilIcon.tintColor = .white
        pencilIcon.contentMode = .scaleAspectFit
        pencilIcon.translatesAutoresizingMaskIntoConstraints = false
        
        // 4. ASSEMBLE HIERARCHY
        badgeView.addSubview(pencilIcon)      // Put pencil inside the small circle
        headerView.addSubview(badgeView)      // Put small circle on the header
        
        // 5. ADD GESTURE (So tapping the pencil also opens the gallery)
        // We add the gesture to the profileImageView usually, but you can add it to headerView or both.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImageView.addGestureRecognizer(tapGesture)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        badgeView.addGestureRecognizer(tapGesture2)
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? personalData.count : preferenceData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditableCell", for: indexPath) as? EditableProfileCell else {
            return UITableViewCell()
        }
        
        let isSectionZero = indexPath.section == 0
        let data = isSectionZero ? personalData[indexPath.row] : preferenceData[indexPath.row]
        
        cell.titleLabel.text = data.title
        cell.inputTextField.text = data.value
        
        cell.onTextChange = { [weak self] newText in
            if isSectionZero {
                self?.personalData[indexPath.row].value = newText
            } else {
                self?.preferenceData[indexPath.row].value = newText
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print(indexPath.section,indexPath.row)
    }
    
    @objc func didTapCancel() {
        //        let alert = UIAlertController(
        //            title: "Discard ",
        ////            message: "Are you sure you want to logout?",
        //            preferredStyle: .alert
        //        )
        //
        //        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        //
        //        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
        //            UserSession.shared.logout()
        //            let welcomeVC = WelcomeViewController()
        //            let nav = UINavigationController(rootViewController: welcomeVC)
        //            SceneDelegate.setRootViewController(nav)
        //        }
        //
        //        alert.addAction(cancelAction)
        //        alert.addAction(logoutAction)
        //
        //        present(alert, animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapDone() {
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
        
        // TODO: Call your UserSession.shared.updateUser(...) here
        navigationController?.popViewController(animated: true)
    }
    

    // Inside your Class
//    @objc private func didTapProfileImage() {
//        // 1. Configure the picker
//        var config = PHPickerConfiguration()
//        config.filter = .images // Only show images (no videos)
//        config.selectionLimit = 1 // User can only pick 1 image
//        
//        // 2. Create the picker
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = self // We will fix the error for this in Step 3
//        
//        // 3. Present it
//        present(picker, animated: true)
//    }
    
    @objc private func didTapProfileImage() {
        // 1. Create the Alert Controller
        // standard UIKit Action Sheet (slides from bottom)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 2. Add "Take Photo" Action
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.openCamera()
        })
        
        // 3. Add "Choose Photo" Action
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default) { [weak self] _ in
            self?.openGallery()
        })
        
        // 4. Add "Browse..." Action (Files App)
        if !isProfileImageNil {
            actionSheet.addAction(UIAlertAction(title: "Remove Photo", style: .destructive) { [weak self] _ in
                self?.removeImage()
            })
        }
        
        // 5. Add "Cancel" Action
        // The style .cancel automatically puts it at the bottom, separated from the others
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // 6. CRITICAL FOR IPAD: Prevent Crash
        // Action sheets on iPad must know where to "pop" from, or the app will crash.
        if let popover = actionSheet.popoverPresentationController {
            // Option A: Point to the profile image view
            // popover.sourceView = profileImageView
            
            // Option B: Point to the center of the screen (Generic fallback)
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // 7. Show it
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
