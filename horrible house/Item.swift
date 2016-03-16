//
//  Item.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Item: NSObject {

    // MARK: Properties
    
    var name: String
    var consumable = false
    

    init(name:String) {
        self.name = name
        if self.name.lowercaseString.rangeOfString("\\con") != nil { self.consumable = true }

    }
    
}
