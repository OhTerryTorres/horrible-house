//
//  UILabelExtension.swift
//  horrible house
//
//  Created by TerryTorres on 4/1/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    // Uses the tag system to set the right color to the text.
    // A string that reads "Go north to {[room]Dining Room}" would become "Go north to Dining Room"
    // with the "Dining Room" text being the color Color.roomColor.
    
    
    func setAttributedTextWithTags(var string: String) {
        
        var mutableStringArray = [NSMutableAttributedString]()
        var rangeAndTagArray = [(range : NSRange, tag : String)]()
        
        while string.rangeOfString("}") != nil {
            
            let tagStartStartRange = string.rangeOfString("{[")
            let tagStartEndRange = string.rangeOfString("]")
            
            let tag = string.substringWithRange(Range<String.Index>(start: tagStartStartRange!.endIndex, end: tagStartEndRange!.startIndex))
            
            
            let tagStartRange = Range<String.Index>(start: tagStartStartRange!.startIndex, end: tagStartEndRange!.endIndex)
            
            let tagEndRange = string.rangeOfString("}")
            
            var newString = string.stringByReplacingCharactersInRange(tagEndRange!, withString: "")
            newString = newString.stringByReplacingCharactersInRange(tagStartRange, withString: "")
            
            var b = string.stringByReplacingCharactersInRange(Range<String.Index>(start: tagEndRange!.startIndex, end: string.endIndex), withString: "")

            b = b.stringByReplacingCharactersInRange(Range<String.Index>(start: string.startIndex, end: tagStartRange.endIndex), withString: "")
            
            let a = newString.stringByReplacingCharactersInRange(Range<String.Index>(start: tagStartRange.startIndex, end: newString.endIndex), withString: "")
            
            string = newString
            
            let affectedNSRange = NSMakeRange(a.characters.count, b.characters.count)
            
            let rangeAndTag = (range : affectedNSRange, tag : tag)
            
            
            /// Instead of making an array of mutable strings
            /// try making an array of affectedNSRanges
            /// then apply new attributes using each of those ranges.
            
            let mutableString = NSMutableAttributedString(string: newString)
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: affectedNSRange)
            
            mutableStringArray += [mutableString]
            
            rangeAndTagArray += [rangeAndTag]
            
        }
        
        
        let newMutableString = NSMutableAttributedString(string: string)
        
        for (range,tag) in rangeAndTagArray {
            newMutableString.addAttribute(NSForegroundColorAttributeName, value: textColorForTag(tag), range: range)
        }
        
        self.attributedText = newMutableString
    }
    
    func textColorForTag(tag: String) -> UIColor {
        var textColor = UIColor.blackColor()
        
        if (tag.rangeOfString("room") != nil) {
            textColor = Color.roomColor
        }
        if (tag.rangeOfString("item") != nil) {
            textColor = Color.itemColor
        }
        
        return textColor
    }
    
    
}