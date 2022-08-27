//
//  SudokuPuzzle.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/22/22.
//

import Foundation
import AppKit

struct SudokuPuzzle {
    static let supportedLevels = [
        Level( level: 3, label: "9x9" ),
        Level( level: 4, label: "16x16")
    ]
    
    let levelInfo: Level
    let level: Int
    let limit: Int
    let rows: [[Cell]]
    let drawer: Drawer
    var selection: Cell?
    
    var image: NSImage { drawer.image( puzzle: self ) }
    var cells: [Cell] { rows.flatMap { $0 } }
    
    init( levelInfo: Level ) {
        self.levelInfo = levelInfo
        level = levelInfo.level
        limit = levelInfo.limit
        drawer = Drawer( levelInfo: levelInfo )
        
        rows = ( 0 ..< levelInfo.limit ).map { row in
            ( 0 ..< levelInfo.limit ).map { col in
                Cell( row: row, col: col )
            }
        }
    }
    
    func groupRow( cell: Cell ) -> Int { cell.row / level }
    func groupCol( cell: Cell ) -> Int { cell.col / level }
    
    mutating func mouseClick( point: CGPoint ) -> Void {
        guard let cell = drawer.cell( for: point, puzzle: self ) else {
            NSSound.beep()
            return
        }
        
        selection = cell
    }
}
