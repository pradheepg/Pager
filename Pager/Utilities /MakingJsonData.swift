//
//  MakingJsonData.swift
//  Pager
//
//  Created by Pradheep G on 29/12/25.
//

import SwiftUI
internal import Combine

// MARK: - 1. Destination Model (The JSON Schema you want)
struct ExportBook: Codable {
    let bookId: String
    let title: String
    let author: String
    let genre: String
    let descriptionText: String
    let language: String
    let coverImageUrl: String // Will hold "Image 1", "Image 2" etc.
    let contentText: String
    let price: Double
    let averageRating: Double // Ignored (0.0)
    let publicationDate: String // ISO8601 String for portability
}

// MARK: - 2. Source Model (Gutendex API)
struct GutendexResponse: Codable {
    let results: [GutendexBook]
}

struct GutendexBook: Codable {
    let id: Int
    let title: String
    let authors: [GutendexPerson]
    let summaries: [String]
    let languages: [String]
    let bookshelves: [String]
    let subjects: [String]
    let formats: [String: String]
}

struct GutendexPerson: Codable {
    let name: String
}

// MARK: - 3. The Downloader Engine
class BookExportManager: ObservableObject {
    @Published var statusMessage = "Ready to start..."
    @Published var isProcessing = false
    
    // Genre Enum Logic
    enum CategoryEnum: String, CaseIterable {
        case novels = "Novels"
        case thriller = "Thriller"
        case fantasy = "Fantasy"
        case business = "Business"
        case biography = "Biography"
        case kids = "Kids"
    }

    func startExport() async {
        await MainActor.run {
            isProcessing = true
            statusMessage = "Starting download..."
        }
        
        let fileManager = FileManager.default
        
        // 1. Create Export Directory: "Documents/BookExport"
        guard let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let exportFolder = docDir.appendingPathComponent("BookExport")
        let coversFolder = exportFolder.appendingPathComponent("Covers")
        
        do {
            if fileManager.fileExists(atPath: exportFolder.path) {
                try fileManager.removeItem(at: exportFolder)
            }
            try fileManager.createDirectory(at: coversFolder, withIntermediateDirectories: true)
        } catch {
            print("Error creating directories: \(error)")
            return
        }

        var exportedBooks: [ExportBook] = []
        var imageCounter = 1
        
        let urls = [
            "https://gutendex.com/books/?page=1",
            "https://gutendex.com/books/?page=2",
            "https://gutendex.com/books/?page=3"
        ]
        
        // 2. Loop through pages
        for urlString in urls {
            await MainActor.run { statusMessage = "Fetching Page: \(urlString)..." }
            
            guard let url = URL(string: urlString),
                  let (data, _) = try? await URLSession.shared.data(from: url),
                  let response = try? JSONDecoder().decode(GutendexResponse.self, from: data) else {
                continue
            }
            
            // 3. Process each book
            for book in response.results {
                // Determine Genre
                let genre = mapGenre(bookshelves: book.bookshelves, subjects: book.subjects)
                
                // Determine Text URL (prefer UTF-8, fallback to ASCII)
                var contentText = "Text unavailable"
                if let textUrlString = book.formats["text/plain; charset=utf-8"] ?? book.formats["text/plain; charset=us-ascii"],
                   let textUrl = URL(string: textUrlString) {
                    if let (textData, _) = try? await URLSession.shared.data(from: textUrl) {
                        contentText = String(data: textData, encoding: .utf8) ?? "Encoding error"
                    }
                }
                
                // Handle Image
                let imageName = "Image \(imageCounter)"
                if let coverUrlString = book.formats["image/jpeg"],
                   let coverUrl = URL(string: coverUrlString),
                   let (imageData, _) = try? await URLSession.shared.data(from: coverUrl) {
                    
                    let imageFileUrl = coversFolder.appendingPathComponent("\(imageName).jpg")
                    try? imageData.write(to: imageFileUrl)
                }
                
                // Create Export Object
                let newBook = ExportBook(
                    bookId: UUID().uuidString,
                    title: book.title,
                    author: book.authors.first?.name ?? "Unknown",
                    genre: genre.rawValue,
                    descriptionText: book.summaries.first ?? "",
                    language: book.languages.first ?? "en",
                    coverImageUrl: imageName, // Stores "Image 1"
                    contentText: contentText,
                    price: 0.0,
                    averageRating: 0.0,
                    publicationDate: randomDateString()
                )
                
                exportedBooks.append(newBook)
                imageCounter += 1
                
                await MainActor.run { statusMessage = "Processed: \(book.title)" }
            }
        }
        
        // 4. Save JSON File
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonDate = try encoder.encode(exportedBooks)
            let jsonFileUrl = exportFolder.appendingPathComponent("books.json")
            try jsonDate.write(to: jsonFileUrl)
            
            await MainActor.run {
                statusMessage = "✅ DONE! Exported \(exportedBooks.count) books.\nLocation: \(exportFolder.path)"
                isProcessing = false
                print("FOLDER PATH: \(exportFolder.path)")
            }
        } catch {
            await MainActor.run { statusMessage = "Error saving JSON: \(error)" }
        }
    }
    
    // MARK: - Helpers
    func mapGenre(bookshelves: [String], subjects: [String]) -> CategoryEnum {
        let allTags = (bookshelves + subjects).map { $0.lowercased() }
        let combined = allTags.joined(separator: " ")
        
        if combined.contains("children") || combined.contains("juvenile") { return .kids }
        if combined.contains("thriller") || combined.contains("mystery") || combined.contains("crime") || combined.contains("gothic") { return .thriller }
        if combined.contains("fantasy") || combined.contains("sci-fi") { return .fantasy }
        if combined.contains("biography") || combined.contains("memoir") { return .biography }
        if combined.contains("business") || combined.contains("economics") { return .business }
        return .novels
    }
    
    func randomDateString() -> String {
        let day = Int.random(in: 1...28)
        let month = Int.random(in: 1...12)
        let year = Int.random(in: 1980...2023)
        // Simple ISO8601-ish format
        return String(format: "%04d-%02d-%02dT09:00:00Z", year, month, day)
    }
}

// MARK: - 4. SwiftUI View to Run the Script
struct ContentView: View {
    @StateObject private var exporter = BookExportManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Book JSON Generator")
                .font(.largeTitle)
                .bold()
            
            Text(exporter.statusMessage)
                .padding()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            
            if exporter.isProcessing {
                ProgressView()
            } else {
                Button("Start Download & Export") {
                    Task {
                        await exporter.startExport()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            
            if exporter.statusMessage.contains("DONE") {
                Text("Copy the file path printed in the console to find your files.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}
