//
//  Style.swift
//  horrible house
//
//  Created by TerryTorres on 4/1/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation
import UIKit

struct Color {
    
    static let background = UIColor.redColor()
    static let foreground = UIColor.blackColor()
    
    static let textRoom = UIColor.whiteColor()
    static let textItem = UIColor.greenColor()
    static let textSpecial = UIColor.blueColor()
    
    static let mapCurrent = UIColor.blueColor()
    static let mapPrevious = UIColor.cyanColor()
}

struct Font {
    static let basicFont = UIFont.systemFontOfSize(UIFont.systemFontSize())
    // static let basic = UIFont (name: "HelveticaNeue-UltraLight", size: 30)
    
    static let phoneFont = UIFont.systemFontOfSize(40)
}

extension UIView {
    func setStyle() {
        self.backgroundColor = Color.background
        self.tintColor = Color.foreground
    }
}

extension UITableView {
    override func setStyle() {
        self.backgroundColor = Color.background
        self.tintColor = Color.foreground
    }
}

extension UITableViewCell {
    override func setStyle() {
        self.backgroundColor = Color.background
        self.tintColor = Color.foreground
    }
}