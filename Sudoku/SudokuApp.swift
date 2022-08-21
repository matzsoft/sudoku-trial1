//
//  SudokuApp.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/20/22.
//

import SwiftUI

@main
struct SudokuApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: SudokuDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
