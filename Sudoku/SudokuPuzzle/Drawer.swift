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

        let cellSize: Int
        let blockSize: Int
        let size: Int
        let cellInteriorSize: Int
        let solvedFont: CFDictionary
        let context: CGContext

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
        
        init( level: Int ) {
            cellSize = Drawer.cellMargin * ( level + 1 ) + Drawer.miniCellSize * level
            blockSize = level * cellSize + ( level - 1 ) * Drawer.thinLine
            size = level * blockSize + ( level + 1 ) * Drawer.fatLine
            cellInteriorSize = cellSize - 2 * Drawer.cellMargin
            solvedFont = Drawer.setupFontAttributes(
                color: Drawer.textColor, fontSize: CGFloat( cellSize - 2 * Drawer.cellMargin ) )

            let nsImage = NSImage( size: NSSize( width: size, height: size ) )
            let imageRep = NSBitmapImageRep(
                bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8,
                samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                colorSpaceName: NSColorSpaceName.calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
            )!
            nsImage.addRepresentation( imageRep )
            let cgImage = nsImage.cgImage( forProposedRect: nil, context: nil, hints: nil )!
            context = CGContext(
                data: nil,
                width: Int( cgImage.width ),
                height: Int( cgImage.height ),
                bitsPerComponent: cgImage.bitsPerComponent,
                bytesPerRow: 0,
                space: cgImage.colorSpace!,
                bitmapInfo: cgImage.bitmapInfo.rawValue
            )!
        }
        
        func cell( for point: CGPoint, puzzle: SudokuPuzzle ) -> Cell? {
            let point = CGPoint( x: 2 * point.x, y: 2 * point.y )
            
            return puzzle.cells.first { cellRect( cell: $0, puzzle: puzzle ).contains(point ) }
        }
        
        func image( puzzle: SudokuPuzzle ) -> NSImage {
            // Create the image to draw in.
            let level = puzzle.level

            // Draw the fat lines
            context.clear( CGRect( x: 0, y: 0, width: size, height: size ) )
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
            for index in 0 ..< puzzle.limit {
                if !index.isMultiple( of: level ) {
                    let fatLines = ( index / level + 1 ) * Drawer.fatLine
                    let thinLineCount = ( level - 1 ) * ( index / level ) + index % level - 1
                    let thinLines = thinLineCount * Drawer.thinLine
                    let base = fatLines + thinLines + index * cellSize + Drawer.thinLine / 2
                    context.move( to: CGPoint( x: base, y: 0 ) )
                    context.addLine( to: CGPoint( x: base, y: size ) )
                    context.move( to: CGPoint( x: 0, y: base ) )
                    context.addLine( to: CGPoint( x: size, y: base ) )
                }
            }
            context.strokePath()

            // Draw the cell contents
            for cell in puzzle.cells {
                let rect = cellRect( cell: cell, puzzle: puzzle )
                
                context.saveGState()
                context.translateBy( x: rect.minX, y: rect.minY )
                draw( cell: cell, puzzle: puzzle )
                context.restoreGState()
            }
            
            let final = context.makeImage()!
            return NSImage( cgImage: final, size: NSSize(width: size / 2, height: size / 2 ) )
        }
        
        func cellRect( cell: Cell, puzzle: SudokuPuzzle ) -> CGRect {
            let groupRow = puzzle.groupRow( cell: cell )
            let groupCol = puzzle.groupCol( cell: cell )
            let groupX = groupCol * blockSize + Drawer.fatLine * ( groupCol + 1 )
            let groupY = groupRow * blockSize + Drawer.fatLine * ( groupRow + 1 )
            let cellX  = groupX + ( cell.col % puzzle.level ) * ( cellSize + Drawer.thinLine )
            let cellY  = groupY + ( cell.row % puzzle.level ) * ( cellSize + Drawer.thinLine )
            
            return CGRect( x: cellX, y: cellY, width: cellSize, height: cellSize )
        }
        
        func penciledRect( penciled: Int, puzzle: SudokuPuzzle ) -> CGRect {
            let skipOver = Drawer.miniCellSize + Drawer.cellMargin
            return CGRect(
                x: Drawer.cellMargin + penciled % puzzle.level * skipOver,
                y: Drawer.cellMargin + penciled / puzzle.level * skipOver,
                width: Drawer.miniCellSize, height: Drawer.miniCellSize
            )
        }
        
        func draw( symbol: Character, rect: CGRect, font: CFDictionary ) -> Void {
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
        
        func draw( cell: Cell, puzzle: SudokuPuzzle ) -> Void {
            if cell !== puzzle.selection {
                if ( puzzle.groupRow( cell: cell ) + puzzle.groupCol( cell: cell ) ).isMultiple( of: 2 ) {
                    context.setFillColor( Drawer.checkerboardLightColor )
                } else {
                    context.setFillColor( Drawer.checkerboardDarkColor )
                }
                context.fill( CGRect( x: 0, y: 0, width: cellSize, height: cellSize ) )
            }
            
            if let solved = cell.solved {
                // Draw the solved number
                let symbol = puzzle.levelInfo.symbol( from: solved ) ?? "?"
                let rect   = CGRect(
                    x: Drawer.cellMargin, y: Drawer.cellMargin,
                    width: cellInteriorSize, height: cellInteriorSize
                )
                
                draw( symbol: symbol, rect: rect, font: solvedFont )
                return
            }
            
            if !cell.penciled.isEmpty {
                // Draw all the penciled.
                for penciled in cell.penciled {
                    let symbol = puzzle.levelInfo.symbol( from: penciled ) ?? "?"
                    let rect   = penciledRect( penciled: penciled, puzzle: puzzle )

                    draw( symbol: symbol, rect: rect, font: Drawer.penciledFont )
                }
                return
            }
        }
    }
}
