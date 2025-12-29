//
//  SignUpViewController.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//
import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let nameField = UITextField()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let confirmPasswordField = UITextField()
    private let warningLabel = UILabel()
//    private let genreTextView = UITextView()
    private let signUpButton = UIButton(type: .system)
    private let loginPromptLabel = UILabel()
    private let loginLabel = UILabel()
    private let viewModel = SignUpViewModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupScrollContent()
        setupViews()
        setupConstraints()
        setupKeyboardObservers()
        bindViewModel()
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
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24
        
        titleLabel.text = "Sign Up"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = AppColors.title
        titleLabel.textAlignment = .center
        
        subtitleLabel.text = "Start your reading journey now"
        subtitleLabel.font = UIFont.systemFont(ofSize: 19)
        subtitleLabel.textColor = AppColors.subtitle
        subtitleLabel.textAlignment = .center

        nameField.placeholder = "Name\u{002A}"
        nameField.autocapitalizationType = .words
        nameField.returnKeyType = .next
        styleTextField(nameField)
        
        emailField.placeholder = "Email\u{002A}"
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.returnKeyType = .next
        styleTextField(emailField)
        
        passwordField.placeholder = "Password\u{002A}"
        passwordField.isSecureTextEntry = true
        passwordField.returnKeyType = .next
        styleTextField(passwordField)
        
        confirmPasswordField.placeholder = "Confirm Password\u{002A}"
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.returnKeyType = .done
        styleTextField(confirmPasswordField)
        
        warningLabel.text = "Password must be at least 6 characters long"
        warningLabel.font = UIFont.systemFont(ofSize: 12)
        warningLabel.textColor = .systemRed
        
//        genreTextView.backgroundColor = AppColors.textFieldBackground
//        genreTextView.textColor = AppColors.title
//        genreTextView.font = UIFont.systemFont(ofSize: 17)
//        genreTextView.layer.cornerRadius = 8
//        genreTextView.layer.masksToBounds = true
//        genreTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
//        genreTextView.isScrollEnabled = false
//        genreTextView.text = ""
//        genreTextView.delegate = self
//        genreTextView.layer.borderWidth = 1
//        genreTextView.layer.borderColor = AppColors.buttonBorder.cgColor

        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.backgroundColor = AppColors.disableButton
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.setTitleColor(AppColors.disableText, for: .disabled)
        signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        signUpButton.layer.cornerRadius = 8
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        signUpButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        signUpButton.isEnabled = false

        let loginText = "Already have an account? "
        let loginAttributed = NSMutableAttributedString(string: loginText, attributes: [ .foregroundColor: AppColors.title])
        let linkPart = NSAttributedString(string: "Log In", attributes: [
            .foregroundColor: AppColors.button,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        loginAttributed.append(linkPart)
        loginLabel.attributedText = loginAttributed
        loginLabel.font = UIFont.systemFont(ofSize: 16)
        loginLabel.textAlignment = .center
        loginLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(loginTapped))
        loginLabel.addGestureRecognizer(tap)
                
        [titleLabel, subtitleLabel, nameField, emailField, passwordField, confirmPasswordField, warningLabel, signUpButton].forEach {
            stackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            if $0 is UITextField || $0 is UIButton {
                $0.widthAnchor.constraint(equalToConstant: 320).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
            }
            if $0 is UITextView {
                $0.widthAnchor.constraint(equalToConstant: 320).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
            }
        }
        stackView.setCustomSpacing(4,  after: confirmPasswordField)
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
//        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        setupTabGesture()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 48),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            
            
            
//            genreLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 50),
        ])
    }
    
    private func styleTextField(_ field: UITextField) {
        field.backgroundColor = AppColors.textFieldBackground
        field.textColor = AppColors.title
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        field.leftView = UIView(frame: CGRect(x:0, y:0, width:12, height:0))
        field.leftViewMode = .always
        field.layer.borderWidth = 1
        field.layer.borderColor = AppColors.buttonBorder.cgColor
        field.delegate = self
        field.addTarget(self, action: #selector(validateTextField), for: .editingChanged)

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

//    @objc private func keyboardWillShow(notification: Notification) {
//        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
//            let safeAreaBottom = view.safeAreaInsets.bottom
//            let keyboardHeight = keyboardFrame.height - safeAreaBottom
//            scrollView.contentInset.bottom = keyboardHeight + 100
//            scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 100
//        }
//    }
    
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
//
//    @objc private func signUpTapped() {
//        guard let name = nameField.text, !name.isEmpty else {
//            showAlert("Name cannot be empty"); return
//        }
//        guard let email = emailField.text, isValidEmail(email) else {
//            showAlert("Enter a valid email address"); return
//        }
//        guard let password = passwordField.text, password.count >= 6 else {
//            showAlert("Password must be 6+ characters"); return
//        }
//        guard let confirmPassword = confirmPasswordField.text, confirmPassword == password else {
//            showAlert("Passwords do not match"); return
//        }
////        guard let genre = genreTextView.text, !genre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
////            showAlert("Please enter your favorite genre"); return
////        }
//        viewModel.signUp(name: name, email: email, password: password, confirmPassword: confirmPassword, genre: nil)
//    }
    
    @objc private func signUpTapped() {
        guard let name = nameField.text,
              name.count >= ContentLimits.userMinNameLength,
              name.count <= ContentLimits.userMaxNameLength else {
            showAlert("Name must be between \(ContentLimits.userMinNameLength) and \(ContentLimits.userMaxNameLength) characters.")
            return
        }
        
        guard let email = emailField.text, isValidEmail(email) else {
            showAlert("Please enter a valid email address.")
            return
        }
        
        guard let password = passwordField.text,
              password.count >= ContentLimits.passwordMinLength else {
            showAlert("Password must be at least \(ContentLimits.passwordMinLength) characters long.")
            return
        }
        
        guard let confirmPassword = confirmPasswordField.text, confirmPassword == password else {
            showAlert("Passwords do not match.")
            return
        }

        viewModel.signUp(name: name, email: email, password: password, confirmPassword: confirmPassword, genre: nil)
    }
    
    
    @objc private func validateTextField() {
        let isValid = !(emailField.text?.isEmpty ?? true) &&
        !(nameField.text?.isEmpty ?? true) &&
        !(passwordField.text?.isEmpty ?? true) &&
        !(confirmPasswordField.text?.isEmpty ?? true) //&&
//        !(genreTextView.text?.isEmpty ?? true)
        
        signUpButton.isEnabled = isValid
        if isValid {
            signUpButton.backgroundColor = AppColors.button
        } else {
            signUpButton.backgroundColor = AppColors.disableButton
        }
    }
    
    @objc private func loginTapped() {
        showAlert("Navigate to Login screen!")
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        return NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    private func setupTabGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = AppColors.buttonBorderEditing.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = AppColors.buttonBorder.cgColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = AppColors.buttonBorderEditing.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = AppColors.buttonBorder.cgColor
    }
    
    func textViewDidChange(_ textView: UITextView) {
        validateTextField()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if textField == nameField {
            return updatedText.count <=  ContentLimits.userMaxNameLength
        }
        
        if textField == emailField {
            return updatedText.count <= ContentLimits.userMaxEmailLength
        }
        
        return true
    }
    
    private func bindViewModel() {
        viewModel.onSignUpSuccess = { [weak self] user in
            if let sceneDelegate = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                (sceneDelegate.delegate as? SceneDelegate)?.setSampleDataAlertAsRoot()
            }
        }

        viewModel.onSignUpFailure = { [weak self] message in
            self?.showAlert(message)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        } else if textField == confirmPasswordField {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

