//
//  ProfileViewController.swift
//  Pager
//
//  Created by Pradheep G on 08/12/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.backgroundColor = .systemGray6
        
//        imageView.layer.borderWidth = 2
//        imageView.layer.borderColor = UIColor.systemBackground.cgColor
        
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 26, weight: .bold)
        
        label.textColor = .label
        
        label.textAlignment = .center
        
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        
        return label
    }()
    
    private let editButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        
        config.title = "Edit Profile"
        config.image = UIImage(systemName: "pencil")
        
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let themeStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    private let footerButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    private let themeLabel: UILabel = {
        let label = UILabel()
        label.text = "Appearance : "
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let themeSegmentalControl: UISegmentedControl = {
        let items = ["System", "Light", "Dark"]
        let sc = UISegmentedControl(items: items)
        
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let logOutButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        
        config.title = "Logout"
        config.image = UIImage(systemName: "iphone.and.arrow.right.outward")
        
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .systemRed
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let changePasswordButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        
        config.title = "ChangePassword"
        config.image = UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
        
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        config.cornerStyle = .capsule
//        config.baseBackgroundColor = .systemRed
//        config.baseForegroundColor = .systemRed
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Profile"
        view.backgroundColor = AppColors.background
        
        setUpMainStackView()
        setUpSubView()
        setUpThemeStack()
        setUpFooterStack()
    }
    
    func setUpFooterStack() {
        footerButtonStack.addArrangedSubview(changePasswordButton)
        footerButtonStack.addArrangedSubview(logOutButton)
        
        NSLayoutConstraint.activate([
            footerButtonStack.widthAnchor.constraint(equalTo:view.widthAnchor, multiplier: 0.9),
            changePasswordButton.widthAnchor.constraint(equalTo: footerButtonStack.widthAnchor, multiplier: 0.6),
//            logOutButton.widthAnchor.constraint(equalTo: footerButtonStack.widthAnchor, multiplier: 0.4)
        ])
    }
    
    
    func setUpThemeStack() {
        
//        themeStack.addArrangedSubview(themeLabel)
        themeStack.addArrangedSubview(themeSegmentalControl)
        
        themeSegmentalControl.addTarget(self, action: #selector(didChangeTheme(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            themeStack.widthAnchor.constraint(equalTo:view.widthAnchor, multiplier: 0.9),
//            themeSegmentalControl.widthAnchor.constraint(equalTo: themeStack.widthAnchor),
            themeSegmentalControl.heightAnchor.constraint(equalToConstant: 50),
        ])
        
    }
    
    func setUpSubView() {
        nameLabel.text = UserSession.shared.currentUser?.profileName
        profileImageView.image = getImage()
        editButton.addTarget(self, action: #selector(didTapEditProfile), for: .touchUpInside)
        changePasswordButton.addTarget(self, action: #selector(didTapChangePasswordButton), for: .touchUpInside)
        logOutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    func setUpMainStackView() {
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(profileImageView)
        mainStackView.addArrangedSubview(nameLabel)
        mainStackView.addArrangedSubview(editButton)
        mainStackView.addArrangedSubview(themeStack)
        mainStackView.addArrangedSubview(footerButtonStack)
        
        mainStackView.setCustomSpacing(20, after: profileImageView)
        mainStackView.setCustomSpacing(30, after: editButton)
        mainStackView.setCustomSpacing(40, after: themeStack)

        
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func didTapChangePasswordButton() {
        let vc = ChangePasswordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        print("Password change button tapped!! ")
    }
    
    @objc private func didTapLogoutButton() {
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
    
    @objc private func didChangeTheme(_ sender: UISegmentedControl) {
        let selectedStyle: UIUserInterfaceStyle
        
        switch sender.selectedSegmentIndex {
        case 0:
            selectedStyle = .unspecified
        case 1:
            selectedStyle = .light
        case 2:
            selectedStyle = .dark
        default:
            selectedStyle = .unspecified
        }

        if let windowScene = view.window?.windowScene {
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = selectedStyle
            }
        }
    }
    
    @objc private func didTapEditProfile() {
        let vc = EditprofileViewController()
        self.navigationController?.pushViewController(vc, animated: true)

        print("Edit Profile Tapped")
    }
    
    func getImage() -> UIImage? {
        guard let user = UserSession.shared.currentUser else {
            return UIImage(systemName: "person.circle.fill")
        }
        
        if let imageData = user.profileImage, let image = UIImage(data: imageData) {
            return image
        }
        
        let name = user.profileName ?? "?"
        let firstLetter = String(name.prefix(1)).uppercased()
        
        return UIImage.createImageWithLabel(text: firstLetter)
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


extension UIImage {
    static func createImageWithLabel(text: String) -> UIImage? {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let colors: [UIColor] = [.systemBlue, .systemRed, .systemGreen, .systemOrange, .systemPurple, .systemTeal, .systemIndigo]
            let randomColor = colors.randomElement() ?? .systemGray
            
            randomColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 50, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: rect, withAttributes: attributes)
        }
    }
}
