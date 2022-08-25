//
//  SudokuPuzzleDrawer.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/24/22.
//

import Foundation
import AppKit
import CoreText

extension SudokuPuzzle {
    struct Drawer {
        static let checkerboardLightColor = CGColor( red: 1, green: 1, blue: 1, alpha: 1 )
        static let checkerboardDarkColor  = CGColor( red: 0.90, green: 0.90, blue: 0.90, alpha: 1 )
        static let lineColor = CGColor( red: 0, green: 0, blue: 0, alpha: 1 )
        static let textColor = CGColor( red: 0, green: 0, blue: 0, alpha: 1 )
        static let fatLine      = 5
        static let thinLine     = 3
        static let cellMargin   = 5
        static let miniCellSize = 20
        static let penciledFont = setupFontAttributes( color: textColor, fontSize: CGFloat( miniCellSize ) )

        let levelInfo: Level
        let cellSize: Int
        let blockSize: Int
        let size: Int
        let cellInteriorSize: Int
        let solvedFont: CFDictionary

        static func setupFontAttributes( color: CGColor, fontSize: CGFloat ) -> CFDictionary {
            let fontAttributes = [
                String( kCTFontFamilyNameAttribute ) : "Arial",
                String( kCTFontStyleNameAttribute )  : "Regular",
                String( kCTFontSizeAttribute )       : fontSize
                ] as CFDictionary
            let fontDescriptor = CTFontDescriptorCreateWithAttributes( fontAttributes )
            let font           = CTFontCreateWithFontDescriptor( fontDescriptor, 0.0, nil )
            
            let attributes = [
                String( kCTFontAttributeName )            : font,
                String( kCTForegroundColorAttributeName ) : color
            ] as CFDictionary
            
            return attributes
        }
        
        init( levelInfo: Level ) {
            let level = levelInfo.level
            
            self.levelInfo = levelInfo

            cellSize = Drawer.cellMargin * ( level + 1 ) + Drawer.miniCellSize * level
            blockSize = level * cellSize + ( level - 1 ) * Drawer.thinLine
            size = level * blockSize + ( level + 1 ) * Drawer.fatLine
            cellInteriorSize = cellSize - 2 * Drawer.cellMargin
            solvedFont = Drawer.setupFontAttributes(
                color: Drawer.textColor, fontSize: CGFloat( cellSize - 2 * Drawer.cellMargin ) )
        }
        
        func image( puzzle: SudokuPuzzle ) -> NSImage {
            // Create the image to draw in.
            let level = levelInfo.level
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

            // Draw the checkerboard pattern
            context.setFillColor( Drawer.checkerboardLightColor )
            context.fill( CGRect( x: 0, y: 0, width: size, height: size ) )
            context.setFillColor( Drawer.checkerboardDarkColor )
            for groupRow in 0 ..< level {
                for groupCol in stride( from: groupRow % 2 == 1 ? 0 : 1, to: level, by: 2 ) {
                    let x = groupCol * blockSize + Drawer.fatLine * ( groupCol + 1 )
                    let y = groupRow * blockSize + Drawer.fatLine * ( groupRow + 1 )
                    context.fill( CGRect( x: x, y: y, width: blockSize, height: blockSize ) )
                }
            }
            
            // Draw the fat lines
            context.setStrokeColor( Drawer.lineColor )
            context.setLineWidth( CGFloat( Drawer.fatLine ) )
            let fatLineSpacing = level * cellSize + ( level - 1 ) * Drawer.thinLine + Drawer.fatLine
            for base in stride( from: Drawer.fatLine / 2, to: size, by: fatLineSpacing ) {
                context.move( to: CGPoint( x: base, y: 0 ) )
                context.addLine( to: CGPoint( x: base, y: size ) )
                context.move( to: CGPoint( x: 0, y: base ) )
                context.addLine( to: CGPoint( x: size, y: base ) )
            }
            context.strokePath()
            
            // Draw the thin lines
            context.setLineWidth( CGFloat( Drawer.thinLine ) )
            for index in 0 ..< level * level {
                if !index.isMultiple( of: level ) {
                    let fatLines = ( index / level + 1 )
                    let thinLines = 2 * index / level + index % level - 1
                    let base = fatLines * Drawer.fatLine + thinLines * Drawer.thinLine + index * cellSize + Drawer.thinLine / 2
                    context.move( to: CGPoint( x: base, y: 0 ) )
                    context.addLine( to: CGPoint( x: base, y: size ) )
                    context.move( to: CGPoint( x: 0, y: base ) )
                    context.addLine( to: CGPoint( x: size, y: base ) )
                }
            }
            context.strokePath()

            // Draw the cell contents
            for cell in puzzle.cells {
                draw( cell: cell, context: context )
            }
            
            let final = context.makeImage()!
            return NSImage( cgImage: final, size: NSSize(width: size / 2, height: size / 2 ) )
        }
        
        func penciledRect( penciled: Int ) -> CGRect {
            let skipOver = Drawer.miniCellSize + Drawer.cellMargin
            return CGRect(
                x: Drawer.cellMargin + penciled % levelInfo.level * skipOver,
                y: Drawer.cellMargin + penciled / levelInfo.level * skipOver,
                width: Drawer.miniCellSize, height: Drawer.miniCellSize
            )
        }
        
        func moveTo( cell: Cell, context: CGContext ) -> Void {
            let groupRow = cell.row / levelInfo.level
            let groupCol = cell.col / levelInfo.level
            let groupX = groupCol * blockSize + Drawer.fatLine * ( groupCol + 1 )
            let groupY = groupRow * blockSize + Drawer.fatLine * ( groupRow + 1 )
            let cellX  = CGFloat( groupX + ( cell.col % levelInfo.level ) * ( cellSize + Drawer.thinLine ) )
            let cellY  = CGFloat( groupY + ( cell.row % levelInfo.level ) * ( cellSize + Drawer.thinLine ) )
            
            context.translateBy( x: cellX, y: cellY )
        }
        
        func draw( symbol: Character, rect: CGRect, font: CFDictionary, context: CGContext ) -> Void {
            let symbol     = String( symbol ) as CFString
            let attrString = CFAttributedStringCreate( kCFAllocatorDefault, symbol, font )
            let line       = CTLineCreateWithAttributedString( attrString! )
            let textSize   = CTLineGetImageBounds( line, context )
            let position   = CGPoint(
                x: rect.minX + ( rect.width - textSize.width ) / 2,
                y: rect.minY + ( rect.height - textSize.height ) / 2
            )

            context.textPosition = position
            CTLineDraw( line, context )
        }
        
        func draw( cell: Cell, context: CGContext ) -> Void {
            if let solved = cell.solved {
                // Draw the solved number
                let symbol = levelInfo.symbol( from: solved ) ?? "?"
                let rect   = CGRect(
                    x: Drawer.cellMargin, y: Drawer.cellMargin,
                    width: cellInteriorSize, height: cellInteriorSize
                )
                
                context.saveGState()
                moveTo( cell: cell, context: context )
                draw( symbol: symbol, rect: rect, font: solvedFont, context: context )
                context.restoreGState()
                return
            }
            
            if !cell.penciled.isEmpty {
                // Draw all the penciled.
                context.saveGState()
                moveTo( cell: cell, context: context )
                for penciled in cell.penciled {
                    let symbol = levelInfo.symbol( from: penciled ) ?? "?"
                    let rect   = penciledRect( penciled: penciled )

                    draw( symbol: symbol, rect: rect, font: Drawer.penciledFont, context: context )
                }
                context.restoreGState()
                return
            }
        }
    }
}
