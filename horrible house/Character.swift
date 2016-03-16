//
//  Character.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Character: NSObject {

    // MARK: Properties
    
    var name: String
    var position = (x: 0, y: 0)
    var items: [Item]? = []
    
    
    init(name:String) {
        self.name = name
    }
    
}
