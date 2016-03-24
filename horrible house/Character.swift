//
//  Character.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Character: ItemBased {

    // MARK: Properties
    
    var name: String
    var position : (x : Int, y : Int)
    var items: [Item] = []
    
    
    init(name:String, position:(x: Int, y: Int)) {
        self.name = name
        self.position = position
    }
    
    
}
