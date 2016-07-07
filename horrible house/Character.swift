//
//  Character.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Character: NSObject, NSCoding, ItemBased {
    
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
    
    
    
    init(withDictionary: Dictionary<String, AnyObject>) {
        super.init()
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
    
    init(name:String, position:(x: Int, y: Int, z: Int)) {
        self.name = name
        self.position = position
        
    }
    
    init(name:String, position:(x: Int, y: Int, z: Int), items:[Item], explanation: String, hidden: Bool, behavior: Behavior) {
        self.name = name
        self.position = position
        self.items = items
        self.explanation = explanation
        self.hidden = hidden
        self.behavior = behavior
    }
    
    override init() {
        
    }
    
    
    // Eventually put in a property that gives a character a general AI direction.
    // Like, Stands In Place, or Seek Item

    // MARK: ENCODING
    
    func encodeWithCoder(coder: NSCoder) {
        
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeInteger(self.position.x, forKey: "x")
        coder.encodeInteger(self.position.y, forKey: "y")
        coder.encodeInteger(self.position.z, forKey: "z")
        
        coder.encodeObject(self.items, forKey: "items")
        
        coder.encodeObject(self.explanation, forKey: "explanation")
        coder.encodeBool(self.hidden, forKey: "hidden")
        coder.encodeObject(self.behavior.rawValue, forKey: "behavior")
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let name = decoder.decodeObjectForKey("name") as? String,
            let items = decoder.decodeObjectForKey("items") as? [Item],
            let explanation = decoder.decodeObjectForKey("explanation") as? String
            else { return nil }
        
        self.init(
            name: name,
            position: (x: decoder.decodeIntegerForKey("x"), y: decoder.decodeIntegerForKey("y"), z: decoder.decodeIntegerForKey("z")),
            items: items,
            explanation: explanation,
            hidden: decoder.decodeBoolForKey("hidden"),
            behavior: Character.Behavior(rawValue: decoder.decodeObjectForKey("behavior") as! String)!
        )
    }
}
