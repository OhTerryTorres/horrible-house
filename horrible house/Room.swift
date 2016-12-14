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
            if key == "details" { self.setDetailsForArrayOfDictionaries(dictArray: value as! [Dictionary<String, AnyObject>]) }
            if key == "actions" { self.setActionsForArrayOfDictionaries(dictArray: value as! [Dictionary<String, AnyObject>]) }
            if key == "items" { self.setItemsForDictionary(dictArray: value as! [Dictionary<String, AnyObject>]) }
            if key == "characters" { self.setCharactersForDictionary(dictArray: value as! [Dictionary<String, AnyObject>]) }
            if key == "placementGuidelines" {
                self.placementGuidelines = value as? Dictionary<String, AnyObject>
            }
            
        }
    }
    
    // Default
    override init() {
        self.name = "No Room"
        self.explanation = "This is the absence of a room"
        self.actions = [Action()]
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
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: "name")
        coder.encode(self.explanation, forKey: "explanation")
        
        coder.encode(self.details, forKey: "details")
        coder.encode(self.actions, forKey: "actions")
        
        coder.encode(self.position.x, forKey: "x")
        coder.encode(self.position.y, forKey: "y")
        coder.encode(self.position.z, forKey: "z")
        
        coder.encode(self.timesEntered, forKey: "timesEntered")
        
        coder.encode(self.characters, forKey: "characters")
        coder.encode(self.items, forKey: "items")
        
        if let placementGuidelines = self.placementGuidelines {
            coder.encode(placementGuidelines, forKey: "placementGuidelines")
        }

        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.explanation = decoder.decodeObject(forKey: "explanation") as! String
        self.position = (x: decoder.decodeInteger(forKey: "x"), y: decoder.decodeInteger(forKey: "y"), z: decoder.decodeInteger(forKey: "z"))
        self.timesEntered = decoder.decodeInteger(forKey: "timesEntered")
        self.details = decoder.decodeObject(forKey: "details") as! [Detail]
        self.actions = decoder.decodeObject(forKey: "actions") as! [Action]
        self.characters = decoder.decodeObject(forKey: "characters") as! [Character]
        self.items = decoder.decodeObject(forKey: "items") as! [Item]
        if let placementGuidelines = decoder.decodeObject(forKey: "placementGuidelines") as? Dictionary<String, AnyObject>? {
            self.placementGuidelines = placementGuidelines
        }

        
    }

}
