//
//  ThemeSettingViewController.swift
//  Pager
//
//  Created by Pradheep G on 06/01/26.
//

import UIKit

enum ThemeEnum: String, CaseIterable {
    case light
    case sepia
    case soft
    case midnight
    case dark
    
    var backgroundColor: UIColor {
        switch self {
        case .light:
            return .white
        case .sepia:
            return UIColor(red: 0.96, green: 0.93, blue: 0.88, alpha: 1.0)
        case .soft:
            return UIColor(red: 0.99, green: 0.97, blue: 0.82, alpha: 1.0)
        case .midnight:
            return UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        case .dark:
            return UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        }
    }
    
    var foregroundColor: UIColor {
        switch self {
        case .light:
            return .black
        case .sepia:
            return UIColor(red: 0.36, green: 0.25, blue: 0.20, alpha: 1.0)
        case .soft:
            return UIColor(red: 0.30, green: 0.20, blue: 0.15, alpha: 1.0)
        case .midnight:
            return UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1.0)
        case .dark:
            return UIColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 1.0)
        }
    }
    
    var index: Int {
        switch self {
        case .light:
            return 0
        case .sepia:
            return 1
        case .soft:
            return 2
        case .midnight:
            return 3
        case .dark:
            return 4
        }
    }
    
    var colors: (bg: UIColor, text: UIColor) {
        return (backgroundColor, foregroundColor)
    }
    
    static func from(index: Int) -> ThemeEnum {
        if index >= 0 && index < ThemeEnum.allCases.count {
            return ThemeEnum.allCases[index]
        }
        return .light
    }
}

protocol ThemeSettingsViewControllerDelegate: AnyObject {
    func didChangeTheme(to theme: ThemeEnum)
    func didSetSettingViewTheme(isDark: Bool)
    //    func didChangeBrightness(to value: CGFloat)
}

class ThemeSettingViewController: UIViewController {
    
    var settingPanalThemeIsDark: Bool = false
    
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let themeStack: UIStackView = {
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
//        stack.backgroundColor = AppColors.gridViewSecondaryColor
        return stack
    }()
    
    private let themeTitle: UILabel = {
        let label = UILabel()
        label.text = "Theme"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let themeButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let brightnessStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        stack.backgroundColor = AppColors.gridViewSecondaryColor
        
        return stack
    }()
    
    private let brightnessTitle: UILabel = {
        let label = UILabel()
        label.text = "Brightness"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let brightnessSliderStack: UIStackView = {
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.backgroundColor = AppColors.gridViewSecondaryColor
        
        return stack
    }()
    
    private let brightnessSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.3
        slider.tintColor = AppColors.systemBlue
        
        //        slider.minimumValueImage = UIImage(systemName: "minus")
        //        slider.maximumValueImage = UIImage(systemName: "plus")
        return slider
    }()
    
    private let decreaseButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(systemName: "sun.min")
        btn.setImage(image, for: .normal)
        btn.setTitle("-", for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft

        btn.tintColor = .secondaryLabel
        return btn
    }()
    
    private let increaseButton: UIButton = {
        let btn = UIButton(type: .system)
        
        let image = UIImage(systemName: "sun.max.fill")
        btn.setTitle("+", for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.setImage(image, for: .normal)
        btn.tintColor = .secondaryLabel
        return btn
    }()
    
    weak var delegate: ThemeSettingsViewControllerDelegate?
    var currentFont: FontEnum = .libreBaskerville {
        didSet {
            refreshThemeButtonFonts()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainStack()
        setUpThemeStack()
        setUpBrightnessStack()
    }
    
    func configure(theme: ThemeEnum, currentFont: FontEnum) {
        updateSelectedThemeButton(selectedIndex: theme.index)
        if theme.index == 4 || theme.index == 3 {
            settingPanalThemeIsDark = true
        } else {
            settingPanalThemeIsDark = false
        }
        self.currentFont = currentFont
    }
    
    private func setUpMainStack() {
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
        ])
    }
    
    private func setUpThemeStack() {
        setUpThemeButtonStack()
        mainStack.addArrangedSubview(themeStack)
        themeStack.addArrangedSubview(themeTitle)
        themeStack.addArrangedSubview(themeButtonStack)
    }
    
    //    private func setUpThemeButtonStack() {
    //        for theme in ThemeEnum.allCases {
    //            let button = UIButton()
    //            button.backgroundColor = theme.backgroundColor
    //            button.titleLabel?.text = "A"
    //            button.setTitleColor(theme.foregroundColor, for: .normal)
    //            themeButtonStack.addArrangedSubview(button)
    //        }
    //    }
    
