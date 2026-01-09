//
//  ReadBookViewController.swift
//  Pager
//
//  Created by Pradheep G on 04/12/25.
//

import UIKit

enum ReadingStyle: Int {
    case slide = 0
    case scroll = 1
    case curl = 2
}

enum ThemeMode: Int {
    case light = 0
    case dark = 1
    case system = 2
    
    var uiInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .unspecified
        }
    }
}

struct ReaderAppearance {
    var themeMode: ThemeEnum = .light
    var fontSize: CGFloat = 18.0
    var font: FontEnum = FontEnum.helvetica
}

class OptimizedPaginator {
    
    private let fullAttributedText: NSAttributedString
    private let framesetter: CTFramesetter
    
    init(bookText: String, appearance: ReaderAppearance) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: appearance.font.uiFont(size: appearance.fontSize),
            .foregroundColor: appearance.themeMode.foregroundColor
        ]
        
        self.fullAttributedText = NSAttributedString(string: bookText, attributes: attributes)
        self.framesetter = CTFramesetterCreateWithAttributedString(fullAttributedText)
    }
    
    func computePageRanges(textAreaSize: CGSize) -> [NSRange] {
        var ranges: [NSRange] = []
        let totalLength = fullAttributedText.length
        var currentOffset = 0
        
        while currentOffset < totalLength {
            let path = CGPath(rect: CGRect(origin: .zero, size: textAreaSize), transform: nil)
            
            let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: currentOffset, length: 0), path, nil)
            let frameRange = CTFrameGetVisibleStringRange(frame)
            
            let nsRange = NSRange(location: frameRange.location, length: frameRange.length)
            ranges.append(nsRange)
            
            currentOffset += frameRange.length
        }
        
        return ranges
    }
    
    func getAttributedText(for range: NSRange) -> NSAttributedString {
        return fullAttributedText.attributedSubstring(from: range)
    }
    
    func getPageIndex(forCharacterIndex index: Int, in ranges: [NSRange]) -> Int {
        for (i, range) in ranges.enumerated() {
            if index >= range.location && index < (range.location + range.length) {
                return i
            }
        }
        return 0
    }
}

class PageContentViewController: UIViewController {
    
