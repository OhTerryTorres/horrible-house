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
    
    // Player statistics
    // but maybe other characters can have them??
    var stats : [String : [String]] = [:]
    var gamesPlayed = 0
    
    
    
    
    
    
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
            if key == "items" { self.setItemsForDictionary(dictArray: value as! [Dictionary<String, AnyObject>]) }
            if key == "startingRoom" { self.startingRoom = value as? String }
        }
        
        if self.name == "player" {
            if let statsData = UserDefaults.standard.object(forKey: "statsData") {
                self.stats = NSKeyedUnarchiver.unarchiveObject(with: statsData as! Data) as! [String : [String]]
            } else {
                self.stats = ["roomsFound" : [""], "itemsFound" : [""]]
            }
            
        }
    }

    func getMemories() -> Int {
        var memories = 0
        if let roomsFound = self.stats["roomsFound"] {
            memories += roomsFound.count
        }
        if let itemsFound = self.stats["itemsFound"] {
            memories += itemsFound.count
        }
        return memories
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
         startingRoom : String?,
         roomHistory : [String],
         stats : [String : [String]])
    {
        self.name = name
        self.position = position
        self.items = items
        self.explanation = explanation
        self.hidden = hidden
        self.behaviors = behaviors
        self.startingRoom = startingRoom
        self.roomHistory = roomHistory
        self.stats = stats
    }
    
    override init() {
        
    }
    
    func addRoomNameToRoomHistory(roomName: String) {

        self.roomHistory.insert(roomName, at: 0)
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
            if let _ = self.items.index(where: {$0.name == itemName}) {
                print("ExC – consuming item in inventory")
                self.removeItemFromItems(withName: itemName)
            }
        }
    }
    
    
    
    
    
    // Eventually put in a property that gives a character a general AI direction.
    // Like, Stands In Place, or Seek Item

    // MARK: ENCODING
    
    public func encode(with coder: NSCoder) {
        
        coder.encode(self.name, forKey: "name")
        coder.encode(self.position.x, forKey: "x")
        coder.encode(self.position.y, forKey: "y")
        coder.encode(self.position.z, forKey: "z")
        
        coder.encode(self.items, forKey: "items")
        
        coder.encode(self.explanation, forKey: "explanation")
        coder.encode(self.hidden, forKey: "hidden")
        coder.encode(self.behaviors, forKey: "behavior")
        
        if let startingRoom = self.startingRoom {
            coder.encode(startingRoom, forKey: "startingRoom")
        }
        
        coder.encode(self.roomHistory, forKey: "roomHistory")
        coder.encode(self.stats, forKey: "stats")
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.position = (x: decoder.decodeInteger(forKey: "x"), y: decoder.decodeInteger(forKey: "y"), z: decoder.decodeInteger(forKey: "z"))
        self.items = decoder.decodeObject(forKey: "items") as! [Item]
        self.explanation = decoder.decodeObject(forKey: "explanation") as! String
        self.hidden = decoder.decodeBool(forKey: "hidden")
        self.behaviors = decoder.decodeObject(forKey: "behavior") as! [Behavior]
        
        if let startingRoom = decoder.decodeObject(forKey: "startingRoom") as? String? {
            self.startingRoom = startingRoom
        }
        
        self.roomHistory = decoder.decodeObject(forKey: "roomHistory") as! [String]
        
        self.stats = decoder.decodeObject(forKey: "stats") as! [String : [String]]
        
    }
}
