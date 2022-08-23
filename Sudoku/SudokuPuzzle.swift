//
//  SudokuPuzzle.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/22/22.
//

import Foundation
import AppKit

struct SudokuPuzzle {
    struct Level: Hashable {
        internal init( level: Int, label: String ) {
            self.level = level
            self.label = label
        }
                
        let level: Int
        let label: String
    }
    
    static let supportedLevels = [
        Level(level: 3, label: "9x9" ),
        Level(level: 4, label: "16x16")
    ]
    
    let level: Int
    
    var image: NSImage {
        let fatLine = 5
        let thinLine = 3
        let cellSize = 5 * ( level + 1 ) + 20 * level
        let blockSize = level * cellSize + ( level - 1 ) * thinLine
        let size = level * blockSize + ( level + 1 ) * fatLine
        
        let nsImage = NSImage( size: NSSize( width: size, height: size ) )
        let imageRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8,
            samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: NSColorSpaceName.calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        )!
        nsImage.addRepresentation( imageRep )
        let cgImage = nsImage.cgImage( forProposedRect: nil, context: nil, hints: nil )!
        let context = CGContext(
            data: nil,
            width: Int( cgImage.width ),
            height: Int( cgImage.height ),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: cgImage.colorSpace!,
            bitmapInfo: cgImage.bitmapInfo.rawValue
        )!

        let white = CGColor( red: 1, green: 1, blue: 1, alpha: 1 )
        let black = CGColor( red: 0, green: 0, blue: 0, alpha: 1 )
        let grey  = CGColor( red: 0.95, green: 0.95, blue: 0.95, alpha: 1 )

        context.setFillColor( white )
        context.fill( CGRect( x: 0, y: 0, width: size, height: size ) )
        context.setFillColor( grey )
        for groupRow in 0 ..< level {
            for groupCol in stride( from: groupRow % 2 == 1 ? 0 : 1, to: level, by: 2 ) {
                let x = groupCol * blockSize + fatLine * ( groupCol + 1 )
                let y = groupRow * blockSize + fatLine * ( groupRow + 1 )
                context.fill( CGRect( x: x, y: y, width: blockSize, height: blockSize ) )
            }
        }
        
        context.setStrokeColor( black )
        context.setLineWidth( CGFloat( fatLine ) )
        let fatLineSpacing = level * cellSize + ( level - 1 ) * thinLine + fatLine
        for base in stride( from: fatLine / 2, to: size, by: fatLineSpacing ) {
            context.move( to: CGPoint( x: base, y: 0 ) )
            context.addLine( to: CGPoint( x: base, y: size ) )
            context.move( to: CGPoint( x: 0, y: base ) )
            context.addLine( to: CGPoint( x: size, y: base ) )
        }
        context.strokePath()
        
        context.setLineWidth( CGFloat( thinLine ) )
        for index in 0 ..< level * level {
            if !index.isMultiple( of: level ) {
                let fatLines = ( index / level + 1 )
                let thinLines = 2 * index / level + index % level - 1
                let base = fatLines * fatLine + thinLines * thinLine + index * cellSize + thinLine / 2
                context.move( to: CGPoint( x: base, y: 0 ) )
                context.addLine( to: CGPoint( x: base, y: size ) )
                context.move( to: CGPoint( x: 0, y: base ) )
                context.addLine( to: CGPoint( x: size, y: base ) )
            }
        }
        context.strokePath()

        let final = context.makeImage()!
        return NSImage( cgImage: final, size: NSSize(width: size / 2, height: size / 2 ) )
    }
}