    init(presentationViewModel: ReaderPresentationViewModel) {
        self.presentationViewModel = presentationViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var presentationViewModel: ReaderPresentationViewModel?
    var pageText: NSAttributedString?
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
        bookTitle.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.addSubview(bookTitle)
        view.addSubview(textView)
        view.addSubview(pageNumber)
        NSLayoutConstraint.activate([
            bookTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            
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
        textView.attributedText = pageText
    }
    
    private func applyTheme() {
        //        view.backgroundColor = AppColors.background
        //        textView.textColor = AppColors.text
        view.backgroundColor = self.presentationViewModel?.appearance.themeMode.backgroundColor ?? AppColors.readBookBg
        textView.textColor = self.presentationViewModel?.appearance.themeMode.foregroundColor ?? AppColors.readBookFg
        bookTitle.textColor = AppColors.secondaryText
        pageNumber.textColor = AppColors.secondaryText
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
    }
    
}

class MainBookReaderViewController: UIViewController, SettingsViewControllerDelegate, FontSettingsViewControllerDelegate {

    
    var presentationViewModel: ReaderPresentationViewModel!
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
    
    
    var currentIndex: Int {
        didSet {
            if let vm = presentationViewModel {
                vm.currentPageIndex = currentIndex
            }
            updatePageLabel(currentIndex: currentIndex)
        }
    }
    
    let percentage: Double?
    let bookTitle: String
    let fullBookText: String
    var pageContentVCs = NSHashTable<PageContentViewController>.weakObjects()
    let settingsVC = SettingsViewController()
    let themeSettingVC = ThemeSettingViewController()
    let fontSettingVC = FontSettingViewController()
    
    var fontSize = 18
    var transitionStyle: UIPageViewController.TransitionStyle = .scroll
    var navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal
    var startTime: Date? = Date()
    private let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.color = .systemPurple
        return spinner
    }()
    var onDismiss: (() -> Void)?
    private lazy var pageController: UIPageViewController = createPageController(transitionStyle: transitionStyle, navigationOrientation: navigationOrientation)
    private let viewModel: ReadBookViewModel
    private let readGoalService: ReadGoalService = ReadGoalService()
    
    init(book: Book) {
        
        self.bookTitle = book.title ?? ""
        self.viewModel = ReadBookViewModel(book: book)
        self.fullBookText = ViewHelper.loadBookContent(fileName: book.contentText ?? "")
        self.currentIndex = self.viewModel.loadProgress()
        self.percentage = self.viewModel.loadPercentage()
        super.init(nibName: nil, bundle: nil)
        self.viewModel.configure()
        self.transitionStyle =  self.viewModel.isSide ? .scroll : .pageCurl
        self.navigationOrientation = self.viewModel.isSwipe ? .horizontal : .vertical
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
        
        view.backgroundColor = AppColors.readBookBg
        view.addSubview(loadingSpinner)
        
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        loadingSpinner.startAnimating()
        
        presentationViewModel = ReaderPresentationViewModel(bookContent: self.fullBookText)
        presentationViewModel.currentPageIndex = self.currentIndex
        presentationViewModel.appearance.fontSize = CGFloat(viewModel.fontSize)
        presentationViewModel.appearance.themeMode = viewModel.theme
        presentationViewModel.appearance.font = viewModel.font
        presentationViewModel.onLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.loadingSpinner.startAnimating()
                    self?.view.isUserInteractionEnabled = false
                } else {
                    self?.loadingSpinner.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                }
            }
        }
        
        presentationViewModel.onReloadNeeded = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view.backgroundColor = self.presentationViewModel.appearance.themeMode.backgroundColor
                
                let newIndex = self.presentationViewModel.currentPageIndex
                self.currentIndex = newIndex
                self.viewModel.saveTotalPages(count: self.presentationViewModel.totalPages)
                self.pageControllerReSetUp(startPage: newIndex)
                
                self.updatePageLabel(currentIndex: newIndex)
                
                self.setUpGesture()
                self.setupPageNumberLabel()
                self.settingsVC.configure(
                    themeMode: self.viewModel.themeMode,
                    isVertical: !self.viewModel.isSwipe,
                    isCurl: !self.viewModel.isSide,
                    totalPages: self.presentationViewModel.totalPages,
                    currentPage: self.currentIndex
                )
                self.themeSettingVC.configure(theme: self.viewModel.theme, currentFont: self.viewModel.font)

            }
        }
        
        let width = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        let height = view.bounds.height > 0 ? view.bounds.height : UIScreen.main.bounds.height
        
        let textAreaSize = CGSize(width: width - 40, height: height - 60)
        presentationViewModel.loadBook(textAreaSize: textAreaSize)
        
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
    func didChangeReadingStyle(to style: ReadingStyle) {
        
        let newTransitionStyle: UIPageViewController.TransitionStyle
        let newOrientation: UIPageViewController.NavigationOrientation
        
        switch style {
        case .slide:
            newTransitionStyle = .scroll
            newOrientation = .horizontal
            
            viewModel.isSwipe = true
            viewModel.isSide = true
            
        case .scroll:
            newTransitionStyle = .scroll
            newOrientation = .vertical
            
            viewModel.isSwipe = false
            viewModel.isSide = true
            
        case .curl:
            newTransitionStyle = .pageCurl
            newOrientation = .horizontal
            
            viewModel.isSwipe = true
            viewModel.isSide = false
        }
        
        self.transitionStyle = newTransitionStyle
        self.navigationOrientation = newOrientation
        
        managePageControllerChange(
            transitionStyle: newTransitionStyle,
            navigationOrientation: newOrientation
        )
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
    
    func didChangeFont(to font: FontEnum) {
        let width = view.bounds.width
        let height = view.bounds.height
        let textAreaSize = CGSize(width: width - 40, height: height - 60)
        viewModel.font = font
        presentationViewModel.updateSettings(font: font, textAreaSize: textAreaSize)
    }
    
    func didChangeFontSize(to size: CGFloat) {
        let width = view.bounds.width
        let height = view.bounds.height
        let textAreaSize = CGSize(width: width - 40, height: height - 60)
        viewModel.fontSize = Float(size)
        presentationViewModel.updateSettings(fontSize: size, textAreaSize: textAreaSize)
    }
    
    func didChangeTheme(to modeIndex: Int) {
        return
        let width = view.bounds.width
        let height = view.bounds.height
        let textAreaSize = CGSize(width: width - 40, height: height - 60)
        
//        presentationViewModel.updateSettings(theme: modeIndex, textAreaSize: textAreaSize)
        
        let mode = ThemeMode(rawValue: modeIndex) ?? .system
        let style = mode.uiInterfaceStyle
        
        self.overrideUserInterfaceStyle = style
        settingsVC.overrideUserInterfaceStyle = style
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: presentationViewModel.appearance.themeMode.foregroundColor]
        
        setNeedsStatusBarAppearanceUpdate()
        pageNumberLabel.textColor = presentationViewModel.appearance.themeMode.foregroundColor
        
        if presentedViewController == settingsVC {
            settingsVC.applyThemeOverride(modeIndex: modeIndex)
        }
    }
    
    private func setupPpageNumberLabel() {
        view.addSubview(pageNumberLabel)
        
        NSLayoutConstraint.activate([
            pageNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            pageNumberLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    private func updatePageLabel(currentIndex: Int) {
        //        let totalPages = pages.count
        pageNumberLabel.text = "Page \(currentIndex + 1) of \(self.presentationViewModel.totalPages)"
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

    private lazy var floatingButton: UIButton = {
    var config = UIButton.Configuration.filled()
    
    config.image = UIImage(systemName: "slider.horizontal.3")
    config.baseForegroundColor = .label
    
    config.background.visualEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    
    config.background.backgroundColor = UIColor.clear
    
    config.cornerStyle = .capsule
    config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    
    let button = UIButton(configuration: config)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOpacity = 0.2
    button.layer.shadowOffset = CGSize(width: 0, height: 4)
    button.layer.shadowRadius = 8
    
    button.layer.borderWidth = 0.5
    button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    
    button.addTarget(self, action: #selector(showHideSettingView), for: .touchUpInside)
    
    return button
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
            pageController.setViewControllers([firstVC], direction: .forward, animated: false)
        }
    }
    
    private func setUpGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showSettingButton))
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
    
    @objc func showSettingButton() {
        isFullScreen = !isFullScreen
        pageNumberContainer.isHidden = !pageNumberContainer.isHidden
        floatingButton.isHidden = isFullScreen
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
        settingsVC.configure(
            themeMode: viewModel.themeMode,
            isVertical: !viewModel.isSwipe,
            isCurl: !viewModel.isSide,
            totalPages: presentationViewModel.totalPages,
            currentPage: currentIndex
        )
        
        settingsVC.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "gearshape"),
            tag: 0
        )
        

        themeSettingVC.view.backgroundColor = AppColors.background
        themeSettingVC.delegate = self
        themeSettingVC.configure(theme: viewModel.theme, currentFont: viewModel.font)
        themeSettingVC.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "sun.min"),
            tag: 1
        )
        
        fontSettingVC.view.backgroundColor = AppColors.background
        fontSettingVC.delegate = self
        fontSettingVC.configure(font: viewModel.font, fontSize: viewModel.fontSize)
        fontSettingVC.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "textformat.size"),
            tag: 2
        )
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [settingsVC, themeSettingVC, fontSettingVC]
        
