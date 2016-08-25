//
//  Character.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Character: NSObject, NSCoding, ItemBased {
    

    // MARK: Properties
    
    var name = ""
    var position = (x : 0, y : 0, z : 0)
    var items: [Item] = []
    var explanation = ""
    var hidden = false
    var behaviors : [Behavior] = []
    
    var startingRoom : String?
    
    var roomHistory : [String] = []
    
    
    
    init(withDictionary: Dictionary<String, AnyObject>) {
        super.init()
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "explanation" { self.explanation = value as! String }
            if key == "behaviors" {
                for dict in value as! [Dictionary<String, AnyObject>] {
                    let behavior = Behavior(withDictionary: dict)
                    self.behaviors += [behavior]
                }
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
    
    init(name:String,
         position:(x: Int, y: Int, z: Int),
         items:[Item],
         explanation: String,
         hidden: Bool,
         behaviors: [Behavior],
         startingRoom : String?)
    {
        self.name = name
        self.position = position
        self.items = items
        self.explanation = explanation
        self.hidden = hidden
        self.behaviors = behaviors
        self.startingRoom = startingRoom
    }
    
    override init() {
        
    }
    
    func addRoomNameToRoomHistory(roomName: String) {
        self.roomHistory.insert(roomName, atIndex: 0)
        if self.roomHistory.count > 3 {
            self.roomHistory.removeLast()
        }
    }
    
    func addItemsToInventory(items: [Item]) {
        // DEPOSIT ITEMS INTO PLAYER INVENTORY
        for item in items {
            print("ExC – adding \(item.name) to inventory")
            self.items += [item]
        }
    }
    
    func consumeItemsWithNames(itemNames: [String]) {
        // REMOVE AND DESTROY ITEMS IN PLAYER INVENTORY
        for itemName in itemNames {
            if let _ = self.items.indexOf({$0.name == itemName}) {
                print("ExC – consuming item in inventory")
                self.removeItemFromItems(withName: itemName)
            }
        }
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
        coder.encodeObject(self.behaviors, forKey: "behavior")
        
        if let startingRoom = self.startingRoom {
            coder.encodeObject(startingRoom, forKey: "startingRoom")
        }
        
        coder.encodeObject(self.roomHistory, forKey: "roomHistory")
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObjectForKey("name") as! String
        self.position = (x: decoder.decodeIntegerForKey("x"), y: decoder.decodeIntegerForKey("y"), z: decoder.decodeIntegerForKey("z"))
        self.items = decoder.decodeObjectForKey("items") as! [Item]
        self.explanation = decoder.decodeObjectForKey("explanation") as! String
        self.hidden = decoder.decodeBoolForKey("hidden")
        self.behaviors = decoder.decodeObjectForKey("behavior") as! [Behavior]
        
        if let startingRoom = decoder.decodeObjectForKey("startingRoom") as? String? {
            self.startingRoom = startingRoom
        }
        
        self.roomHistory = decoder.decodeObjectForKey("roomHistory") as! [String]
        
    }
}
