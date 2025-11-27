//
//  LoginViewController.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let signupLabel = UILabel()
    private let viewModel = LoginViewModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupScrollContent()
        setupViews()
        setupConstraints()
        setupKeyboardObservers()
        setupTabGesture()
        bindViewModel()
    }
    
    private func setupTabGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupScrollContent() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    private func setupViews() {
        titleLabel.text = "Log In"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        titleLabel.textColor = AppColors.title
        
        subtitleLabel.text = "Log in to your existing account"
        subtitleLabel.font = UIFont.systemFont(ofSize: 18)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = AppColors.subtitle
        
        emailField.placeholder = "Type in your Email"
        emailField.backgroundColor = AppColors.textFieldBackground
        emailField.textColor = AppColors.title
        emailField.layer.cornerRadius = 8
        emailField.layer.masksToBounds = true
        emailField.leftView = UIView(frame: CGRect(x:0, y:0, width:12, height:0))
        emailField.leftViewMode = .always
        emailField.autocapitalizationType = .none
        emailField.keyboardType = .emailAddress
        emailField.addTarget(self, action: #selector(validateTextField), for: .editingChanged)
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = AppColors.buttonBorder.cgColor
        emailField.delegate = self
        
        passwordField.placeholder = "Type in your password"
        passwordField.backgroundColor = AppColors.textFieldBackground
        passwordField.textColor = AppColors.title
        passwordField.layer.cornerRadius = 8
        passwordField.layer.masksToBounds = true
        passwordField.isSecureTextEntry = true
        passwordField.leftView = UIView(frame: CGRect(x:0, y:0, width:12, height:0))
        passwordField.leftViewMode = .always
        passwordField.addTarget(self, action: #selector(validateTextField), for: .editingChanged)
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = AppColors.buttonBorder.cgColor
        passwordField.delegate = self
        
        loginButton.setTitle("Log In", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        loginButton.backgroundColor = AppColors.disableButton
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitleColor(AppColors.disableText, for: .disabled)
        loginButton.layer.cornerRadius = 8
        loginButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.isEnabled = false
        
        
        let signupText = "Are you a new user? "
        let signupAttributed = NSMutableAttributedString(string: signupText, attributes: [ .foregroundColor: AppColors.title])
        let linkPart = NSAttributedString(string: "Sign up now", attributes: [
            .foregroundColor: AppColors.button,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        signupAttributed.append(linkPart)
        signupLabel.attributedText = signupAttributed
        signupLabel.font = UIFont.systemFont(ofSize: 16)
        signupLabel.textAlignment = .center
        signupLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(signupTapped))
        signupLabel.addGestureRecognizer(tap)
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.setCustomSpacing(44, after: subtitleLabel)
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(passwordField)
        stackView.setCustomSpacing(32, after: passwordField)
        stackView.addArrangedSubview(loginButton)
        stackView.setCustomSpacing(40, after: loginButton)
//        stackView.addArrangedSubview(signupLabel)
        
        [emailField, passwordField, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 320).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
        }
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 80),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
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

    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardHeight = keyboardFrame.height
        let safeAreaBottom = view.safeAreaInsets.bottom
        
        let bottomInset = keyboardHeight - safeAreaBottom + 90
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        
        if let activeField = view.findFirstResponder() {
            let fieldFrame = activeField.convert(activeField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(fieldFrame, animated: true)
        }
    }
    
    
    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    @objc private func validateTextField() {
        let isValid = !(emailField.text?.isEmpty ?? true) &&
                      !(passwordField.text?.isEmpty ?? true)
        
        loginButton.isEnabled = isValid
        if isValid {
            loginButton.backgroundColor = AppColors.button
        } else {
            loginButton.backgroundColor = AppColors.disableButton
        }
    }
    
    @objc private func loginTapped() {
        print("Login tpped")
        if let email = emailField.text, let password = passwordField.text {
            viewModel.login(email: email, password: password)
        }
    }
    
    @objc private func signupTapped() {
        print("signup tapppedd")
        viewModel.signupTapped()

    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func bindViewModel() {
        viewModel.onLoginSuccess = { [weak self] user in
            if let sceneDelegate = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                (sceneDelegate.delegate as? SceneDelegate)?.setTabBarAsRoot()
            }
            print("Login Success\(user.email)")
        }

        viewModel.onLoginFailure = { [weak self] message in
            self?.showAlert(message)
        }

        viewModel.onNavigateToSignup = { [weak self] in
            print("Go to Signup page")
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = AppColors.buttonBorderEditing.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = AppColors.buttonBorder.cgColor
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension UIView {
    func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subview in subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}
