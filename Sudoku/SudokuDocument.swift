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
    
    var text: String
    var puzzle: SudokuPuzzle?
    var isSpeaking = false
    var speechQueue: [ SpeechCommand ] = []
    var speechDelegate: SpeechDelegate?

    @Published var selection: SudokuPuzzle.Cell?
    
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
        let desiredVoice = NSSpeechSynthesizer.VoiceName(rawValue: desiredVoiceName)
        
        if let voice = voices.first(where: { $0 == desiredVoice } ) {
            synthesizer.setVoice(voice)
        }
        
        synthesizer.usesFeedbackWindow = true
        speechDelegate = SpeechDelegate( document: self )
        synthesizer.delegate = speechDelegate
        return synthesizer
    }()
    
    init( text: String = "Hello, world!" ) {
        self.text = text
    }
    
    init() {
        text = "Goodbye, World!"
    }

    static var readableContentTypes: [UTType] { [.text] }

    init( configuration: ReadConfiguration ) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String( data: data, encoding: .utf8 )
        else {
            throw CocoaError( .fileReadCorruptFile )
        }
        text = string
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
        let data = text.data( using: .utf8 )!
        return .init( regularFileWithContents: data )
    }
    
    func image( cell: SudokuPuzzle.Cell ) -> NSImage {
        guard let puzzle = puzzle else { return NSImage( named: NSImage.cautionName )! }
        return puzzle.drawer.image( cell: cell, puzzle: puzzle, selection: selection )
    }
    
    func moveTo( row: Int, col: Int ) -> Bool {
        guard 0 <= row && row < rows.count else { return false }
        guard 0 <= col && col < rows[0].count else { return false }
        
        selection = rows[row][col]
        return true
    }
    
    func moveCommand( direction: MoveCommandDirection ) -> Void {
        guard puzzle != nil else { fatalError( "No puzzle available" ) }
        guard let selection = selection else {
            guard moveTo( row: 0, col: 0 ) else { fatalError( "Cannot set selection" ) }
            return
        }
        
        let oldSelection = selection

        switch direction {
        case .up:
            _ = moveTo( row: selection.row - 1, col: selection.col )
        case .down:
            _ = moveTo( row: selection.row + 1, col: selection.col )
        case .left:
            _ = moveTo( row: selection.row, col: selection.col - 1 )
        case .right:
            _ = moveTo( row: selection.row, col: selection.col + 1 )
        @unknown default:
            NSSound.beep()
        }

        if self.selection == oldSelection {
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
    
}
