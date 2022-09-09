//
//  SudokuDocument.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/20/22.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var exampleText: UTType {
        UTType( importedAs: "com.example.plain-text" )
    }
}


class SpeechDelegate: NSObject, NSSpeechSynthesizerDelegate {
    let document: SudokuDocument
    
    internal init( document: SudokuDocument ) {
        self.document = document
    }
    
    func speechSynthesizer( _ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool ) {
        guard document.isSpeaking else { return }
        guard !document.speechQueue.isEmpty else {
            document.isSpeaking = false
            return
        }
        
        let command = document.speechQueue.removeFirst()
        
        if document.moveTo( row: command.row, col: command.col ) {
//            viewController?.view.needsDisplay = true
        }
        
        sender.startSpeaking( command.string )
    }
}


final class SudokuDocument: ReferenceFileDocument {
    typealias Snapshot = Data
    
    var puzzle: SudokuPuzzle?
    var isSpeaking = false
    var speechQueue: [ SpeechCommand ] = []
    var speechDelegate: SpeechDelegate?

    @Published var selection: SudokuPuzzle.Cell?
    @Published var penciledCount = 0
    
    var level: SudokuPuzzle.Level? {
        get { puzzle?.levelInfo }
        set { puzzle = SudokuPuzzle( levelInfo: newValue! ) }
    }
    var needsLevel: Bool { level == nil }
    var levelDescription: String { level?.label ?? "No level for the puzzle." }
    var rows: [[SudokuPuzzle.Cell]] { puzzle?.rows ?? [] }

    lazy var synthesizer: NSSpeechSynthesizer = {
        let synthesizer = NSSpeechSynthesizer()
        let voices = NSSpeechSynthesizer.availableVoices
        let desiredVoiceName = "com.apple.speech.synthesis.voice.Alex"
        let desiredVoice = NSSpeechSynthesizer.VoiceName( rawValue: desiredVoiceName )
        
        if let voice = voices.first( where: { $0 == desiredVoice } ) {
            synthesizer.setVoice( voice )
        }
        
        synthesizer.usesFeedbackWindow = true
        speechDelegate = SpeechDelegate( document: self )
        synthesizer.delegate = speechDelegate
        return synthesizer
    }()
    
    init( text: String = "Hello, world!" ) {
    }
    
    init() {
    }

    static var readableContentTypes: [UTType] { [.text] }

    init( configuration: ReadConfiguration ) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String( data: data, encoding: .utf8 )
        else {
            throw CocoaError( .fileReadCorruptFile )
        }
        let lines = string.split( separator: "\n" )
        let level = Int( sqrt( Double( lines.count ) ) )
        
