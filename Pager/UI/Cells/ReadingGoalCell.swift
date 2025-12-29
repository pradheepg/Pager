//
//  ReadingGoalFooterView.swift
//  Pager
//
//  Created by Pradheep G on 25/12/25.
//

import UIKit

class ReadingGoalCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ReadingGoalCell"

    var onAdjustGoalTapped: (() -> Void)?
    var onContinueReadingTapped: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reading Goal"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let adjustButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "gearshape")
        config.baseForegroundColor = .systemBlue
        
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let totalGoalLabel: UILabel = {
        let label = UILabel()
        label.text = "Today's Reading"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressBar: UIProgressView = {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.trackTintColor = .systemGray5
        bar.progressTintColor = .systemBlue
        bar.layer.cornerRadius = 4
        bar.clipsToBounds = true
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let continueButton: UIButton = {
        var config = UIButton.Configuration.filled()
        
        var titleContainer = AttributeContainer()
        titleContainer.font = .systemFont(ofSize: 18, weight: .bold)
        config.attributedTitle = AttributedString("Continue Reading!", attributes: titleContainer)
        
        var subtitleContainer = AttributeContainer()
        subtitleContainer.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleContainer.foregroundColor = UIColor.lightGray.withAlphaComponent(0.9)
        
        let longText = ""
        config.attributedSubtitle = AttributedString(longText, attributes: subtitleContainer)
        
        config.titleAlignment = .center
        config.titlePadding = 2
        config.subtitleLineBreakMode = .byTruncatingTail
        config.titleLineBreakMode = .byTruncatingTail
        
        config.baseBackgroundColor = AppColors.readingGoalButtonBGColoe
        config.cornerStyle = .capsule
        
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let completedIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iv.tintColor = .systemBlue
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
//        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        [titleLabel, adjustButton, completedIcon, totalGoalLabel, progressBar, progressLabel, continueButton].forEach {
            contentView.addSubview($0)
        }

        adjustButton.addTarget(self, action: #selector(didTapAdjust), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)

        NSLayoutConstraint.activate([
            adjustButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            adjustButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -0),
            adjustButton.heightAnchor.constraint(equalToConstant: 44),
            adjustButton.widthAnchor.constraint(equalToConstant: 44),

            titleLabel.centerYAnchor.constraint(equalTo: adjustButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: adjustButton.leadingAnchor, constant: -8),

            totalGoalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            totalGoalLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            
            completedIcon.centerYAnchor.constraint(equalTo: totalGoalLabel.centerYAnchor),
            completedIcon.leadingAnchor.constraint(equalTo: totalGoalLabel.trailingAnchor, constant: 8),
            completedIcon.widthAnchor.constraint(equalToConstant: 22),
            completedIcon.heightAnchor.constraint(equalToConstant: 22),
            
            
            progressBar.topAnchor.constraint(equalTo: totalGoalLabel.bottomAnchor, constant: 12),
            progressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            progressBar.heightAnchor.constraint(equalToConstant: 8),
            
            progressLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 12),
            progressLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            continueButton.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func didTapAdjust() {
        onAdjustGoalTapped?()
    }

    @objc private func didTapContinue() {
        onContinueReadingTapped?()
    }

//    func configure(currentMinutes: Int, goalMinutes: Int, bookName: String? = nil) {
////        var currentMinutes = 1
////        var goalMinutes = 1
//        let progress = goalMinutes > 0 ? Float(currentMinutes) / Float(goalMinutes) : 0
//        progressBar.setProgress(progress, animated: false)
//        
//        if currentMinutes >= goalMinutes && false {
//            progressLabel.text = "\(format(goalMinutes)) of \(format(goalMinutes))"
//            totalGoalLabel.text = "Goal Completed"
//            totalGoalLabel.largeContentImage = UIImage(systemName: "heat.waves.circle")
//            completedIcon.isHidden = false
//
//        } else {
//            progressLabel.text = "\(format(currentMinutes)) of \(format(goalMinutes))"
//        }
////        totalGoalLabel.text = "Total Goal: \(format(goalMinutes))"
//    }
    
    func configure(currentMinutes: Int, goalMinutes: Int, bookName: String? = nil) {
        let progress = goalMinutes > 0 ? Float(currentMinutes) / Float(goalMinutes) : 0
        progressBar.setProgress(progress, animated: false)
        
        let currentFormatted = format(currentMinutes)
        let goalFormatted = format(goalMinutes)
        print(goalMinutes)
        
        if currentMinutes >= goalMinutes && goalMinutes > 0 {
            totalGoalLabel.text = "Goal Completed!"
            progressLabel.text = "Total today: \(currentFormatted)"
        } else {
            progressLabel.text = "\(currentFormatted) of \(goalFormatted)"
            totalGoalLabel.text = "Today Reading"
//            totalGoalLabel.textColor = .label
        }
        
        var config = continueButton.configuration
        
        if let title = bookName, !title.isEmpty {
            var titleContainer = AttributeContainer()
            titleContainer.font = .systemFont(ofSize: 18, weight: .bold)
            titleContainer.foregroundColor = .white
            config?.attributedTitle = AttributedString("Continue Reading", attributes: titleContainer)

            var subtitleContainer = AttributeContainer()
            subtitleContainer.font = .systemFont(ofSize: 13, weight: .regular)
            subtitleContainer.foregroundColor = UIColor.lightGray.withAlphaComponent(0.9)
            
            config?.attributedSubtitle = AttributedString(title, attributes: subtitleContainer)
            config?.subtitleLineBreakMode = .byTruncatingTail
            config?.titleLineBreakMode = .byTruncatingTail
        } else {
            var titleContainer = AttributeContainer()
            titleContainer.font = .systemFont(ofSize: 18, weight: .bold)
            titleContainer.foregroundColor = .white
            config?.attributedTitle = AttributedString("Explore the Book Store", attributes: titleContainer)
            
            config?.attributedSubtitle = nil
        }
        
        continueButton.configuration = config
    }
    
    private func format(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 && m > 0 { return "\(h) hr \(m) min" }
        if h > 0 { return "\(h) hr" }
        return "\(m) min"
    }
}
class AdjustGoalViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var onGoalSelected: ((Int) -> Void)?
    var currentGoalMinutes: Int = 60
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Set Daily Goal"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let pickerView = UIPickerView()
    
    private let saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        var title = AttributedString("Update Goal")
        title.font = .systemFont(ofSize: 22, weight: .semibold)
        config.attributedTitle = title
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .capsule

        return UIButton(configuration: config)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupPicker()
        
        setPickerToMinutes(currentGoalMinutes)
    }
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, pickerView, saveButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pickerView.heightAnchor.constraint(equalToConstant: 200),
            
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupPicker() {
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    
    private func setPickerToMinutes(_ totalMinutes: Int) {
        let clamped = min(max(totalMinutes, 1), 1440)
        
        let hours = clamped / 60
        let minutes = clamped % 60
        
        pickerView.selectRow(hours, inComponent: 0, animated: false)
        pickerView.selectRow(minutes, inComponent: 1, animated: false)
    }
    
    private func getCurrentMinutes() -> Int {
        let hours = pickerView.selectedRow(inComponent: 0)
        let minutes = pickerView.selectedRow(inComponent: 1)
        return (hours * 60) + minutes
    }
    
    @objc private func saveTapped() {
        let totalMinutes = getCurrentMinutes()
        onGoalSelected?(totalMinutes)
        dismiss(animated: true)
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 25
        } else {
            return 60
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row) hr"
        } else {
            return "\(row) min"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let selectedHours = pickerView.selectedRow(inComponent: 0)
        let selectedMinutes = pickerView.selectedRow(inComponent: 1)
        
        if selectedHours == 24 && selectedMinutes > 0 {
            pickerView.selectRow(0, inComponent: 1, animated: true)
        }
        
        if selectedHours == 0 && selectedMinutes == 0 {
            pickerView.selectRow(1, inComponent: 1, animated: true)
        }
    }
}
