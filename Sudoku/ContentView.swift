//
//  ContentView.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/20/22.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: SudokuDocument
    @State private var needsLevel = true
    
    var body: some View {
        Image( nsImage: $document.wrappedValue.image )
            .padding()
            .confirmationDialog( "Puzzle Level", isPresented: $needsLevel ) {
                ForEach( SudokuPuzzle.supportedLevels, id: \.self ) { level in
                    Button( level.label ) { $document.wrappedValue.level = level.level; needsLevel = false }
                }
            }
            message: {
                Text( "Select your puzzle size" )
            }
            .onAppear() { needsLevel = $document.wrappedValue.needsLevel }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(SudokuDocument()))
    }
}
