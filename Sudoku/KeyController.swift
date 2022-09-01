//
//  KeyController.swift
//  Sudoku
//
//  Created by Mark Johnson on 8/31/22.
//

import Foundation
import SwiftUI

class KeyViewController: NSViewController {
    override func loadView() {
        view = NSView( frame: CGRect( x: 0, y: 0, width: 0, height: 0 ) )
    }

    override func insertText( _ insertString: Any ) {
        print( "Insert string = '\(insertString)' (KeyViewController)" )
        
        let string = ( insertString as! String ).lowercased()
        
        print( "as String = '\(string)' (KeyViewController)" )
//        switch string {
//        case "0" ... "9":
//            super.insertText(insertString, replacementRange: selectedRange())
//        default:
//            viewController?.insertText(insertString)
//        }
    }
}


struct KeyController: NSViewControllerRepresentable {
    func makeNSViewController( context: Context ) -> KeyViewController {
        let controller = KeyViewController()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown ) {
            controller.interpretKeyEvents( [ $0 ] )
            return nil
        }
        return controller
    }
    
    func updateNSViewController( _ nsViewController: KeyViewController, context: Context ) {
       // <#code#>
    }
}
