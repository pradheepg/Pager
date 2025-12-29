//
//  ViewHelper.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//
import UIKit

class ViewHelper {
    
    static func getCoverImage(of book: Book) -> UIImage{
        
        return UIImage(named: book.coverImageUrl ?? "") ??
        generateBookCoverImage(
            title: book.title ?? "Book",
            author: book.author ?? "Author"
        )
    }
    
    static func generateBookCoverImage(title: String, author: String, size: CGSize = CGSize(width: 120, height: 180)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.systemOrange.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let titleFont = UIFont.boldSystemFont(ofSize: 18)
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            let titleRect = CGRect(x: 10, y: 30, width: size.width-20, height: 60)
            (title as NSString).draw(in: titleRect, withAttributes: titleAttrs)
            
            let authorFont = UIFont.systemFont(ofSize: 14)
            let authorAttrs: [NSAttributedString.Key: Any] = [
                .font: authorFont,
                .foregroundColor: UIColor(white: 0.9, alpha: 1),
                .paragraphStyle: paragraphStyle
            ]
            let authorRect = CGRect(x: 10, y: 100, width: size.width-20, height: 22)
            (author as NSString).draw(in: authorRect, withAttributes: authorAttrs)
            
        }
    }
    
    static func loadBookContent(fileName: String) -> String {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return "Error" }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            return "Error loading book content."
        }
    }
}
extension UIImage {
    static func createImageWithLabel(text: String) -> UIImage? {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let colors: [UIColor] = [.systemBlue, .systemRed, .systemGreen, .systemOrange, .systemPurple, .systemTeal, .systemIndigo]
            let randomColor = colors.randomElement() ?? .systemGray
            
            randomColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 50, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: rect, withAttributes: attributes)
        }
    }
}
