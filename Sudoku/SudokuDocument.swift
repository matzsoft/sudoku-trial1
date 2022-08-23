//
//  SudokuDocument.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/20/22.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var exampleText: UTType {
        UTType(importedAs: "com.example.plain-text")
    }
}

struct SudokuDocument: FileDocument {
    var text: String
    var puzzle: SudokuPuzzle?
    
    var level: Int? {
        get { puzzle?.level }
        set { puzzle = SudokuPuzzle( level: newValue! ) }
    }
    var needsLevel: Bool { level == nil }
    var levelDescription: String {
        guard let level = level else {
            return "No level for the puzzle."
        }

        switch level {
        case 3:
            return "9x9"
        case 4:
            return "16x16"
        default:
            return "Unknown puzzle level \(level)."
        }
    }
    var image: NSImage {
        guard let puzzle = puzzle else {
            return NSImage( named: NSImage.cautionName )!
        }
        return puzzle.image
    }

    init(text: String = "Hello, world!") {
        self.text = text
    }

    static var readableContentTypes: [UTType] { [.exampleText] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}
