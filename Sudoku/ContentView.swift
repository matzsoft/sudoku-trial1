//
//  ContentView.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/20/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var document: SudokuDocument
    @State private var needsLevel = true
    @State private var keyDownMonitor: Any?
    @State private var window: NSWindow?
    
    var body: some View {
        VStack( alignment: .leading, spacing: 0 ) {
            ForEach( document.rows ) { row in
                HStack( alignment: .top, spacing: 0 ) {
                    ForEach( row ) { cell in
                        Image( nsImage: document.image( cell: cell ) )
                            .onTapGesture { document.selection = cell }
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
            DispatchQueue.main.async {
                window = NSApp.windows.last
            }
            keyDownMonitor = NSEvent.addLocalMonitorForEvents( matching: [.keyDown] ) {
                return $0.window == window ? document.handleKeyEvent( event: $0 ) : $0
            }
        }
        .onDisappear() {
            NSEvent.removeMonitor( keyDownMonitor! )
        }
        .onMoveCommand { direction in
            document.moveCommand( direction: direction )
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView( document: .constant( SudokuDocument() ) )
//    }
//}
