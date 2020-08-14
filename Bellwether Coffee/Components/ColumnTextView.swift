//
//  ColumnTextView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/14/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol ColumnTextViewDelegate: class {
    func textViewDidResize(newSize: CGSize)
}

class ColumnTextView: ComponentView {
    
    weak var delegate: DynamicTextViewDelegate?
    
    var attributedText: NSAttributedString? {
        didSet {
            updateTextLayout()
//            textView.attributedText = attributedText
//            resizeHeight()
        }
    }
    
    var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    var textHeight: CGFloat = 100 {
        didSet { updateTextLayout() }
    }
    
    var textWidth: NSLayoutConstraint?
    
    var verticalPadding: CGFloat = 14
    var columnWidth: CGFloat = 300
    
    override func setupViews() {
        textWidth = widthAnchor.constraint(equalToConstant: 44)
        textWidth?.isActive = true
        
        clipsToBounds = true
        backgroundColor = .red
        
        let str = "During development, we will rigorously profile and stress-test our app for memory management, storage, and CPU/GPU usage to eliminate memory leaks or inefficient processes taking up large processing cycles. This will enable us to take full advantage of creating beautiful interactions and animations that give the app a level of polish. This extends well into the future for more advanced features that may take lots of processing power to perform, which may otherwise be impossible if our core application had performance issues. \n\nFor example, we can create a better experience for sign in by disabling only the components of the app that require a user account. Simple architecture tweaks can make a big difference to boost user friendliness.\n\nKeeping a modular structure not only in the development environment, but also for the app’s UI components is a huge value add. Modularizing each piece of the interface and managing the app’s state will help us do a number of things including graceful authentication, clear zero states, clear but non-intrusive feedback from the app if there is a problem with their input, and stateful user profiles/other app wide settings that can be accessed from the sidebar or UI component at any time."
        
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "OpenSans-Regular", size: 17)
        renderer.color = UIColor(white: 0.3, alpha: 1.0)
        renderer.lineSpacing = 4
        renderer.appendText(string: str)
        
        attributedText = renderer.renderedText
        
        
    }
    
    func updateTextLayout() {
        guard let attributedString = attributedText else { return }
        
        let textStorage = NSTextStorage(attributedString: attributedString)
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        updateTextLayout(layoutManager: layoutManager)
    }
    
    func updateTextLayout(layoutManager: NSLayoutManager) {
        var lastRenderedGlyph = 0
        var offsetX = CGFloat()
        
        while lastRenderedGlyph < layoutManager.numberOfGlyphs {
            let textFrame = CGRect(x: offsetX, y: 0, width: 200, height: textHeight)
            let columnSize = CGSize(width: textFrame.width, height: textFrame.height)
            
            let textContainer = NSTextContainer(size: columnSize)
            layoutManager.addTextContainer(textContainer)
            
            let textView = UITextView(frame: textFrame, textContainer: textContainer)
            textView.isScrollEnabled = false
            textView.backgroundColor = .clear
            addSubview(textView)
            
            offsetX += textFrame.width
            lastRenderedGlyph = NSMaxRange(layoutManager.glyphRange(for: textContainer))
            
        }
        
        textWidth?.constant = offsetX
    }
    
}
