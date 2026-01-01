//
//  Untitled.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//
import UIKit

class WelcomeViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let existingUserButton = UIButton(type: .system)
    private let newUserButton = UIButton(type: .system)
    private let illustrationView = UIImageView()
    private let viewModel = WelcomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupScrollContent()
        setupViews()
        setupConstraints()
        bindViewModel()
        setupKeyboardObservers()
    }

    private func setupScrollContent() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupViews() {
        titleLabel.text = "Hello there!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textAlignment = .center

        subtitleLabel.text = "Ready to start reading?"
        subtitleLabel.font = UIFont.systemFont(ofSize: 18)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = AppColors.subtitle

        existingUserButton.setTitle("I am an existing user", for: .normal)
        existingUserButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        existingUserButton.setTitleColor(AppColors.buttonText, for: .normal)
        existingUserButton.backgroundColor = AppColors.button
        existingUserButton.layer.cornerRadius = 8

        newUserButton.setTitle("I am a new user", for: .normal)
        newUserButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        newUserButton.setTitleColor(AppColors.buttonText, for: .normal)
        newUserButton.backgroundColor = AppColors.button
        newUserButton.layer.cornerRadius = 8

        illustrationView.image = UIImage(named: "welcomeImage")
        illustrationView.contentMode = .scaleAspectFit
        illustrationView.tintColor = AppColors.illustrationTint
        illustrationView.alpha = 0.8

        existingUserButton.addTarget(self, action: #selector(existingUserTapped), for: .touchUpInside)
        newUserButton.addTarget(self, action: #selector(newUserTapped), for: .touchUpInside)

        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.distribution = .fillProportionally
        contentStackView.spacing = 10

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.setCustomSpacing(40, after: subtitleLabel)
        contentStackView.addArrangedSubview(existingUserButton)
        contentStackView.addArrangedSubview(newUserButton)
        contentStackView.setCustomSpacing(100, after: newUserButton)
        contentStackView.addArrangedSubview(illustrationView)

        [titleLabel, subtitleLabel, existingUserButton, newUserButton, illustrationView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 44),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 24),
            existingUserButton.widthAnchor.constraint(equalToConstant: 270),
            existingUserButton.heightAnchor.constraint(equalToConstant: 48),
            newUserButton.widthAnchor.constraint(equalToConstant: 270),
            newUserButton.heightAnchor.constraint(equalToConstant: 48),
            illustrationView.widthAnchor.constraint(lessThanOrEqualToConstant: 600),
            illustrationView.heightAnchor.constraint(equalToConstant: 250)
        ])

        contentView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 60),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let safeAreaBottom = view.safeAreaInsets.bottom
            let keyboardHeight = keyboardFrame.height - safeAreaBottom
            scrollView.contentInset.bottom = keyboardHeight + 20
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 20
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    @objc private func existingUserTapped() {
        viewModel.userTappedLogin()
    }

    @objc private func newUserTapped() {
        viewModel.userTappedSignUp()
    }

    private func bindViewModel() {
        viewModel.onOutput = { [weak self] output in
            switch output {
            case .goToLogin:
                self?.navigateToLogin()
            case .goToSignUp:
                self?.navigateToSignUp()
            }
        }
    }

    private func navigateToLogin() {
        let vc = LoginViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToSignUp() {
         let vc = SignUpViewController()
         navigationController?.pushViewController(vc, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
