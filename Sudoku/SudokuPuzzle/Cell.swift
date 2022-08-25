//
//  SudokuCell.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/22/22.
//

import Foundation

extension SudokuPuzzle {
    class Cell {
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
