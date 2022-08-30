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
        UTType( importedAs: "com.example.plain-text" )
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
    var levelDescription: String { level?.label ?? "No level for the puzzle." }
    var rows: [[SudokuPuzzle.Cell]] { puzzle?.rows ?? [] }

    init( text: String = "Hello, world!" ) {
        self.text = text
    }

    static var readableContentTypes: [UTType] { [.text] }

    init( configuration: ReadConfiguration ) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String( data: data, encoding: .utf8 )
        else {
            throw CocoaError( .fileReadCorruptFile )
        }
        text = string
        let lines = string.split( separator: "\n" )
        let level = Int( sqrt( Double( lines.count ) ) )
        
        guard let levelInfo = SudokuPuzzle.supportedLevels.first( where: { $0.level == level } ),
              level * level == lines.count,
              lines.allSatisfy( { $0.count == lines.count } )
        else {
            throw CocoaError( .fileReadCorruptFile )
        }
        puzzle = SudokuPuzzle( levelInfo: levelInfo )
        for ( row, line ) in lines.enumerated() {
            for ( col, symbol ) in line.enumerated() {
                if let index = puzzle?.levelInfo.index( from: symbol ) {
                    puzzle?.rows[row][col].solved = index
                } else if symbol != "." {
                    throw CocoaError( .fileReadCorruptFile )
                }
            }
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
    
    func moveCommand( direction: MoveCommandDirection ) -> SudokuPuzzle.Cell {
        guard let puzzle = puzzle else { fatalError( "No puzzle available" ) }

        return puzzle.moveCommand( direction: direction )
    }
}
