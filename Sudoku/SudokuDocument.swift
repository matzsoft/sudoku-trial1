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
    
    var level: SudokuPuzzle.Level? {
        get { puzzle?.levelInfo }
        set { puzzle = SudokuPuzzle( levelInfo: newValue! ) }
    }
    var needsLevel: Bool { level == nil }
    var levelDescription: String {
        guard let level = level else {
            return "No level for the puzzle."
        }

        return level.label
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
