//
//  ReadBookViewController.swift
//  Pager
//
//  Created by Pradheep G on 04/12/25.
//

import UIKit


class BookPaginator {
    
    
//    static func splitTextIntoPages(text: String, size: CGSize, font: UIFont) -> [String] {
//        let attributedString = NSAttributedString(string: text, attributes: [.font: font])
//        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
//        
//        var pageRange = CFRange()
//        var textPos = 0
//        let totalLength = attributedString.length
//        var pages = [String]()
//        
//        while textPos < totalLength {
//            let path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
//            
//            let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: textPos, length: 0), path, nil)
//            
//            pageRange = CTFrameGetVisibleStringRange(frame)
//            print(text.count,"-=-=-=-",textPos ,"aldjaksdj", pageRange.length)
//            let pageStart = text.index(text.startIndex, offsetBy: textPos)
//            let pageEnd = text.index(text.startIndex, offsetBy: textPos + pageRange.length)
//            let pageString = String(text[pageStart..<pageEnd])
//            
//            pages.append(pageString)
//            if pageRange.length == 0 {
//                print("Error: Page frame is too small to fit any text.")
//                break
//            }
//            textPos += pageRange.length
//        }
//        
//        return pages
//    }
    
    static func splitTextIntoPages(text: String, size: CGSize, font: UIFont) -> [String] {
        let attributedString = NSAttributedString(string: text, attributes: [.font: font])
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        
        var textPos = 0
        let totalLength = attributedString.length
        var pages = [String]()
        
        while textPos < totalLength {
            let path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
            
            let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: textPos, length: 0), path, nil)
            
            let pageRange = CTFrameGetVisibleStringRange(frame)
            
            let nsRange = NSRange(location: textPos, length: pageRange.length)
            
            if nsRange.location + nsRange.length > totalLength {
                 break
            }
            
            let pageString = attributedString.attributedSubstring(from: nsRange).string
            
            pages.append(pageString)
            
            if pageRange.length == 0 {
                print("Error: Page frame is too small to fit any text.")
                break
            }
            textPos += pageRange.length
        }
        
        return pages
    }
}

class PageContentViewController: UIViewController {
    
    var pageText: String = ""
    var pageIndex: Int = 0
    var bookTitleString: String = ""
    var fontSize: CGFloat = 18 {
        didSet {
            textView.font = .systemFont(ofSize: fontSize)
        }
    }

    
    let bookTitle: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.font = .systemFont(ofSize: 16)
        lable.textColor = AppColors.secondaryText
        lable.backgroundColor = .clear
        return lable
    }()
    
    let pageNumber: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.font = .systemFont(ofSize: 16)
        lable.textColor = AppColors.secondaryText
        lable.backgroundColor = .clear
        return lable
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.font = .systemFont(ofSize: 18)
        tv.textColor = AppColors.text
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        applyTheme()
        view.addSubview(bookTitle)
        view.addSubview(textView)
        view.addSubview(pageNumber)
        
        NSLayoutConstraint.activate([
            bookTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            
            // Center it
            bookTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bookTitle.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            bookTitle.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            
            pageNumber.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            pageNumber.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageNumber.heightAnchor.constraint(lessThanOrEqualToConstant: 50),
            
            textView.topAnchor.constraint(equalTo: bookTitle.bottomAnchor, constant: 10),
            
            textView.bottomAnchor.constraint(equalTo: pageNumber.topAnchor, constant: -10),
            
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        pageNumber.text = String(pageIndex + 1)
        bookTitle.text = bookTitleString
        textView.text = pageText
    }
    
    private func applyTheme() {
        view.backgroundColor = AppColors.background
        textView.textColor = AppColors.text
        bookTitle.textColor = AppColors.secondaryText
        pageNumber.textColor = AppColors.secondaryText
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
    }

}

class MainBookReaderViewController: UIViewController, SettingsViewControllerDelegate {
    
