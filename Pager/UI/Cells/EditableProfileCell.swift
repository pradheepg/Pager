//
//  EditableProfileCell.swift
//  Pager
//
//  Created by Pradheep G on 09/12/25.
//
import UIKit

class EditableProfileCell: UITableViewCell, UITextViewDelegate {
    
    var onTextChange: ((String) -> Void)?
    var onResize: (() -> Void)?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    lazy var inputTextView: UITextView = {
            let tv = UITextView()
            tv.font = .systemFont(ofSize: 16)
            tv.textColor = .systemBlue
            tv.textAlignment = .right
            tv.isScrollEnabled = false
            tv.backgroundColor = .clear
            
            tv.textContainerInset = .zero
            tv.textContainer.lineFragmentPadding = 0
            
            tv.delegate = self
            return tv
        }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(inputTextView)
        
        selectionStyle = .none
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.widthAnchor.constraint(equalToConstant: 100),
            
            inputTextView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            inputTextView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            inputTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            inputTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            inputTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
    }

    
    func textViewDidChange(_ textView: UITextView) {
        onTextChange?(textView.text)
        onResize?()
    }
    func setEditingMode(_ isEditing: Bool) {
            inputTextView.isEditable = isEditing
            inputTextView.isUserInteractionEnabled = isEditing
            
            if isEditing {
                inputTextView.textColor = .systemBlue
            } else {
                inputTextView.textColor = .label
            }
        }
}
