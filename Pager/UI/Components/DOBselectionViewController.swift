//
//  DOBselectionViewController.swift
//  Pager
//
//  Created by Pradheep G on 22/12/25.
//

import UIKit

class DOBselectionViewController: UIViewController {
    
    private let datePicker: UIDatePicker = UIDatePicker()
    
    var onDone: ((_ date: Date) -> ())? = nil
    
    init(currentDate: Date? = nil) {
        super.init(nibName: nil, bundle: nil)
        if let date = currentDate {
            datePicker.date = date
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavBar()
        setupDatePicker()
    }
    
    private func setupNavBar() {
        let clearButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))
        clearButton.tintColor = .systemRed
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        
        navigationItem.leftBarButtonItem = clearButton
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.title = "Select Date"
    }
    
    private func setupDatePicker() {
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.datePickerMode = .date
        
        datePicker.preferredDatePickerStyle = .wheels
        
        datePicker.maximumDate = Date()
        
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            datePicker.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapDone() {
        onDone?(datePicker.date)
        dismiss(animated: true)
    }
}