    var isFullScreen: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
            navigationController?.setNavigationBarHidden(isFullScreen, animated: true)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return isFullScreen
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    
    var pages: [String] = []
    var currentIndex: Int = 0
    let percentage: Double?
    let bookTitle: String
    let fullBookText: String
    var pageContentVCs = NSHashTable<PageContentViewController>.weakObjects()
    let settingsVC = SettingsViewController()
    var fontSize = 18
//    var themeTitle:UIColor = .black
//    var themeBackGroung:UIColor = .white
    var transitionStyle: UIPageViewController.TransitionStyle = .scroll
    var navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal
    var startTime: Date? = Date()
    private let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.color = .gray // Or use your theme color
        return spinner
    }()
    var onDismiss: (() -> Void)?
    private lazy var pageController: UIPageViewController = createPageController(transitionStyle: transitionStyle, navigationOrientation: navigationOrientation)
    private let viewModel: ReadBookViewModel
    private let readGoalService: ReadGoalService = ReadGoalService()
    
    init(book: Book) {
        self.bookTitle = book.title ?? ""
        self.viewModel = ReadBookViewModel(book: book)
        self.fullBookText = ViewHelper.loadBookContent(fileName: book.contentText ?? "") //driver
        self.currentIndex = self.viewModel.loadProgress()
        self.percentage = self.viewModel.loadPercentage()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTransparentNavbar()
        startSession()
        setUpNavBarItem()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        view.addSubview(loadingSpinner)
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loadingSpinner.startAnimating()
        viewModel.loadSetting()

        didChangeTheme(isDark: viewModel.isDark)
        didChangeNavigationOrientation(to: viewModel.isSwipe ? .horizontal : .vertical)
        didChangePageStyle(to: viewModel.isSide ? .scroll : .pageCurl)
        
        let screenWidth = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        let screenHeight = view.bounds.height > 0 ? view.bounds.height : UIScreen.main.bounds.height
        
        let textAreaSize = CGSize(
            width: screenWidth - 40,
            height: screenHeight - 60 // Adjusted based on previous discussion
        )
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            //driver
            print(fullBookText.count)
            let calculatedPages = BookPaginator.splitTextIntoPages(
                text: self.fullBookText,
                size: textAreaSize,
                font: .systemFont(ofSize: 20)
            )
            
            DispatchQueue.main.async {
                self.loadingSpinner.stopAnimating()
                guard !calculatedPages.isEmpty else {
                    return
                }
                self.pages = calculatedPages
                let totalPageCount = calculatedPages.count
                self.viewModel.saveTotalPages(count: totalPageCount)
                var safeIndex: Int = 0
                
                if let percentage = self.percentage, percentage > 0 {
                    let rawIndex = Int(Double(totalPageCount) * percentage / 100.0)
                    safeIndex = min(rawIndex, totalPageCount - 1)
                    
                } else {
                    if self.currentIndex < totalPageCount {
                        safeIndex = self.currentIndex
                    } else {
                        safeIndex = totalPageCount - 1
                    }
                }
                self.currentIndex = safeIndex
                self.pageControllerSetUp(startPage: safeIndex)
                self.setupSliderLayout()
                self.setUpGesture()
                //                    self.setUpNavBarItem()
                self.setupPageNumberLabel()
                self.updatePageLabel(currentIndex: safeIndex)
            }
        }
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func setupPageNumberLabel() {
        view.addSubview(pageNumberContainer)
        
        
//        pageNumberLabel.textColor = themeTitle
        
        pageNumberContainer.contentView.addSubview(pageNumberLabel)
        
        NSLayoutConstraint.activate([
            pageNumberContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageNumberContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            pageNumberContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            pageNumberContainer.heightAnchor.constraint(equalToConstant: 30),
            
            pageNumberLabel.centerXAnchor.constraint(equalTo: pageNumberContainer.contentView.centerXAnchor),
            pageNumberLabel.centerYAnchor.constraint(equalTo: pageNumberContainer.contentView.centerYAnchor),
            pageNumberLabel.leadingAnchor.constraint(equalTo: pageNumberContainer.contentView.leadingAnchor, constant: 10),
            pageNumberLabel.trailingAnchor.constraint(equalTo: pageNumberContainer.contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func didChangeNavigationOrientation(to style: UIPageViewController.NavigationOrientation) {
        let isVertical = (style == .vertical)
        viewModel.isSwipe = !isVertical
        navigationOrientation = style
        managePageControllerChange(transitionStyle: nil, navigationOrientation: navigationOrientation)
    }
    
    func didChangePageStyle(to style: UIPageViewController.TransitionStyle) {
        let isCurl = (style == .pageCurl)
        viewModel.isSide = !isCurl
        
        transitionStyle = style
        managePageControllerChange(transitionStyle: transitionStyle, navigationOrientation: nil)
    }
    
//    func didChangeTheme(isDark: Bool) {
//        viewModel.isDark = isDark
//        if isDark {
//            themeBackGroung = .black
//            themeTitle = .white
//            view.backgroundColor = themeBackGroung
//            for vc in pageContentVCs.allObjects {
//                vc.textView.textColor = themeTitle
//                vc.view.backgroundColor = themeBackGroung
//            }
//            let appearance = UINavigationBarAppearance()
//            appearance.titleTextAttributes = [.foregroundColor: themeTitle]
//            
//            navigationController?.navigationBar.standardAppearance = appearance
//            navigationController?.navigationBar.compactAppearance = appearance
//            navigationController?.navigationBar.scrollEdgeAppearance = appearance
//
//        } else {
//            themeBackGroung = .white
//            themeTitle = .black
//            view.backgroundColor = themeBackGroung
//            for vc in pageContentVCs.allObjects {
//                vc.textView.textColor = themeTitle
//                
//                vc.view.backgroundColor = themeBackGroung
//            }
//            let appearance = UINavigationBarAppearance()
//            appearance.titleTextAttributes = [.foregroundColor: themeTitle]
//            
//            navigationController?.navigationBar.standardAppearance = appearance
//            navigationController?.navigationBar.compactAppearance = appearance
//            navigationController?.navigationBar.scrollEdgeAppearance = appearance
//        }
//        settingsVC.changeTheme(isDark: isDark)
//        pageNumberLabel.textColor = themeTitle
//        
//        
//    }
    
    func didChangeTheme(isDark: Bool) {
        viewModel.isDark = isDark
        let style: UIUserInterfaceStyle = isDark ? .dark : .light
        self.overrideUserInterfaceStyle = style
//        navigationController?.overrideUserInterfaceStyle = style
//        overrideUserInterfaceStyle = style
        settingsVC.overrideUserInterfaceStyle = style//  applyThemeOverride(isDark: isDark)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: AppColors.text]
        appearance.backgroundColor = AppColors.background
        
        
        //driver
//        navigationController?.navigationBar.standardAppearance = appearance
//        navigationController?.navigationBar.compactAppearance = appearance
//        navigationController?.navigationBar.scrollEdgeAppearance = appearance
//        setNeedsStatusBarAppearanceUpdate()
        pageNumberLabel.textColor = AppColors.text
    }
    
    private func setupPpageNumberLabel() {
        view.addSubview(pageNumberLabel)
//        pageNumberLabel.textColor = themeTitle
        
        NSLayoutConstraint.activate([
            // Center horizontally
            pageNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Pin to bottom (Adjust constant based on where your slider is)
            // If slider is hidden by default, this sits at the bottom.
            pageNumberLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    private func updatePageLabel(currentIndex: Int) {
        let totalPages = pages.count
        // +1 because arrays start at 0, but humans count from 1
        pageNumberLabel.text = "Page \(currentIndex + 1) of \(totalPages)"
    }
    
    private func createPageController(transitionStyle: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation) -> UIPageViewController{
        let pc = UIPageViewController(transitionStyle: transitionStyle, navigationOrientation: navigationOrientation, options: [.interPageSpacing: 20])
        pc.dataSource = self
        pc.delegate = self
        return pc
    }
    
    private let pageNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.text = "Loading..."
        return label
    }()
    
    private let pageNumberContainer: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)//systemThinMaterial
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 12 // Half of height (capsule shape)
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.separator.cgColor // Subtle border
        return view
    }()
    
    private let pageSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .label
        slider.maximumTrackTintColor = .secondaryLabel
        
        let config = UIImage.SymbolConfiguration(scale: .small)
        let thumb = UIImage(systemName: "circle.fill", withConfiguration: config)
        slider.setThumbImage(thumb, for: .normal)
        
        return slider
    }()
    
    
    
    private func pageControllerSetUp(startPage index: Int) {
        setupPageController()
        if let firstVC = viewControllerAtIndex(index) {
            pageController.setViewControllers([firstVC], direction: .forward, animated: true)
        }
    }
    
    private func pageControllerReSetUp(startPage index: Int) {
        reSetupPageController()
        if let firstVC = viewControllerAtIndex(index) {
            pageController.setViewControllers([firstVC], direction: .forward, animated: true)
        }
    }
    
    private func setUpGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showSlider))
        tapGesture.cancelsTouchesInView = true
        
        view.addGestureRecognizer(tapGesture)
    }
    
    private func removePageController(pageController: UIPageViewController) {
        pageController.willMove(toParent: nil)
        pageController.view.removeFromSuperview()
        pageController.removeFromParent()
    }
    
    
    private func managePageControllerChange(
        transitionStyle: UIPageViewController.TransitionStyle?,
        navigationOrientation: UIPageViewController.NavigationOrientation?
    ) {
        removePageController(pageController: pageController)
        pageController = createPageController(transitionStyle: transitionStyle ?? self.transitionStyle, navigationOrientation: navigationOrientation ?? self.navigationOrientation)
        pageControllerReSetUp(startPage: currentIndex)
    }
    
    @objc func showSlider() {
        isFullScreen = !isFullScreen
        pageNumberContainer.isHidden = !pageNumberContainer.isHidden
        //                mainSettingButton.isHidden = !mainSettingButton.isHidden
    }
    
    
    private func setupPageController() {
        addChild(pageController)
        
        view.addSubview(pageController.view)
        
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            pageController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        pageController.didMove(toParent: self)
    }
    private func reSetupPageController() {
        addChild(pageController)
        
        view.insertSubview(pageController.view, at: 0)
        
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            pageController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        pageController.didMove(toParent: self)
    }
    
    func presentSettings() {
        settingsVC.delegate = self
        settingsVC.configure(isDark: viewModel.isDark, isVertical: !viewModel.isSwipe, isCurl: !viewModel.isSide)
        if let sheet = settingsVC.sheetPresentationController {
            sheet.detents = [
                .custom(resolver: { context in
                    return 300
                })
            ]
            sheet.prefersGrabberVisible = true
        }

        
        present(settingsVC, animated: true)
    }
    @objc func showHideSettingView() {
        presentSettings()
    }
    
    private func setupSliderLayout() {
        view.addSubview(pageSlider)
        pageSlider.isHidden = false
        pageSlider.minimumValue = 0
        pageSlider.maximumValue = Float(max(0, pages.count - 1))
        pageSlider.value = 0
        pageSlider.isHidden = true
        pageSlider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        NSLayoutConstraint.activate([
            pageSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pageSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pageSlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -1),
            pageSlider.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc func handleSliderChange(_ sender: UISlider) {
        let targetIndex = Int(sender.value.rounded())
        guard targetIndex != currentIndex else { return }
        
        let direction: UIPageViewController.NavigationDirection = targetIndex > currentIndex ? .forward : .reverse
        
        if let targetVC = viewControllerAtIndex(targetIndex) {
            pageController.setViewControllers([targetVC], direction: direction, animated: false)
            currentIndex = targetIndex
        }
        updatePageLabel(currentIndex: targetIndex)
    }
    
    func viewControllerAtIndex(_ index: Int) -> PageContentViewController? {
        if index >= pages.count || index < 0 { return nil }
        let vc = PageContentViewController()
        vc.pageText = pages[index]
        vc.bookTitleString = bookTitle
        vc.pageIndex = index
//        vc.textView.textColor = themeTitle
//        vc.view.backgroundColor = themeBackGroung
        vc.fontSize = CGFloat(fontSize)
        pageContentVCs.add(vc)
        return vc
    }
    
    
    private func startSession() {
        if startTime == nil {
            startTime = Date()
        }
    }

    private func saveAndResetSession() {
        guard let start = startTime else { return }
        
        let endTime = Date()
        readGoalService.updateTodayReading(startTime: start, endTime: endTime)
        startTime = nil
    }
    
    @objc func appWillEnterForeground() {
        startSession()
     }

     @objc func appDidEnterBackground() {
         saveAndResetSession()
     }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.saveProgress(progressValue: currentIndex)
        viewModel.saveSetting()
        saveAndResetSession()
        restoreDefaultNavbar()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            onDismiss?()
        }
    }
    
    private func configureTransparentNavbar() {
        guard let navBar = navigationController?.navigationBar else { return }

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        appearance.titleTextAttributes = [
            .foregroundColor: AppColors.text
        ]

        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance

        navBar.isTranslucent = true
    }

    private func restoreDefaultNavbar() {
        guard let navBar = navigationController?.navigationBar else { return }

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance

        navBar.isTranslucent = true
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainBookReaderViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PageContentViewController else { return nil }
        return viewControllerAtIndex(currentVC.pageIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PageContentViewController else { return nil }
        return viewControllerAtIndex(currentVC.pageIndex + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let currentVC = pageViewController.viewControllers?.first as? PageContentViewController {
            self.currentIndex = currentVC.pageIndex
            pageSlider.setValue(Float(self.currentIndex), animated: true)
            updatePageLabel(currentIndex: self.currentIndex)
        }
    }
    
    func setUpNavBarItem() {
        //        navigationItem.title = bookTitle
        let appearance = UINavigationBarAppearance()
//        appearance.titleTextAttributes = [.foregroundColor: themeTitle]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        let closeBarButton = UIBarButtonItem(barButtonSystemItem: .close,
                                             target: self,
                                             action: #selector(closeButtonTapped))
        
        navigationItem.leftBarButtonItems = [closeBarButton]
        
        if #available(iOS 26.0, *) {
            let editBarButton = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"),
                                                style: .prominent,
                                                target: self,
                                                action: #selector(showHideSettingView))
            editBarButton.tintColor = AppColors.background
            navigationItem.rightBarButtonItems = [editBarButton]
        } else {
            let editBarButton = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(showHideSettingView) )
            editBarButton.tintColor = AppColors.title
            navigationItem.rightBarButtonItems = [editBarButton]
        }
        
    }
    
    @objc private func closeButtonTapped() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

