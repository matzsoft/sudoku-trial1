//
//  SudokuCell.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/22/22.
//

import Foundation

extension SudokuPuzzle {
    class Cell: Hashable, Identifiable {
        static func == ( lhs: SudokuPuzzle.Cell, rhs: SudokuPuzzle.Cell ) -> Bool {
            return lhs.row == rhs.row && lhs.col == rhs.col
        }
        
        func hash( into hasher: inout Hasher ) {
            hasher.combine( row )
            hasher.combine( col )
        }

        var solved: Int?
        var penciled: [Int] = []
        let row: Int
        let col: Int
        
        init( solved: Int? = nil, penciled: [Int] = [], row: Int, col: Int) {
            self.solved = solved
            self.penciled = penciled
            self.row = row
            self.col = col
        }
    }
}

extension Array: Identifiable where Element: Hashable {
    public var id: Int {
        self[0].hashValue
    }
    
    
}
