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
    
    
    func setAttributedTextWithTags(string: String) {
        var str = string
        
        var mutableStringArray = [NSMutableAttributedString]()
        var rangeAndTagArray = [(range : NSRange, tag : String)]()
        
        while str.range(of: "}") != nil {
            
            
            let tagStartStartRange = str.range(of: "{[")
            let tagStartEndRange = str.range(of: "]")
            
            let tag = str.substring(with: tagStartStartRange!.upperBound..<tagStartEndRange!.lowerBound)
            
            let tagStartRange = tagStartStartRange!.lowerBound..<tagStartEndRange!.upperBound
            
            let tagEndRange = str.range(of: "}")
            
            var newString = str.replacingCharacters(in: tagEndRange!, with: "")
            newString = newString.replacingCharacters(in: tagStartRange, with: "")
            
            var b = str.replacingCharacters(in: tagEndRange!.lowerBound..<str.endIndex, with: "")

            b = b.replacingCharacters(in: str.startIndex..<tagStartRange.upperBound, with: "")
            
            let a = newString.replacingCharacters(in: tagStartRange.lowerBound..<newString.endIndex, with: "")
            
            str = newString
            
            let affectedNSRange = NSMakeRange(a.characters.count, b.characters.count)
            
            let rangeAndTag = (range : affectedNSRange, tag : tag)
            
            
            /// Instead of making an array of mutable strings
            /// try making an array of affectedNSRanges
            /// then apply new attributes using each of those ranges.
            
            let mutableString = NSMutableAttributedString(string: newString)
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: affectedNSRange)
            
            mutableStringArray += [mutableString]
            
            rangeAndTagArray += [rangeAndTag]
            
        }
        
        
        let newMutableString = NSMutableAttributedString(string: str)
        
        for (range,tag) in rangeAndTagArray {
            newMutableString.addAttribute(NSForegroundColorAttributeName, value: textColorForTag(tag: tag), range: range)
        }
        
        newMutableString.addAttributes([ NSFontAttributeName: Font.basicFont!], range: NSRange(location:0, length:newMutableString.length))
        
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
    
    // ***
    func setTextWithTypeAnimation(typedText: String) {
        self.text = ""
        DispatchQueue.global(qos: .background).async {
            for character in typedText.characters {
                DispatchQueue.main.async {
                    self.text = self.text! + String(character)
                }
                sleep(UInt32(0.02))
            }
        }
    }
    
    func textColorForTag(tag: String) -> UIColor {
        var textColor = UIColor.black
        
        if (tag.range(of: "room") != nil) {
            textColor = Color.textRoomColor
        }
        if (tag.range(of: "item") != nil) {
            textColor = Color.textItemColor
        }
        if (tag.range(of: "special") != nil) {
            textColor = Color.textSpecialColor
        }
        
        return textColor
    }
    
    
}

extension String {
    
    func contains(s: String) -> Bool
    {
        return self.range(of: s) != nil ? true : false
    }
    
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: String.CompareOptions.literal, range: nil)
    }
    
    
}
