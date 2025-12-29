//
//  ReviewEditViewController.swift
//  Pager
//
//  Created by Pradheep G on 28/11/25.
//

import UIKit

class EditReviewViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    

    private let placeholderText = "Enter what's on your mind..."
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.keyboardDismissMode = .interactive
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }()
    
    private let starButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Review Title"
        tf.backgroundColor = AppColors.gridViewSecondaryColor
        tf.textColor = AppColors.title
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        return tf
    }()
    
    private let bodyTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = AppColors.gridViewSecondaryColor
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.layer.cornerRadius = 8
        tv.layer.masksToBounds = true
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.backgroundColor = AppColors.gridViewSecondaryColor
        btn.layer.cornerRadius = 8
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let label = UILabel()
        label.text = "Remove Rating"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(label)
        
        let icon = UIImageView(image: UIImage(systemName: "trash"))
        icon.tintColor = .systemRed
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(icon)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: btn.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            icon.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -16),
            icon.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            icon.heightAnchor.constraint(equalToConstant: 20),
            icon.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        return btn
    }()
    
    private var viewModel: EditReviewViewModel
    
    init(book: Book) {
        self.viewModel = EditReviewViewModel(book: book)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        bodyTextView.delegate = self
        setupUI()
        setupNavBar()
        setupKeyboardObservers()
        populateExistingData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.backgroundColor = AppColors.gridViewBGColor
        title = "Write a review"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(rootStackView)
        
        setupRatingStars()
        
        rootStackView.addArrangedSubview(ratingStackView)
        rootStackView.addArrangedSubview(makeHorizontalSeparator())
        rootStackView.addArrangedSubview(titleTextField)
        rootStackView.addArrangedSubview(bodyTextView)
        
        rootStackView.addArrangedSubview(makeHorizontalSeparator(color: .clear))
        
        rootStackView.addArrangedSubview(deleteButton)
        
        bodyTextView.delegate = self
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rootStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            bodyTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150)
        ])
    }
    
    private func setupRatingStars() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        
        for i in 1...5 {
            let starButton = UIButton()
            starButton.setImage(UIImage(systemName: "star", withConfiguration: largeConfig), for: .normal)
            starButton.setImage(UIImage(systemName: "star.fill", withConfiguration: largeConfig), for: .selected)
            starButton.tintColor = AppColors.systemBlue
            starButton.tag = i
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starButton.translatesAutoresizingMaskIntoConstraints = false
            starButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
            starButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            starButtonStack.addArrangedSubview(starButton)
        }
        
        ratingStackView.addArrangedSubview(starButtonStack)
        
        let ratingLabel = UILabel()
        ratingLabel.text = "Tap to Rate"
        ratingLabel.textColor = AppColors.subtitle
        ratingLabel.font = .systemFont(ofSize: 15, weight: .regular)
        ratingStackView.addArrangedSubview(ratingLabel)
    }
    
    private func setupNavBar() {
        let editBarButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"),
                                          style: .done,
                                          target: self,
                                          action: #selector(saveButtonTapped))
        editBarButton.tintColor = AppColors.title
        navigationItem.rightBarButtonItem = editBarButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboards))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func populateExistingData() {
        bodyTextView.text = placeholderText
        bodyTextView.textColor = .placeholderText
        
        if let existingReview = viewModel.getCurrentUserReview() {
            let savedRating = Int(existingReview.rating)
            updateStarUI(rating: savedRating)
            
            titleTextField.text = existingReview.reviewTitle
            if ((existingReview.reviewText?.isEmpty) != nil) {
                bodyTextView.text = existingReview.reviewText
                bodyTextView.textColor = AppColors.title
            }
            
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
    }
    
    
    @objc func starTapped(_ sender: UIButton) {
        updateStarUI(rating: sender.tag)
    }
    
    func updateStarUI(rating: Int) {
        self.viewModel.currentRating = rating
        for view in starButtonStack.arrangedSubviews {
            if let button = view as? UIButton {
                button.isSelected = button.tag <= rating
            }
        }
    }
    
    @objc func saveButtonTapped() {
        let titleText = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var bodyText = bodyTextView.text ?? ""
        
        if bodyText == placeholderText || bodyTextView.textColor == .placeholderText {
            bodyText = ""
        }
        bodyText = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard viewModel.currentRating > 0 else {
            showAlert(title: "Rating Required", message: "Please tap a star to rate this book.")
            return
        }
        if !(titleText.count == 0 && bodyText.count == 0) {
            if titleText.count < ContentLimits.reviewMinTitleLength {
                showAlert(title: "Title too short", message: "Review title must be at least \(ContentLimits.reviewMinTitleLength) characters.")
                return
            }
            if titleText.count > ContentLimits.reviewMaxTitleLength {
                showAlert(title: "Title too long", message: "Please keep the title under \(ContentLimits.reviewMaxTitleLength) characters. You are currently at \(titleText.count).")
                        return
                    }
            if bodyText.count < ContentLimits.reviewMinBodyLength {
                showAlert(title: "Review too short", message: "Please write at least \(ContentLimits.reviewMinBodyLength) characters so others understand your opinion.")
                return
            }
            
            if bodyText.count > ContentLimits.reviewMaxBodyLength {
                showAlert(title: "Review too long", message: "Please keep the Review under \(ContentLimits.reviewMaxBodyLength) characters. You are currently at \(bodyText.count).")
                return
            }
        }
        
        let result = viewModel.submitReview(
            rating: viewModel.currentRating,
            title: titleText,
            text: bodyText
        )
        
        switch result {
        case .success():
            Toast.show(message: "Review saved", in: self.view)
            navigationController?.popViewController(animated: true)
        case .failure(let error):
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    @objc func deleteButtonTapped() {
        let alert = UIAlertController(title: "Delete Review", message: "Are you sure you want to remove your review? This cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.performDelete()
        }))
        
        present(alert, animated: true)
    }
    
    private func performDelete() {
        let result = viewModel.removeReview()
        switch result {
        case .success:
            self.navigationController?.popViewController(animated: true)
            Toast.show(message: "Review deleted", in: view)
        case .failure(let error):
            self.navigationController?.popViewController(animated: true)
            Toast.show(message: "Error in deleting review \(error.localizedDescription)", in: view)
        }
    }
    
    private func makeHorizontalSeparator(color: UIColor = AppColors.subtitle) -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false
        let lineHeight = 1 / UIScreen.main.scale
        lineView.heightAnchor.constraint(equalToConstant: lineHeight).isActive = true
        return lineView
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func dismissKeyboards() {
        view.endEditing(true)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if textField == titleTextField {
            print(updatedText.count )
            return  !(updatedText.count > ContentLimits.reviewMaxTitleLength)
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard textView == bodyTextView else { return true }

        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        return updatedText.count <= ContentLimits.reviewMaxBodyLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == titleTextField {
            bodyTextView.becomeFirstResponder()
        }
        return true
    }

}

extension EditReviewViewController {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = AppColors.title
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholderText
            textView.textColor = .placeholderText
        }
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        // Because Scrolling is disabled, the Intrinsic Content Size updates automatically
//        // We just need to tell the View to layout again if inside a stack
//        /*
//         Note: In modern UIStackViews with isScrollEnabled = false on the TextView,
//         resize happens automatically. If you notice jumpiness, you can uncomment the line below:
//         */
//        // UIView.animate(withDuration: 0.1) { self.view.layoutIfNeeded() }
//    }
}
