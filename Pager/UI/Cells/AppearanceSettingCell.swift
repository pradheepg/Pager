//
//  Apper.swift
//  Pager
//
//  Created by Pradheep G on 10/12/25.
//

import UIKit
class AppearanceSettingCell: UITableViewCell {
    

    public static let reuseKey = "AppearanceSettingCell"
    private let themeSegmentalControl: UISegmentedControl = {
        let items = ["System", "Light", "Dark"]
        let sc = UISegmentedControl(items: items)
        let savedIndex = UserDefaults.standard.integer(forKey: "selectedThemeIndex")
                sc.selectedSegmentIndex = savedIndex
        return sc
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.text = "Appearance"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        themeSegmentalControl.addTarget(self, action: #selector(didChangeTheme(_:)), for: .valueChanged)

        contentView.addSubview(titleLabel)
        contentView.addSubview(themeSegmentalControl)
        
        selectionStyle = .none
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        themeSegmentalControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
//            titleLabel.topAnc₹hor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 100),
            
            themeSegmentalControl.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            themeSegmentalControl.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            themeSegmentalControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            themeSegmentalControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            themeSegmentalControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
    }
    @objc private func didChangeTheme(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "selectedThemeIndex")
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

        if let windowScene = self.window?.windowScene {
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = selectedStyle
            }
        }
    }
}

