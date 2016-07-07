//
//  Action.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Action: NSObject, NSCoding, DictionaryBased, RuleBased {
    
    enum ActionType: String {
        case Item
        case Room
        case Inventory
    }
    
    // MARK: Properties
    
    // The text displayed to the player
    var name = ""
    
    // The new text displayed when the action is performed
    var result: String?
    
    // Changes the room explanation
    // Left blank if there is no substantial change.
    var roomChange: String?

    // The rules that must be followed for the action to be displayed
    // Left empty if the action can be performed any time.
    var rules: [Rule] = []
    
    // The number of times the player has performed the action
    var timesPerformed = 0
    
    // Applied to irreversible actions, or actions that get you a special item
    var onceOnly = false
    
    // If this action reveals an item, this is the item that will be presented to the player.
    // When preseneted, the item will be added to the currentRoom.items array, and a new
    // action presenting this item to the player will be added to the currentRoom.actions array.
    // This action will also, likely, be deleted from the currentRoom.actions array.
    var revealItems : [String] = []
    
    // Used to select an item by name and allow the player to carry it.
    var liberateItems : [String] = []
    
    // Used to add an item directly to the player's inventory.
    // Unlike the other item altering action properties, this one is an array of Items.
    // As such, consumeItem entries in the ROOMS.plist will likely be the first time such an item is generated.
    var addItems : [Item] = []
    
    // Used to eliminate a consumable item from the player's inventory.
    var consumeItems : [String] = []
    
    
    // These will add characters to the current room
    // Or, if the initializing dictionary has a startingRoom property, they'll spawn in that room
    var spawnCharacters : [Character] = []
    
    // When revealed, a hidden character is added to the current room's position.
    var revealCharacters : [String] = []
    
    // This helps remove Characters entirely from the house.npcs list and whatver room they are in.
    var removeCharacters : [String] = []

    
    // If a triggerEvent name is listed, choosing this action will trigger that event.
    // If a triggerEvent name is listed, but it is BLANK, the event will end and go back to the house.
    var triggerEventName : String?
    
    // The action can replace itself with another action
    // Ex: "Open Chest" replaced with "Look in Chest"
    var replaceAction : Action?
    
    // 0 goes to basement, 1 goes to first floor, 2 goes to second floor.
    var changeFloor : Int?
    
    // This is for special actions that trigger a segue to a viewcontroller
    var segue : String?
    
    required init(withDictionary: Dictionary<String, AnyObject>) {
        super.init()
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "result" { self.result = value as? String }
            if key == "roomChange" { self.roomChange = value as? String }
            if key == "rules" { self.setRulesForArray(value as! [String]) }
            
            if key == "revealItems" { self.revealItems = value as! [String] }
            if key == "liberateItems" { self.liberateItems = value as! [String] }
            
            if key == "addItems" {
                for dict in value as! [Dictionary<String, AnyObject>] {
                    let item = Item(withDictionary: dict)
                    self.addItems += [item]
                }
            }
            
            if key == "consumeItems" { self.consumeItems = value as! [String] }
            
            if key == "spawnCharacters" {
                for dict in value as! [Dictionary<String, AnyObject>] {
                    let character = Character(withDictionary: dict)
                    self.spawnCharacters += [character]
                }
            }
            if key == "revealCharacters" { self.revealCharacters = value as! [String] }
            if key == "removeCharacters" { self.removeCharacters = value as! [String] }
                        
            if key == "onceOnly" { self.onceOnly = true }
            
            // Rather than storing the triggerEvent itself, we'll store a string we can use to
            // search house.events for the event name. This, as opposed to storing the event
            // from house.events before house.events even exists!
            if key == "triggerEventName" { self.triggerEventName = value as? String }
                
            if key == "replaceAction" { self.replaceAction = Action(withDictionary: value as! Dictionary<String, AnyObject>) }
            
            if key == "changeFloor" { self.changeFloor = value as? Int }
            
            if key == "segue" { self.segue = value as? String }
            
        }
    }
    
    init(
        name: String,
        result: String?,
        roomChange: String?,
        rules: [Rule],
        timesPerformed: Int,
        onceOnly: Bool,
        revealItems: [String],
        liberateItems: [String],
        addItems: [Item],
        consumeItems: [String],
        spawnCharacters: [Character],
        revealCharacters: [String],
        removeCharacters: [String],
        replaceAction: Action?,
        changeFloor: Int?,
        segue: String?
        ) {
        self.name = name
        if let rs = result { self.result = rs }
        if let rc = roomChange { self.roomChange = rc }
        self.rules = rules
        self.timesPerformed = timesPerformed
        self.onceOnly = onceOnly
        self.revealItems = revealItems
        self.liberateItems = liberateItems
        self.addItems = addItems
        self.consumeItems = consumeItems
        self.spawnCharacters = spawnCharacters
        self.revealCharacters = revealCharacters
        self.removeCharacters = removeCharacters
        if let ra = replaceAction { self.replaceAction = ra }
        if let cf = changeFloor { self.changeFloor = cf }
        if let sg = segue { self.segue = sg }
    }
    
    
    override init() {
        
    }
    
    // MARK: ENCODING
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "name")
        
        if let result = self.result {
            coder.encodeObject(result, forKey: "result")
        }
        
        if let roomChange = self.roomChange {
            coder.encodeObject(roomChange, forKey: "roomChange")
        }
        
        coder.encodeObject(self.rules, forKey: "rules")
        coder.encodeInteger(self.timesPerformed, forKey: "timesPerformed")
        
        coder.encodeBool(self.onceOnly, forKey: "onceOnly")
        
        coder.encodeObject(self.revealItems, forKey: "revealItems")
        coder.encodeObject(self.liberateItems, forKey: "liberateItems")
        coder.encodeObject(self.addItems, forKey: "addItems")
        coder.encodeObject(self.consumeItems, forKey: "consumeItems")
        
        coder.encodeObject(self.spawnCharacters, forKey: "spawnCharacters")
        coder.encodeObject(self.revealCharacters, forKey: "revealCharacters")
        coder.encodeObject(self.removeCharacters, forKey: "removeCharacters")
        
        if let replaceAction = self.replaceAction {
            coder.encodeObject(replaceAction, forKey: "replaceAction")
        }
        
        if let changeFloor = self.changeFloor {
            coder.encodeInteger(changeFloor, forKey: "changeFloor")
        }
        
        if let segue = self.segue {
            coder.encodeObject(segue, forKey: "segue")
        }
        
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let name = decoder.decodeObjectForKey("name") as? String,
            let result = decoder.decodeObjectForKey("result") as? String,
            let roomChange = decoder.decodeObjectForKey("roomChange") as? String,
            let rules = decoder.decodeObjectForKey("rules") as? [Rule],
            let revealItems = decoder.decodeObjectForKey("revealItems") as? [String],
            let liberateItems = decoder.decodeObjectForKey("liberateItems") as? [String],
            let addItems = decoder.decodeObjectForKey("addItems") as? [Item],
            let consumeItems = decoder.decodeObjectForKey("consumeItems") as? [String],
            let spawnCharacters = decoder.decodeObjectForKey("spawnCharacters") as? [Character],
            let revealCharacters = decoder.decodeObjectForKey("revealCharacters") as? [String],
            let removeCharacters = decoder.decodeObjectForKey("removeCharacters") as? [String],
            let replaceAction = decoder.decodeObjectForKey("replaceAction") as? Action,
            let segue = decoder.decodeObjectForKey("segue") as? String
            else { return nil }
        
        self.init(
            name: name,
            result: result,
            roomChange: roomChange,
            rules: rules,
            timesPerformed: decoder.decodeIntegerForKey("timesPerformed"),
            onceOnly: decoder.decodeBoolForKey("onceOnly"),
            revealItems: revealItems,
            liberateItems: liberateItems,
            addItems: addItems,
            consumeItems: consumeItems,
            spawnCharacters: spawnCharacters,
            revealCharacters: revealCharacters,
            removeCharacters: removeCharacters,
            replaceAction: replaceAction,
            changeFloor: decoder.decodeIntegerForKey("changeFloor"),
            segue: segue
        )
    }

}
