//
//  Setting.swift
//  Pager
//
//  Created by Pradheep G on 06/01/26.
//
import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func didChangePageStyle(to style: UIPageViewController.TransitionStyle)
    func didChangeTheme(to mode: Int)
    func didChangeNavigationOrientation(to style: UIPageViewController.NavigationOrientation)
    func didChangePage(to index: Int)
    func didChangeReadingStyle(to: ReadingStyle)
}

class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsViewControllerDelegate?
    private var totalPages: Int = 0
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Position"
//        label.font = .systemFont(ofSize: 16, weight: .semibold)
//        label.textColor = .secondaryLabel//AppColors.text
//        
//        return label
//    }()
     
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 16
        style.headIndent = 16
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.secondaryLabel,
            .paragraphStyle: style
        ]
        
        label.attributedText = NSAttributedString(string: "Book Position", attributes: attributes)
        
        return label
    }()
    
    private lazy var scrollTile: SettingsTileView = {
        let tile = SettingsTileView(title: "Page Navigation", items: ["Slide", "Scroll", "Curl"], imageList: ["arrow.left.and.line.vertical.and.arrow.right","arrow.up.and.line.horizontal.and.arrow.down","doc.text"])
        
        tile.onSegmentChanged = { [weak self] index in
            guard let style = ReadingStyle(rawValue: index) else { return }
            
            self?.delegate?.didChangeReadingStyle(to: style)
        }
        return tile
    }()
    
    private lazy var themeTile: SettingsTileView = {
        let items: [Any] = [
            UIImage(systemName: "sun.max.fill")!,
            UIImage(systemName: "moon.fill")!,
            UIImage(systemName: "iphone")!
        ]
        let tile = SettingsTileView(title: "Theme", items: items)
        
        tile.onSegmentChanged = { [weak self] index in
            self?.delegate?.didChangeTheme(to: index)
        }
        tile.isHidden = true
        return tile
    }()
    
    private lazy var transitionTile: SettingsTileView = {
        let tile = SettingsTileView(title: "Transition Style", items: ["None", "Curl"])
        
        tile.onSegmentChanged = { [weak self] index in
            let style: UIPageViewController.TransitionStyle = (index == 0) ? .scroll : .pageCurl
            self?.delegate?.didChangePageStyle(to: style)
        }
        return tile
    }()
    
    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 15, weight: .medium)
        label.textColor = AppColors.systemBlue
        label.textAlignment = .center
//        label.layer.borderWidth = 1.0
//        
//        label.layer.borderColor = AppColors.secondaryText.withAlphaComponent(0.4).cgColor
//        
//        label.layer.cornerRadius = 8
//        
//        label.backgroundColor = AppColors.secondaryText.withAlphaComponent(0.1)
        
        label.clipsToBounds = true
        
        label.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPageLabel))
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    @objc func didTapPageLabel() {
        presentGoToPageAlert()
    }
    
    private lazy var pageSliderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stack.addArrangedSubview(pageSlider)
        stack.addArrangedSubview(pageLabel)
        pageSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        pageSlider.addTarget(self, action: #selector(sliderDidEndSliding), for: .touchUpInside)
        pageSlider.addTarget(self, action: #selector(dragStarted(_:)), for: .touchDown)
        pageSlider.addTarget(self, action: #selector(sliderDidEndSliding), for: .touchUpOutside)
        return stack
    }()
    
    private let pageSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
//        slider.minimumTrackTintColor = .label
//        slider.maximumTrackTintColor = .secondaryLabel
        slider.tintColor = AppColors.systemBlue

//        slider.minimumValueImage = UIImage(systemName: "book.pages")


//        let config = UIImage.SymbolConfiguration(scale: .large)
//        let thumb = UIImage(systemName: "circle.fill", withConfiguration: config)
//        slider.setThumbImage(thumb, for: .normal)
        
        return slider
    }()
    
    @objc func sliderDidEndSliding(_ sender: UISlider) {
        Haptics.shared.play(.medium)
    }
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, pageSliderStack, scrollTile])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.layoutMargins = UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 8)
        stack.setCustomSpacing(24, after: titleLabel)
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        
        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
        ])
    }
    
    
    func configure(themeMode: Int, isVertical: Bool, isCurl: Bool, totalPages: Int, currentPage: Int) {
        themeTile.setSelectedIndex(themeMode)
        if isCurl {
            scrollTile.setSelectedIndex(2)
        } else {
            scrollTile.setSelectedIndex(isVertical ? 1 : 0)

        }
        transitionTile.setSelectedIndex(isCurl ? 1 : 0)
        
        applyThemeOverride(modeIndex: themeMode)
        
        self.totalPages = totalPages
        pageSlider.minimumValue = 0
        pageSlider.maximumValue = Float(max(0, totalPages - 1))
        pageSlider.setValue(Float(currentPage), animated: true)
        updatePageLabel(current: currentPage)
    }
    
    @objc func dragStarted(_ sender: UISlider) {
        Haptics.shared.play(.heavy)
    }
    
    func applyThemeOverride(modeIndex: Int) {
        guard let mode = ThemeMode(rawValue: modeIndex) else { return }
        self.overrideUserInterfaceStyle = mode.uiInterfaceStyle
        
        let isActuallyDark = mode == .dark || (mode == .system && traitCollection.userInterfaceStyle == .dark)
        
        [scrollTile, themeTile, transitionTile].forEach { $0.updateTheme(isDark: isActuallyDark) }
    }
    
    func changeTheme(isDark: Bool) {
        if isDark {
            view.backgroundColor = .black
            titleLabel.textColor = .white
        } else {
            view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
            titleLabel.textColor = .black
        }
        
        [scrollTile, themeTile, transitionTile].forEach { $0.updateTheme(isDark: isDark) }
    }
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let index = Int(sender.value.rounded())
        pageSlider.value = Float(index)
        updatePageLabel(current: index)
        
        delegate?.didChangePage(to: index)
    }
    
