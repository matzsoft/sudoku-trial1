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
    @State private var selection: SudokuPuzzle.Cell?
    @State var overImg = false
    
    var body: some View {
        VStack( alignment: .leading, spacing: 0 ) {
            ForEach( document.rows ) { row in
                HStack( alignment: .top, spacing: 0 ) {
                    ForEach( row ) { cell in
                        Image( nsImage: document.image( cell: cell, selection: selection ) )
                            .onTapGesture { selection = cell }
                    }
                }
            }
        }
        .padding()
        .background( LinearGradient(
            gradient: Gradient(
                colors: [ .blue.opacity( 0.25 ), .cyan.opacity( 0.25 ), .green.opacity( 0.25 ) ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
            )
            .confirmationDialog( "Puzzle Level", isPresented: $needsLevel ) {
                ForEach( SudokuPuzzle.supportedLevels, id: \.self ) { level in
                    Button( level.label ) { document.level = level; needsLevel = false }
                }
            }
            message: {
                Text( "Select your puzzle size" )
            }
        )
        .focusable()
        .onAppear() {
            needsLevel = document.needsLevel
        }
        .onMoveCommand { direction in
            selection = document.moveCommand( direction: direction, selection: selection )
        }
//        KeyController()
    }
    
    // Original body from one view for the puzzle.  Kept here for possible reference for key events.
//    var blinko: some View {
//        Image( nsImage: $document.wrappedValue.image )
//            .confirmationDialog( "Puzzle Level", isPresented: $needsLevel ) {
//                ForEach( SudokuPuzzle.supportedLevels, id: \.self ) { level in
//                    Button( level.label ) { $document.wrappedValue.level = level; needsLevel = false }
//                }
//            }
//            message: {
//                Text( "Select your puzzle size" )
//            }
//            .onHover { overImg = $0 }
//            .padding()
//            .onAppear() {
//                needsLevel = $document.wrappedValue.needsLevel
//                NSEvent.addLocalMonitorForEvents( matching: [.leftMouseUp] ) {
//                    if overImg {
//                        let contentView = $0.window?.contentView
//                        let view = contentView?.subviews.first( where: { $0.frame != contentView?.frame } )
//                        let x = $0.locationInWindow.x - (view?.frame.minX)!
//                        let y = $0.locationInWindow.y - (view?.frame.minX)!
//                        //print( "mouse: \(x),\(y)" )
//                        $document.wrappedValue.puzzle?.mouseClick( point: CGPoint( x: x, y: y ) )
//                    }
//                    return $0
//                }
//            }
//            .background( LinearGradient(
//                gradient: Gradient(
//                    colors: [ .blue.opacity( 0.25 ), .cyan.opacity( 0.25 ), .green.opacity( 0.25 ) ]
//                ),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//                )
//            )
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(SudokuDocument()))
    }
}
