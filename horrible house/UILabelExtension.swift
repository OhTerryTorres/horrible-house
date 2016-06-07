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
        
        
        // This shall be sealed away until it may be needed again one day.
        /*
        if isAnimated {
            var typewriteRange = NSMakeRange(1, newMutableString.length)
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                for var i = 1; typewriteRange.location < newMutableString.length; i++ {
                    typewriteRange.location = i
                    typewriteRange.length -= 1
                    print("typewriteRange is \(typewriteRange)")
                    print("newMutableString is \(newMutableString)")
                    
                    let newerMutableString = NSMutableAttributedString(string: string)
                    for (range,tag) in rangeAndTagArray {
                        newerMutableString.addAttribute(NSForegroundColorAttributeName, value: self.textColorForTag(tag), range: range)
                    }
                    
                    newerMutableString.replaceCharactersInRange(typewriteRange, withString: "")
                    print("newerMutableString is \(newerMutableString)")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.attributedText = newerMutableString
                    }
                    NSThread.sleepForTimeInterval(0.02)
                }
            }
        }
        */
        
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