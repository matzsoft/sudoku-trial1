//
//  SudokuApp.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/20/22.
//

import SwiftUI

@main
struct SudokuApp: App {
    @FocusedValue( \.focusedDocument ) var focusedDocument: SudokuDocument?

    var body: some Scene {
        DocumentGroup( newDocument: SudokuDocument.init ) { file in
            ContentView( document: file.document )
                .focusedSceneValue( \.focusedDocument, file.document )
        }
        .commands {
            CommandGroup( after: .saveItem ) {
                Button( "Audio Verify" ) {
                    guard let document = focusedDocument else { NSSound.beep(); return }
                    document.audioVerify()
                }
            }
        }
    }
}

extension FocusedValues {
    struct DocumentFocusedValueKey: FocusedValueKey {
        typealias Value = SudokuDocument
    }

    var focusedDocument: DocumentFocusedValueKey.Value? {
        get { return self[DocumentFocusedValueKey.self] }
        set { self[DocumentFocusedValueKey.self] = newValue }
    }
}