//    private func updatePageLabel(current: Int) {
//        pageLabel.text = " Page \(current + 1)/\(totalPages) "
//    }
    
    private func updatePageLabel(current: Int) {
            let totalDigits = String(totalPages).count
            
            let formattedCurrent = String(format: "%\(totalDigits)d", current + 1)
            
            pageLabel.text = " Page \(formattedCurrent)/\(totalPages) "
        }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.overrideUserInterfaceStyle == .unspecified {
            let isDark = traitCollection.userInterfaceStyle == .dark
            [scrollTile, themeTile, transitionTile].forEach { $0.updateTheme(isDark: isDark) }
        }
    }
    func presentGoToPageAlert() {
        let totalPages = totalPages
        let alert = UIAlertController(
            title: "Go to Page",
            message: "Enter a page number (1 - \(totalPages))",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Page #"
            textField.keyboardType = .numberPad
            textField.textAlignment = .center
            textField.delegate = self
        }
        
        let goAction = UIAlertAction(title: "Go", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let pageInput = Int(text) else { return }
            
            let targetIndex = pageInput - 1
            
            if targetIndex >= 0 && targetIndex < self.totalPages {
                updatePageLabel(current: targetIndex)
                delegate?.didChangePage(to: targetIndex)
                pageSlider.setValue(Float(targetIndex), animated: true)
                Haptics.shared.play(.medium)
            } else {
                Haptics.shared.notify(.warning)
                Toast.show(message: "Invalid page number entered", in: self.view)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cancelAction)
        alert.addAction(goAction)
        
        present(alert, animated: true)
    }
}

class SettingsTileView: UIView {
    
    var onSegmentChanged: ((Int) -> Void)?
    
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel//AppColors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: [])
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    
    init(title: String, items: [Any], defaultIndex: Int = 0, imageList: [String] = []) {
        super.init(frame: .zero)
        
//        self.backgroundColor = AppColors.tileBackground
        self.layer.cornerRadius = 12
        self.layer.cornerCurve = .continuous
        self.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = title
        
        for (index, item) in items.enumerated() {
            if let string = item as? String {
                if index<imageList.count,  let image = UIImage(systemName: imageList[index]) {
                    segmentedControl.insertSegment(with: UIImage.textEmbededImage(image: image, string: string, color: .red), at: index, animated: false)
                } else {
                    segmentedControl.insertSegment(withTitle: string, at: index, animated: false)
                }
            } else if let image = item as? UIImage {
                segmentedControl.insertSegment(with: image, at: index, animated: false)
            }
        }
        segmentedControl.selectedSegmentIndex = defaultIndex
        segmentedControl.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupLayout() {
        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(label)
        mainStack.addArrangedSubview(segmentedControl)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            mainStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
        ])
//        addSubview(label)
//        addSubview(segmentedControl)
//        
//        NSLayoutConstraint.activate([
//            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
//            
//            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
//            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            
//            segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
//            segmentedControl.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            
//            segmentedControl.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 16),
//            
//            segmentedControl.widthAnchor.constraint(greaterThanOrEqualToConstant: 180)
//        ])
    }
    
    @objc private func segmentAction(_ sender: UISegmentedControl) {
        Haptics.shared.play(.medium)
        onSegmentChanged?(sender.selectedSegmentIndex)
    }
    
    func setSelectedIndex(_ index: Int) {
        segmentedControl.selectedSegmentIndex = index
    }
    func updateTheme(isDark: Bool) {
    }
}
extension SettingsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty { return true }
        
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }
        
        if let currentText = textField.text, let range = Range(range, in: currentText) {
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            if let pageNumber = Int(updatedText), pageNumber > self.totalPages {
                return false
            }
        }
        
        return true
    }
}
extension UIImage {
    static func textEmbededImage(image: UIImage, string: String, color: UIColor, font: UIFont = .systemFont(ofSize: 14, weight: .medium)) -> UIImage {
        
        let expectedTextSize = (string as NSString).size(withAttributes: [.font: font])
        let width = expectedTextSize.width + image.size.width + 10 // 10 is spacing
        let height = max(expectedTextSize.height, image.size.height)
        
        let size = CGSize(width: width, height: height)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let imageY = (height - image.size.height) / 2
            image.draw(at: CGPoint(x: 0, y: imageY))
            
            let textPoint = CGPoint(x: image.size.width + 10, y: (height - expectedTextSize.height) / 2)
            string.draw(at: textPoint, withAttributes: [
                .font: font,
                .foregroundColor: color
            ])
        }
    }
}