        guard let levelInfo = SudokuPuzzle.supportedLevels.first( where: { $0.level == level } ),
              level * level == lines.count,
              lines.allSatisfy( { $0.count == lines.count } )
        else {
            throw CocoaError( .fileReadCorruptFile )
        }
        puzzle = SudokuPuzzle( levelInfo: levelInfo )
        for ( row, line ) in lines.enumerated() {
            for ( col, symbol ) in line.enumerated() {
                if let index = puzzle?.levelInfo.index( from: symbol ) {
                    puzzle?.rows[row][col].solved = index
                } else if symbol != "." {
                    throw CocoaError( .fileReadCorruptFile )
                }
            }
        }
    }
    
    func snapshot( contentType: UTType ) throws -> Data {
        ( puzzle?.asString ?? "" ).data( using: .utf8 )!
    }
    
    func fileWrapper( snapshot: Data, configuration: WriteConfiguration ) throws -> FileWrapper {
        FileWrapper( regularFileWithContents: snapshot )
    }
    
    func fileWrapper( configuration: WriteConfiguration ) throws -> FileWrapper {
        return .init( regularFileWithContents: try snapshot( contentType: .text ) )
    }
    
    func image( cell: SudokuPuzzle.Cell ) -> NSImage {
        guard let puzzle = puzzle else { return NSImage( named: NSImage.cautionName )! }
        return puzzle.drawer.image( cell: cell, puzzle: puzzle, selection: selection )
    }
    
    @discardableResult func moveTo( row: Int, col: Int ) -> Bool {
        guard 0 <= row && row < rows.count else { return false }
        guard 0 <= col && col < rows[0].count else { return false }
        
        selection = rows[row][col]
        return true
    }
    
    func moveCommand( direction: MoveCommandDirection ) -> Void {
        guard puzzle != nil else { fatalError( "No puzzle available" ) }
        guard selection != nil else {
            guard moveTo( row: 0, col: 0 ) else { fatalError( "Cannot set selection" ) }
            return
        }
        
        switch direction {
        case .up:
            moveUp()
        case .down:
            moveDown()
        case .left:
            moveLeft()
        case .right:
            moveRight()
        @unknown default:
            NSSound.beep()
        }
    }

    func audioVerify() {
        guard let puzzle = puzzle else { NSSound.beep(); return }

        if speechQueue.isEmpty {
            speechQueue = puzzle.audioVerify()
        }
        isSpeaking = true
        
        let synthesizer = synthesizer
        
        speechDelegate!.speechSynthesizer( synthesizer, didFinishSpeaking: true )
    }
    
    func stopSpeaking() -> Bool {
        let wasSpeaking = isSpeaking
        
        isSpeaking = false
        return wasSpeaking
    }

    func handleKeyEvent( event: NSEvent, undoManager: UndoManager? ) -> NSEvent? {
        if event.modifierFlags.contains( .command ) { return event }
        if event.modifierFlags.contains( .option ) { return event }
        guard let characters = event.charactersIgnoringModifiers else { return event }
        guard let selection = selection else { return event }
        guard let levelInfo = level else { return event }

        if characters.count == 1 {
            let character = characters.uppercased().first!
            
            if let index = levelInfo.index( from: character ) {
                if !event.modifierFlags.contains( .control ) {
                    let oldValue = selection.solved
                    if oldValue != index {
                        undoManager?.registerUndo( withTarget: self ) { document in
                            document.selection = selection
                            selection.solved = oldValue
                        }
                    }
                    selection.solved = index
                    moveRight()
                    return nil
                } else {
                    if selection.solved != nil { return event }
                    if !selection.penciled.insert( index ).inserted {
                        selection.penciled.remove( index )
                    }
                    penciledCount = puzzle!.penciledCount
                    return nil
                }
            }
            
            if character == "." || character == " " {
                selection.solved = nil
                moveRight()
                return nil
            }
            
            // This handles escape
            if event.keyCode == 53 {
                if stopSpeaking() { return nil }
            }
            
            switch event.specialKey {
            case NSEvent.SpecialKey.backspace, NSEvent.SpecialKey.delete:
                selection.solved = nil
                moveLeft()
                return nil
            case NSEvent.SpecialKey.deleteForward:
                selection.solved = nil
                moveRight()
                return nil
            case NSEvent.SpecialKey.tab:
                let newCol = ( selection.col + levelInfo.level ) / levelInfo.level * levelInfo.level
                if !moveTo( row: selection.row, col: newCol ) {
                    moveTo( row: selection.row, col: 0 )
                    moveDown()
                }
                return nil
            case NSEvent.SpecialKey.backTab:
                if selection.col > 0 {
                    let newCol = ( selection.col - 1 ) / levelInfo.level * levelInfo.level
                    moveTo( row: selection.row, col: newCol )
                } else {
                    moveTo( row: selection.row, col: levelInfo.limit - levelInfo.level )
                    moveUp()
                }
                return nil
            case NSEvent.SpecialKey.carriageReturn, NSEvent.SpecialKey.newline, NSEvent.SpecialKey.enter:
                moveTo( row: selection.row, col: 0 )
                moveDown()
                return nil
            case NSEvent.SpecialKey.home:
                moveTo( row: 0, col: 0 )
                return nil
            case NSEvent.SpecialKey.end:
                let limit = levelInfo.limit
                moveTo( row: limit - 1, col: limit - 1 )
                return nil
            default:
                break
            }
        }
        return event
    }
    
    func moveUp() -> Void {
        guard let selection = selection else { return }
        guard let limit = level?.limit else { return }
        if moveTo( row: selection.row - 1, col: selection.col ) { return }
        moveTo( row: limit - 1, col: selection.col )
    }
    
    func moveDown() -> Void {
        guard let selection = selection else { return }
        if moveTo( row: selection.row + 1, col: selection.col ) { return }
        moveTo( row: 0, col: selection.col )
    }
    
    func moveLeft() -> Void {
        guard let selection = selection else { return }
        guard let limit = level?.limit else { return }
        if moveTo( row: selection.row, col: selection.col - 1 ) { return }
        if moveTo( row: selection.row - 1, col: limit - 1 ) { return }
        moveTo( row: limit - 1, col: limit - 1 )
    }

    func moveRight() -> Void {
        guard let selection = selection else { return }
        if moveTo( row: selection.row, col: selection.col + 1 ) { return }
        if moveTo( row: selection.row + 1, col: 0 ) { return }
        moveTo( row: 0, col: 0 )
    }
}