protocol SettingsViewControllerDelegate: AnyObject {
    func didChangePageStyle(to style: UIPageViewController.TransitionStyle)
    func didChangeTheme(isDark: Bool)
    func didChangeNavigationOrientation(to style: UIPageViewController.NavigationOrientation)
}

class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsViewControllerDelegate?
        
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Appearance"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppColors.text
        return label
    }()
    
    private lazy var scrollTile: SettingsTileView = {
        let tile = SettingsTileView(title: "Scroll Direction", items: ["Horizontal", "Vertical"])
        
        tile.onSegmentChanged = { [weak self] index in
            let style: UIPageViewController.NavigationOrientation = (index == 0) ? .horizontal : .vertical
            self?.delegate?.didChangeNavigationOrientation(to: style)
        }
        return tile
    }()
    
    private lazy var themeTile: SettingsTileView = {
        let items: [Any] = [UIImage(systemName: "sun.max.fill")!, UIImage(systemName: "moon.fill")!]
        let tile = SettingsTileView(title: "Theme", items: items)
        
        tile.onSegmentChanged = { [weak self] index in
            let isDark = (index == 1)
            self?.delegate?.didChangeTheme(isDark: isDark)
//            self?.changeTheme(isDark: isDark)
        }
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
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, scrollTile, themeTile, transitionTile])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.setCustomSpacing(24, after: titleLabel)
        return stack
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    func configure(isDark: Bool, isVertical: Bool, isCurl: Bool) {
        themeTile.setSelectedIndex(isDark ? 1 : 0)
        scrollTile.setSelectedIndex(isVertical ? 1 : 0)
        transitionTile.setSelectedIndex(isCurl ? 1 : 0)
        applyThemeOverride(isDark: isDark)
    }
    func applyThemeOverride(isDark: Bool) {
        self.overrideUserInterfaceStyle = isDark ? .dark : .light
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
}

class SettingsTileView: UIView {
    
    var onSegmentChanged: ((Int) -> Void)?
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = AppColors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: [])
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    
    init(title: String, items: [Any], defaultIndex: Int = 0) {
        super.init(frame: .zero)
        
        self.backgroundColor = AppColors.tileBackground
        self.layer.cornerRadius = 12
        self.layer.cornerCurve = .continuous
        self.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = title
        
        for (index, item) in items.enumerated() {
            if let string = item as? String {
                segmentedControl.insertSegment(withTitle: string, at: index, animated: false)
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
        addSubview(label)
        addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
            
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            segmentedControl.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            segmentedControl.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 16),
            
             segmentedControl.widthAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
    }
        
    @objc private func segmentAction(_ sender: UISegmentedControl) {
        onSegmentChanged?(sender.selectedSegmentIndex)
    }
    
    func setSelectedIndex(_ index: Int) {
        segmentedControl.selectedSegmentIndex = index
    }
    func updateTheme(isDark: Bool) {
            if isDark {
                self.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
                label.textColor = .white
                segmentedControl.overrideUserInterfaceStyle = .dark
            } else {
                self.backgroundColor = .white
                label.textColor = .black
                segmentedControl.overrideUserInterfaceStyle = .light
            }
        }
}
