//
//  AddButtonCell.swift
//  Pager
//
//  Created by Pradheep G on 01/12/25.
//

import UIKit

import UIKit

class AddButtonCell: UITableViewCell {
    static let reuseIdentifier = "AddButtonCell"
    weak var delegate: ListViewControllerDelegate?
    
    let addButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addButton.setImage(UIImage(systemName: "plus.app"), for: .normal)
        addButton.setTitle(" Add New Item", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        contentView.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            addButton.topAnchor.constraint(equalTo: contentView.topAnchor),
//                addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func addButtonTapped() {
        delegate?.didTapAddButton()
    }
}

protocol ListViewControllerDelegate: AnyObject {
    func didTapAddButton()
}
