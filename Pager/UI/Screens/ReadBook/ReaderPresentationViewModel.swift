//
//  ReaderPresentationViewModel.swift
//  Pager
//
//  Created by Pradheep G on 06/01/26.
//
import UIKit

class ReaderPresentationViewModel {
    
    private let bookContent: String
    private var paginator: OptimizedPaginator?
    private var pageRanges: [NSRange] = []
    private var isFirstLoad = true
    
    var appearance = ReaderAppearance()
    var currentPageIndex: Int = 0
    var totalPages: Int { return pageRanges.count }
    
    var onReloadNeeded: (() -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    init(bookContent: String) {
        self.bookContent = bookContent
    }
    
    func loadBook(textAreaSize: CGSize) {
        repaginate(textAreaSize: textAreaSize)
    }
    
    func updateSettings(theme: ThemeEnum? = nil, fontSize: CGFloat? = nil, font: FontEnum? = nil, textAreaSize: CGSize) {
        if let t = theme { appearance.themeMode = t }
        if let s = fontSize { appearance.fontSize = s }
        if let f = font { appearance.font = f }
        
        repaginate(textAreaSize: textAreaSize)
    }
    
//    private func repaginate(textAreaSize: CGSize) {
//        let currentStartChar = pageRanges.isEmpty ? 0 : pageRanges[currentPageIndex].location
//        
//        onLoading?(true)
//
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let self = self else { return }
//            
//            let newPaginator = OptimizedPaginator(bookText: self.bookContent, appearance: self.appearance)
//            let newRanges = newPaginator.computePageRanges(textAreaSize: textAreaSize)
//            
//            let newIndex = newPaginator.getPageIndex(forCharacterIndex: currentStartChar, in: newRanges)
//            
//            DispatchQueue.main.async {
//                self.paginator = newPaginator
//                self.pageRanges = newRanges
//                self.currentPageIndex = newIndex
//                self.onLoading?(false)
//                self.onReloadNeeded?()
//            }
//        }
//    }
    
    private func repaginate(textAreaSize: CGSize) {
            onLoading?(true)
            
            var currentStartChar: Int = 0
            
            if !isFirstLoad && !pageRanges.isEmpty && currentPageIndex < pageRanges.count {
                currentStartChar = pageRanges[currentPageIndex].location
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                let newPaginator = OptimizedPaginator(bookText: self.bookContent, appearance: self.appearance)
                let newRanges = newPaginator.computePageRanges(textAreaSize: textAreaSize)
                
                DispatchQueue.main.async {
                    self.paginator = newPaginator
                    self.pageRanges = newRanges
                    
                    if self.isFirstLoad {
                        if self.currentPageIndex >= newRanges.count {
                            self.currentPageIndex = max(0, newRanges.count - 1)
                        }
                        self.isFirstLoad = false
                    } else {
                        let newIndex = newPaginator.getPageIndex(forCharacterIndex: currentStartChar, in: newRanges)
                        self.currentPageIndex = newIndex
                    }
                    
                    self.onLoading?(false)
                    self.onReloadNeeded?()
                }
            }
        }
    
    func getPageContent(at index: Int) -> NSAttributedString? {
        guard index >= 0 && index < pageRanges.count else { return nil }
        return paginator?.getAttributedText(for: pageRanges[index])
    }
}
