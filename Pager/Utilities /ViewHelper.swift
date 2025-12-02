//
//  ViewHelper.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//
import UIKit

class ViewHelper {
    
    static func getCoverImage(of book: Book) -> UIImage{

//        idString = "image"
        print(book.coverImageUrl,book.title)
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
}
