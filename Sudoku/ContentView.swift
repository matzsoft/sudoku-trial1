//
//  ContentView.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/20/22.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: SudokuDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(SudokuDocument()))
    }
}