//        tabBarController.tabBar.backgroundColor = .systemBackground
        
        if let sheet = tabBarController.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { context in
                                return 300
                            }
            sheet.detents = [customDetent,.medium()]
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
        
        present(tabBarController, animated: true)
    }
    
    @objc func showHideSettingView() {
        presentSettings()
    }
    
    
    func viewControllerAtIndex(_ index: Int) -> PageContentViewController? {
        if index >= presentationViewModel.totalPages || index < 0 { return nil }
        
        let vc = PageContentViewController(presentationViewModel: presentationViewModel)
        vc.pageText = presentationViewModel.getPageContent(at: index)
        vc.bookTitleString = bookTitle
        vc.pageIndex = index
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
        }
    }
    
    func didChangePage(to index: Int) {
        guard index != currentIndex else {
            return
        }
        
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        
        if let targetVC = viewControllerAtIndex(index) {
            pageController.setViewControllers([targetVC], direction: direction, animated: false)
            
            self.currentIndex = index
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
//        let editBarButton = UIBarButtonItem(barButtonSystemItem: .edit,
//                                             target: self,
//                                             action: #selector(showHideSettingView))
//        if #available(iOS 26.0, *) {
//            let editBarButton = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"),
//                                                style: .prominent,
//                                                target: self,
//                                                action: #selector(showHideSettingView))
//            editBarButton.tintColor = AppColors.background
//            navigationItem.rightBarButtonItems = [editBarButton]
//        } else {
//            let editBarButton = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"),
//                                                style: .plain,
//                                                target: self,
//                                                action: #selector(showHideSettingView) )
//            editBarButton.tintColor = AppColors.title
//            navigationItem.rightBarButtonItems = [editBarButton]
//        }
        setupFloatingButton()
    }
    private func setupFloatingButton() {
            view.addSubview(floatingButton)
        floatingButton.isHidden = isFullScreen
            NSLayoutConstraint.activate([
                floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                floatingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
                
                // Optional: Force a specific size if you don't want it to grow with content
                // floatingButton.widthAnchor.constraint(equalToConstant: 60),
                // floatingButton.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
    @objc private func closeButtonTapped() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

extension MainBookReaderViewController: ThemeSettingsViewControllerDelegate {

    func didSetSettingViewTheme(isDark: Bool) {
        print("didsetsetting")
        let style: UIUserInterfaceStyle = isDark ? .dark : .light
//        let modeIndex = isDark ? 1 : 0
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = style
        }
//        settingsVC.overrideUserInterfaceStyle = style
//        themeSettingVC.overrideUserInterfaceStyle = style
//        fontSettingVC.overrideUserInterfaceStyle = style
        
//        if presentedViewController == settingsVC {
//            settingsVC.applyThemeOverride(modeIndex: modeIndex)
//        }
//        
//        if presentedViewController == themeSettingVC {
//            themeSettingVC.applyThemeOverride(modeIndex: modeIndex)
//        }
//        
//        if presentedViewController == fontSettingVC {
//            fontSettingVC.applyThemeOverride(modeIndex: modeIndex)
//        }
    }
    
    func didChangeTheme(to theme: ThemeEnum) {
        viewModel.theme = theme
            let width = view.bounds.width
            let height = view.bounds.height
            let textAreaSize = CGSize(width: width - 40, height: height - 60)
            
            presentationViewModel.updateSettings(theme: theme, textAreaSize: textAreaSize)
    }
}
