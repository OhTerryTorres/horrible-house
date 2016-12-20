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
    
    static let backgroundColor = UIColor.red
    static let foregroundColor = UIColor.black
    static let specialColor = UIColor.white
    
    static let textRoomColor = UIColor.white
    static let textItemColor = UIColor.white
    static let textSpecialColor = UIColor.white
    
    static let mapCurrentColor = UIColor.red
    static let mapPreviousColor = UIColor.red
}

struct Font {
    static let basicFont = UIFont(name: "HelveticaNeue-Light", size: 20)
    static let detailFont = UIFont(name: "HelveticaNeue-Light", size: 12)
    static let titleFont = UIFont(name: "HelveticaNeue-Medium", size: 30)
    static let mainTitleFont = UIFont(name: "HelveticaNeue-Medium", size: 40)
    static let headerFont = UIFont.boldSystemFont(ofSize: 17)
    // static let basic = UIFont.systemFontOfSize(UIFont.systemFontSize())
    
    static let phoneFont = UIFont.systemFont(ofSize: 40)
}

extension UIView {
    func setStyle() {
        self.backgroundColor = Color.backgroundColor
        self.tintColor = Color.foregroundColor
    }
    func setStyleInverse() {
        self.backgroundColor = Color.foregroundColor
        self.tintColor = Color.backgroundColor
    }
}

extension UILabel {
    override func setStyle() {
        self.textColor = Color.foregroundColor
        self.font = Font.basicFont
    }
    override func setStyleInverse() {
        self.textColor = Color.backgroundColor
        self.font = Font.basicFont
    }
}

extension UITableView {
    override func setStyle() {
        self.backgroundColor = Color.backgroundColor
        self.tintColor = Color.foregroundColor
        self.separatorColor = Color.foregroundColor
    }
    override func setStyleInverse() {
        self.backgroundColor = Color.foregroundColor
        self.tintColor = Color.backgroundColor
        self.separatorColor = Color.backgroundColor
    }
}

extension UITableViewCell {
    override func setStyle() {
        self.backgroundColor = Color.backgroundColor
        self.tintColor = Color.foregroundColor
        
        if let textLabel = self.textLabel {
            textLabel.font = Font.basicFont
        }
        
        if let detailTextLabel = self.detailTextLabel {
            detailTextLabel.font = Font.detailFont
        }
    }
    override func setStyleInverse() {
        self.backgroundColor = Color.foregroundColor
        self.tintColor = Color.backgroundColor
        
        if let textLabel = self.textLabel {
            textLabel.font = Font.basicFont
        }
        
        if let detailTextLabel = self.detailTextLabel {
            detailTextLabel.font = Font.detailFont
        }
    }
}
