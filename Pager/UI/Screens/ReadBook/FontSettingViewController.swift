//
//  FontSettingViewController.swift
//  Pager
//
//  Created by Pradheep G on 06/01/26.
//
import UIKit

enum FontEnum: String, CaseIterable {
    case helvetica = "Helvetica"
    
    case literata = "Literata-Regular"
    case lora = "Lora-Regular"
    case merriweather = "Merriweather-Regular"
    case libreBaskerville = "LibreBaskerville-Regular"
    case nunito = "Nunito-Regular"
    case openSans = "OpenSans-Regular"
    
    var displayName: String {
        switch self {
        case .helvetica: return "Helvetica"
        case .literata: return "Literata"
        case .lora: return "Lora"
        case .merriweather: return "Merriweather"
        case .libreBaskerville: return "Baskerville"
        case .nunito: return "Nunito"
        case .openSans: return "Open Sans"
        }
    }
    
    static func from(index: Int) -> FontEnum {
        if index >= 0 && index < FontEnum.allCases.count {
            return FontEnum.allCases[index]
        }
        return .helvetica
    }
    
    var index: Int {
        return FontEnum.allCases.firstIndex(of: self) ?? 0
    }
    
    func uiFont(size: CGFloat) -> UIFont {
        if let customFont = UIFont(name: self.rawValue, size: size) {
            return customFont
        }
        return UIFont.systemFont(ofSize: size)
    }
}

protocol FontSettingsViewControllerDelegate: AnyObject {
    func didChangeFont(to font: FontEnum)
    func didChangeFontSize(to size: CGFloat)
}

class FontSettingViewController: UIViewController {
    
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let fontSizeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return stack
    }()
    
    private let fontSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "Font Size"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fontSizeSliderStack: UIStackView = {
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        //        stack.backgroundColor = AppColors.gridViewSecondaryColor
        
        return stack
    }()
    
    private let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 12
        slider.maximumValue = 36
        slider.value = 18
        slider.tintColor = AppColors.systemBlue
        
        //        slider.minimumValueImage = UIImage(systemName: "textformat.size.smaller")
        //        slider.maximumValueImage = UIImage(systemName: "textformat.size.larger")
        return slider
    }()
    
    private let decreaseButton: UIButton = {
        let btn = UIButton(type: .system)
        
        let image = UIImage(systemName: "textformat.size.smaller")
        
        btn.setImage(image, for: .normal)
        btn.setTitle("-", for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        
        btn.tintColor = .secondaryLabel
        return btn
    }()
    
    private let increaseButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(systemName: "textformat.size.larger")
        btn.setTitle("+", for: .normal)
        btn.setImage(image, for: .normal)
        btn.tintColor = .secondaryLabel
        btn.semanticContentAttribute = .forceRightToLeft
        
        return btn
    }()
    
    private let fontStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return stack
    }()
    
    private let fontLabel: UILabel = {
        let label = UILabel()
        label.text = "Font"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fontButton: UIButton = {
        let btn = UIButton(type: .system)
        
        var config = UIButton.Configuration.gray()
        //            config.image = UIImage(systemName: "chevron.up.chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.cornerStyle = .medium
        config.baseForegroundColor = .label
        config.baseBackgroundColor = .secondarySystemBackground//AppColors.gridViewSecondaryColor
        
        btn.configuration = config
        btn.addTarget(self, action: #selector(fontButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    
    var currentFont: FontEnum = .helvetica
    
    weak var delegate: FontSettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainStack()
        setUpSlider()
        setupPicker()
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
    
    private func setUpSlider() {
        mainStack.addArrangedSubview(fontSizeStack)
        slider.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(dragStarted(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(dragEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        decreaseButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        increaseButton.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
        fontSizeStack.addArrangedSubview(fontSizeLabel)
        fontSizeStack.addArrangedSubview(fontSizeSliderStack)
        fontSizeSliderStack.addArrangedSubview(decreaseButton)
        fontSizeSliderStack.addArrangedSubview(slider)
        fontSizeSliderStack.addArrangedSubview(increaseButton)
        
    }
    
    private func setupPicker() {
        mainStack.addArrangedSubview(fontStack)
        fontStack.addArrangedSubview(fontLabel)
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        fontStack.addArrangedSubview(spacer)
        
        fontStack.addArrangedSubview(fontButton)
        
        updateFontButtonDisplay()
    }
    @objc private func fontButtonTapped() {
        let pickerVC = FontPickerViewController()
        
        pickerVC.currentFont = self.currentFont
        
        pickerVC.didSelectFont = { [weak self] selectedFont in
            guard let self = self else { return }
            self.handleFontSelection(selectedFont)
        }
        
        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(pickerVC, animated: true)
    }
    
    private func updateFontButtonDisplay() {
        var container = AttributeContainer()
        container.font = currentFont.uiFont(size: 17)
        container.foregroundColor = UIColor.label
        
        fontButton.configuration?.attributedTitle = AttributedString(currentFont.displayName, attributes: container)
    }
    
    private func handleFontSelection(_ font: FontEnum) {
        self.currentFont = font
        
        updateFontButtonDisplay()
        
        delegate?.didChangeFont(to: font)
    }
    
    func configure(font: FontEnum, fontSize: Float) {
        slider.value = fontSize
        self.currentFont = font
        updateFontButtonDisplay()
    }
    
    
    @objc func valueChanged(_ sender: UISlider) {
        let step: Float = 2
        let steppedValue = round(sender.value / step) * step
        
        sender.value = steppedValue
    }
    
    @objc func dragStarted(_ sender: UISlider) {
        Haptics.shared.play(.heavy)
    }
    
    @objc func dragEnded(_ sender: UISlider) {
        Haptics.shared.play(.heavy)
        delegate?.didChangeFontSize(to: CGFloat(sender.value))
    }
    
    @objc private func decreaseTapped() {
        let oldValue = slider.value
        let newValue = slider.value - 2
        slider.setValue(newValue, animated: true)
        if oldValue != slider.value {
            dragEnded(slider)
        }
        
    }
    
    @objc private func increaseTapped() {
        let oldValue = slider.value
        let newValue = slider.value + 2
        slider.setValue(newValue, animated: true)
        if oldValue != slider.value {
            dragEnded(slider)
        }
    }
}
class FontPickerViewController: UITableViewController {
    
    private let fonts = FontEnum.allCases
    var currentFont: FontEnum?
    
    var didSelectFont: ((FontEnum) -> Void)?
    
    init() {
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = AppColors.background
//        title = "Select Font"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FontCell")
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        setupHeader()
        tableView.tableFooterView = UIView()
    }
    private func setupHeader() {
        let headerHeight: CGFloat = 60
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
        headerView.backgroundColor = .clear // Or AppColors.background
        let titleLabel = UILabel()
        titleLabel.text = "Select Font"
        titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor =  UIColor.secondaryLabel
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 10),
            
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        tableView.tableHeaderView = headerView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fonts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontCell", for: indexPath)
        let fontEnum = fonts[indexPath.row]
        
        cell.textLabel?.text = fontEnum.displayName
        
        cell.textLabel?.font = fontEnum.uiFont(size: 20)
        
        if fontEnum == currentFont {
            cell.accessoryType = .checkmark
            cell.tintColor = AppColors.systemBlue
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selected = fonts[indexPath.row]
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        didSelectFont?(selected)
        
        dismiss(animated: true)
    }
}
