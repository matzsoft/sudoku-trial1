//
//  SudokuPuzzle.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/22/22.
//

import Foundation
import AppKit
import SwiftUI

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
    
    var cells: [Cell] { rows.flatMap { $0 } }
    
    init( levelInfo: Level ) {
        self.levelInfo = levelInfo
        level = levelInfo.level
        limit = levelInfo.limit
        drawer = Drawer( level: level )
        
        rows = ( 0 ..< levelInfo.limit ).map { row in
            ( 0 ..< levelInfo.limit ).map { col in
                Cell( row: row, col: col )
            }
        }
    }
    
    func groupRow( cell: Cell ) -> Int { cell.row / level }
    func groupCol( cell: Cell ) -> Int { cell.col / level }
    
    func moveCommand( direction: MoveCommandDirection ) -> Cell {
        guard let selection = selection else { return rows[0][0] }

        switch direction {
        case .up:
            if selection.row > 0 {
                return rows[ selection.row - 1 ][ selection.col ]
            }
        case .down:
            if selection.row < limit - 1 {
                return rows[ selection.row + 1 ][ selection.col ]
            }
        case .left:
            if selection.col > 0 {
                return rows[ selection.row ][ selection.col - 1 ]
            }
        case .right:
            if selection.col < limit - 1 {
                return rows[ selection.row ][ selection.col + 1 ]
            }
        @unknown default:
            fatalError( "Unknown move direction" )
        }
        NSSound.beep()
        return selection
    }
}
