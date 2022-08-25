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
        let levelInfo: Level
        let checkerboardLightColor = CGColor( red: 1, green: 1, blue: 1, alpha: 1 )
        let checkerboardDarkColor  = CGColor( red: 0.90, green: 0.90, blue: 0.90, alpha: 1 )
        let lineColor = CGColor( red: 0, green: 0, blue: 0, alpha: 1 )
        let textColor = CGColor( red: 0, green: 0, blue: 0, alpha: 1 )
        let fatLine      = 5
        let thinLine     = 3
        let cellMargin   = 5
        let miniCellSize = 20
        let cellSize: Int
        let blockSize: Int
        let size: Int
        let solvedFont: CFDictionary
        let penciledFont: CFDictionary

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

            cellSize = cellMargin * ( level + 1 ) + miniCellSize * level
            blockSize = level * cellSize + ( level - 1 ) * thinLine
            size = level * blockSize + ( level + 1 ) * fatLine
            solvedFont = Drawer.setupFontAttributes(
                color: textColor, fontSize: CGFloat( cellSize - 2 * cellMargin ) )
            penciledFont = Drawer.setupFontAttributes(
                color: textColor, fontSize: CGFloat( miniCellSize ) )
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
            context.setFillColor( checkerboardLightColor )
            context.fill( CGRect( x: 0, y: 0, width: size, height: size ) )
            context.setFillColor( checkerboardDarkColor )
            for groupRow in 0 ..< level {
                for groupCol in stride( from: groupRow % 2 == 1 ? 0 : 1, to: level, by: 2 ) {
                    let x = groupCol * blockSize + fatLine * ( groupCol + 1 )
                    let y = groupRow * blockSize + fatLine * ( groupRow + 1 )
                    context.fill( CGRect( x: x, y: y, width: blockSize, height: blockSize ) )
                }
            }
            
            // Draw the fat lines
            context.setStrokeColor( lineColor )
            context.setLineWidth( CGFloat( fatLine ) )
            let fatLineSpacing = level * cellSize + ( level - 1 ) * thinLine + fatLine
            for base in stride( from: fatLine / 2, to: size, by: fatLineSpacing ) {
                context.move( to: CGPoint( x: base, y: 0 ) )
                context.addLine( to: CGPoint( x: base, y: size ) )
                context.move( to: CGPoint( x: 0, y: base ) )
                context.addLine( to: CGPoint( x: size, y: base ) )
            }
            context.strokePath()
            
            // Draw the thin lines
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

            // Draw the cell contents
            for cell in puzzle.cells {
                let groupRow = cell.row / level
                let groupCol = cell.col / level
                let groupX = groupCol * blockSize + fatLine * ( groupCol + 1 )
                let groupY = groupRow * blockSize + fatLine * ( groupRow + 1 )
                let cellX  = CGFloat( groupX + ( cell.col % level ) * ( cellSize + thinLine ) )
                let cellY  = CGFloat( groupY + ( cell.row % level ) * ( cellSize + thinLine ) )
                
                context.saveGState()
                context.translateBy( x: cellX, y: cellY )
                draw( cell: cell, context: context )
                context.restoreGState()
            }
            
            let final = context.makeImage()!
            return NSImage( cgImage: final, size: NSSize(width: size / 2, height: size / 2 ) )
        }
        
        func cellRect() -> CGRect {
            CGRect(
                x: cellMargin, y: cellMargin,
                width: cellSize - 2 * cellMargin, height: cellSize - 2 * cellMargin
            )
        }
        
        func penciledRect( penciled: Int ) -> CGRect {
            let rect = cellRect()
            
            return CGRect(
                x: Int( rect.minX ) + penciled % levelInfo.level * ( miniCellSize + cellMargin ),
                y: Int( rect.minY ) + penciled / levelInfo.level * ( miniCellSize + cellMargin ),
                width: miniCellSize, height: miniCellSize
            )
        }
        
        func draw( cell: Cell, context: CGContext ) -> Void {
            if let solved = cell.solved {
                // Draw the solved number
                let rect = cellRect()
                let symbol = String( levelInfo.symbol( from: solved ) ?? "?" ) as CFString
                let attrString = CFAttributedStringCreate( kCFAllocatorDefault, symbol, solvedFont )
                let line       = CTLineCreateWithAttributedString( attrString! )
                let textSize   = CTLineGetImageBounds( line, context )
                let x          = rect.minX + ( rect.width - textSize.width ) / 2
                let y          = rect.minY + ( rect.height - textSize.height ) / 2

                context.textPosition = CGPoint( x: x, y: y)
                CTLineDraw( line, context )
                return
            }
            
            if !cell.penciled.isEmpty {
                // Draw all the penciled.
                for penciled in cell.penciled {
                    let rect = penciledRect( penciled: penciled )
                    let symbol = String( levelInfo.symbol( from: penciled ) ?? "?" ) as CFString
                    let attrString = CFAttributedStringCreate( kCFAllocatorDefault, symbol, penciledFont )
                    let line       = CTLineCreateWithAttributedString( attrString! )
                    let textSize   = CTLineGetImageBounds( line, context )
                    let x          = rect.minX + ( rect.width - textSize.width ) / 2
                    let y          = rect.minY + ( rect.height - textSize.height ) / 2

                    context.textPosition = CGPoint( x: x, y: y)
                    CTLineDraw( line, context )
                }
                return
            }
        }
    }
}