    private func setUpThemeButtonStack() {
        themeButtonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (_, theme) in ThemeEnum.allCases.enumerated() {
            let button = UIButton(type: .system)
            
            button.backgroundColor = theme.backgroundColor
            button.setTitle("Aa", for: .normal)
            button.setTitleColor(theme.foregroundColor, for: .normal)
//            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            button.titleLabel?.font = FontEnum.libreBaskerville.uiFont(size: 18)//currentFont.uiFont(size: 18)
            print(button.titleLabel?.font.fontName)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 60),
                button.heightAnchor.constraint(equalToConstant: 60)
            ])
            button.layer.cornerRadius = 25
            button.clipsToBounds = true
            
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemGray4.cgColor
            
            button.tag = theme.index
            button.addTarget(self, action: #selector(themeButtonTapped(_:)), for: .touchUpInside)
            
            themeButtonStack.addArrangedSubview(button)
        }
    }
    
    private func refreshThemeButtonFonts() {
        for case let button as UIButton in themeButtonStack.arrangedSubviews {
            button.titleLabel?.font = currentFont.uiFont(size: 18)
        }
    }
    
    
    
    private func setUpBrightnessStack() {
        mainStack.addArrangedSubview(brightnessStack)
        brightnessSlider.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        brightnessSlider.addTarget(self, action: #selector(dragStarted(_:)), for: .touchDown)
        brightnessSlider.addTarget(self, action: #selector(dragEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        decreaseButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        increaseButton.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
        brightnessStack.addArrangedSubview(brightnessTitle)
        brightnessStack.addArrangedSubview(brightnessSliderStack)
        brightnessSliderStack.addArrangedSubview(decreaseButton)
        brightnessSliderStack.addArrangedSubview(brightnessSlider)
        brightnessSliderStack.addArrangedSubview(increaseButton)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        brightnessSlider.value = Float(UIScreen.main.brightness)
        
    }
    
    
    @objc func dragStarted(_ sender: UISlider) {
        Haptics.shared.play(.heavy)
    }
    
    @objc func dragEnded(_ sender: UISlider) {
        Haptics.shared.play(.heavy)
        //        delegate?.didChangeFontSize(to: CGFloat(sender.value))
    }
    @objc private func themeButtonTapped(_ sender: UIButton) {
        let themes = ThemeEnum.allCases
        guard sender.tag < themes.count else { return }
        
        let selectedTheme = themes[sender.tag]
        
        updateSelectedThemeButton(selectedIndex: sender.tag)
        
        if selectedTheme.index == 4 || selectedTheme.index == 3 {
            settingPanalThemeIsDark = true
        } else {
            settingPanalThemeIsDark = false
        }
        delegate?.didSetSettingViewTheme(isDark: settingPanalThemeIsDark)
        delegate?.didChangeTheme(to: selectedTheme)
    }
    
    private func updateSelectedThemeButton(selectedIndex: Int) {
        for (index, view) in themeButtonStack.arrangedSubviews.enumerated() {
            guard let button = view as? UIButton else { continue }
            
            if index == selectedIndex {
                button.layer.borderWidth = 3
                button.layer.borderColor = AppColors.systemBlue.cgColor
            } else {
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.systemGray4.cgColor
            }
        }
    }
    
    func updateBrightness(_ value: CGFloat) {
        
        UIScreen.main.brightness = value
    }
    
    @objc private func valueChanged(_ sender: UISlider) {
        //        let step: Float = 0.1
        //        let steppedValue = round(sender.value / step) * step
        //
        //        sender.value = steppedValue
        updateBrightness(CGFloat(sender.value))
    }
    
    @objc private func decreaseTapped() {
        let oldValue = brightnessSlider.value
        let newValue = brightnessSlider.value - 0.1
            brightnessSlider.setValue(newValue, animated: true)
        if oldValue != brightnessSlider.value {
                            Haptics.shared.play(.medium)

            valueChanged(brightnessSlider)
        }
            
        if newValue != Float(UIScreen.main.brightness) {
            //                Haptics.shared.play(.medium)
            
        }
        
    }
    
    @objc private func increaseTapped() {
        let oldValue = brightnessSlider.value
        let newValue = brightnessSlider.value + 0.1
            brightnessSlider.setValue(newValue, animated: true)
        if oldValue != brightnessSlider.value {
                            Haptics.shared.play(.medium)

            valueChanged(brightnessSlider)
        }
            //                Haptics.shared.play(.medium)
        if newValue != Float(UIScreen.main.brightness) {
            //                Haptics.shared.play(.medium)
            
        }
    }
    
}
