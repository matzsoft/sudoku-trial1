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
        DocumentGroup( newDocument: SudokuDocument.init ) { file in
            ContentView( document: file.document )
        }
//        .commands {
//            CommandGroup( replacing: .newItem ) {
//                Menu( "New" ) {
//                    Button( "9x9", action: {} )
//                        .keyboardShortcut( "n" )
//                    Button( "16x16", action: {} )
//                        .keyboardShortcut( "n", modifiers: [ .command, .shift ] )
//                }
//                Button( "Open", action: {} )
//                    .keyboardShortcut( "o" )
//                Button( "Open Recent...", action: {} )
//            }
//        }
    }
}
