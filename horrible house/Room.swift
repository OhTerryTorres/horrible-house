//
//  Room.swift
//  horrible house
//
//  Created by TerryTorres on 2/10/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Room: NSObject, DictionaryBased, ItemBased, ActionPacked, Detailed, Inhabitable, NSCoding {
    
    var name = ""
    var explanation = ""
    var details: [Detail] = []
    var actions: [Action] = []
    var position = (x: 0, y: 0, z: 0)
    var timesEntered = 0
    var characters: [Character] = []
    var items: [Item] = []
    
    var placementGuidelines: Dictionary<String, AnyObject>?
    var isInHouse = false
    
    required init(withDictionary: Dictionary<String, AnyObject>) {
        super.init()
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "explanation" { self.explanation = value as! String }
            if key == "details" { self.setDetailsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            if key == "actions" { self.setActionsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            if key == "items" { self.setItemsForDictionary(value as! [Dictionary<String, AnyObject>]) }
            if key == "characters" { self.setCharactersForDictionary(value as! [Dictionary<String, AnyObject>]) }
            if key == "placementGuidelines" {
                self.placementGuidelines = value as? Dictionary<String, AnyObject>
            }
            
        }
    }
    
    override init() {
        
    }
    
    init(
        name : String,
        explanation : String,
        details : [Detail],
        actions: [Action],
        position: (x: Int, y: Int, z: Int),
        timesEntered: Int,
        characters: [Character],
        items: [Item]) {
            super.init()
        self.name = name
        self.explanation = explanation
        self.details = details
        self.actions = actions
        self.position = position
        self.timesEntered = timesEntered
        self.characters = characters
        self.items = items
    }
    
    
    // MARK: ENCODING
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.explanation, forKey: "explanation")
        
        coder.encodeObject(self.details, forKey: "details")
        coder.encodeObject(self.actions, forKey: "actions")
        
        coder.encodeInteger(self.position.x, forKey: "x")
        coder.encodeInteger(self.position.y, forKey: "y")
        coder.encodeInteger(self.position.z, forKey: "z")
        
        coder.encodeInteger(self.timesEntered, forKey: "timesEntered")
        
        coder.encodeObject(self.characters, forKey: "characters")
        coder.encodeObject(self.items, forKey: "items")
        
        if let placementGuidelines = self.placementGuidelines {
            coder.encodeObject(placementGuidelines, forKey: "placementGuidelines")
        }

        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObjectForKey("name") as! String
        self.explanation = decoder.decodeObjectForKey("explanation") as! String
        self.position = (x: decoder.decodeIntegerForKey("x"), y: decoder.decodeIntegerForKey("y"), z: decoder.decodeIntegerForKey("z"))
        self.timesEntered = decoder.decodeIntegerForKey("timesEntered")
        self.details = decoder.decodeObjectForKey("details") as! [Detail]
        self.actions = decoder.decodeObjectForKey("actions") as! [Action]
        self.characters = decoder.decodeObjectForKey("characters") as! [Character]
        self.items = decoder.decodeObjectForKey("items") as! [Item]
        if let placementGuidelines = decoder.decodeObjectForKey("placementGuidelines") as? Dictionary<String, AnyObject>? {
            self.placementGuidelines = placementGuidelines
        }

        
    }

}
