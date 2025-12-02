//
//  ReviewEditViewController.swift
//  Pager
//
//  Created by Pradheep G on 28/11/25.
//

import UIKit

class ReviewEditViewController: UIViewController, UITextViewDelegate {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let rootStackView: UIStackView = UIStackView()
    private let ratingStackView: UIStackView = UIStackView()
    private let starButtonStack: UIStackView = UIStackView()
    private let titleTextField: UITextField = UITextField()
    private let bodyTextView: UITextView = UITextView()
    private let placeholderText = "Enter whats in you mind"
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        title = "Write a review"
        setUpNavBarItem()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboards))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.addSubview(rootStackView)
        rootStackView.axis = .vertical
        rootStackView.distribution = .fill
        rootStackView.alignment = .center
        rootStackView.spacing = 10
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        setRatingStackView()
        let verticalSeparator1 = makeVerticalSeparator()
        rootStackView.addArrangedSubview(verticalSeparator1)
        setUpFeildsView()
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
//            rootStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func setUpFeildsView() {
        rootStackView.addArrangedSubview(titleTextField)
        titleTextField.placeholder = "Review Title"
        titleTextField.backgroundColor = AppColors.textFieldBackground
        titleTextField.textColor = AppColors.title
        titleTextField.layer.cornerRadius = 8
        titleTextField.layer.masksToBounds = true
        titleTextField.leftView = UIView(frame: CGRect(x:0, y:0, width:12, height:0))
        titleTextField.leftViewMode = .always
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        rootStackView.addArrangedSubview(bodyTextView)
        bodyTextView.backgroundColor = AppColors.textFieldBackground
        bodyTextView.textColor = UIColor.placeholderText
        bodyTextView.font = UIFont.systemFont(ofSize: 17)
        bodyTextView.layer.cornerRadius = 8
        bodyTextView.layer.masksToBounds = true
        bodyTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        bodyTextView.isScrollEnabled = false
        bodyTextView.text = placeholderText
        bodyTextView.delegate = self
        
        
        NSLayoutConstraint.activate([
            titleTextField.widthAnchor.constraint(equalTo: rootStackView.widthAnchor, multiplier: 0.9),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            bodyTextView.widthAnchor.constraint(equalTo: rootStackView.widthAnchor, multiplier: 0.9),
            bodyTextView.heightAnchor.constraint(equalToConstant: 200),
        ])
        
    }
    
    func setUpNavBarItem() {
        if #available(iOS 26.0, *) {
            let editBarButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"),
                                                style: .prominent,
                                                target: self,
                                                action: #selector(saveButonTapped)
            )
            editBarButton.tintColor = AppColors.background
            navigationItem.rightBarButtonItems = [editBarButton]
        } else {
            let editBarButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(saveButonTapped)
            )
            editBarButton.tintColor = AppColors.title
            navigationItem.rightBarButtonItems = [editBarButton]
        }
    }
    
    @objc func saveButonTapped() {
        
    }
    
    func setRatingStackView() {
        rootStackView.addArrangedSubview(ratingStackView)
        ratingStackView.axis = .vertical
        ratingStackView.distribution = .fill
        ratingStackView.alignment = .center
        ratingStackView.spacing = 10
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false

        
        ratingStackView.addArrangedSubview(starButtonStack)
        starButtonStack.axis = .horizontal
        starButtonStack.distribution = .fill
        starButtonStack.alignment = .center
        starButtonStack.spacing = 10
        starButtonStack.translatesAutoresizingMaskIntoConstraints = false
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        
        for i in 1...5 {
            let starButton: UIButton = UIButton()
            starButtonStack.addArrangedSubview(starButton)
            starButton.setImage(UIImage(systemName: "star", withConfiguration: largeConfig), for: .normal)
            starButton.setImage(UIImage(systemName: "star.fill", withConfiguration: largeConfig), for: .selected)
            starButton.tintColor = .systemYellow
            starButton.tag = i
            starButton.addTarget(self, action: #selector(starTapped(_: )), for: .touchUpInside)
            starButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                starButton.widthAnchor.constraint(equalToConstant: 35),
                starButton.heightAnchor.constraint(equalToConstant: 35),
            ])
        }
        
        let ratingLable: UILabel = UILabel()
        ratingStackView.addArrangedSubview(ratingLable)
        ratingLable.text = "Tap to Rate"
        ratingLable.textColor = AppColors.subtitle
        ratingLable.font = .systemFont(ofSize: 15, weight: .regular)
    }
    
    @objc func starTapped(_ sender: UIButton) {
        let selectedRating = sender.tag
        print("Star tapped: \(selectedRating)")
                for view in starButtonStack.arrangedSubviews {
            if let button = view as? UIButton {
                button.isSelected = button.tag <= selectedRating
            }
        }
    }
    
    func makeVerticalSeparator(color: UIColor = AppColors.subtitle,
                               inset: CGFloat = 0) -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false
        let lineHeight = 1 / UIScreen.main.scale
        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: lineHeight)
        ])
        return lineView
    }

    @objc func dismissKeyboards() {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
            // 3. Check the TEXT, not the color.
            // Also check color just in case user typed the exact placeholder text.
        if textView.text == placeholderText && textView.textColor == UIColor.placeholderText {
                textView.text = nil
            textView.textColor = AppColors.title
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                // 4. Use the constant here too
                textView.text = placeholderText
                textView.textColor = UIColor.placeholderText
            }
        }
}
