//
//  Character.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Character: ItemBased {
    
    enum Behavior: String {
        case Default
        case Roam // Character goes from room to room at random, but doesn't reenter the room it just left if it can help it.
    }

    // MARK: Properties
    
    var name = ""
    var position = (x : 0, y : 0, z : 0)
    var items: [Item] = []
    var explanation = ""
    var hidden = false
    var behavior = Behavior.Default
    
    var startingRoom : String?
    
    
    init(name:String, position:(x: Int, y: Int, z: Int)) {
        self.name = name
        self.position = position
        
    }
    
    init(withDictionary: Dictionary<String, AnyObject>) {
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "explanation" { self.explanation = value as! String }
            if key == "behavior" {
                if value as! String == "Roam" { self.behavior = Behavior.Roam }
            }
            if key == "hidden" { self.hidden = true }
            if key == "items" { self.setItemsForDictionary(value as! [Dictionary<String, AnyObject>]) }
            if key == "startingRoom" { self.startingRoom = value as? String }
        }
    }
    
    
    // Eventually put in a property that gives a character a general AI direction.
    // Like, Stands In Place, or Seek Item

    
}
