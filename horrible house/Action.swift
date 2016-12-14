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
    enum ResolutionType: String {
        case Exploration, Event, Default
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
    var triggerEvent : (eventName: String, stageName: String?)?
    
    // The action can replace itself with another action
    // Ex: "Open Chest" replaced with "Look in Chest"
    var replaceAction : Action?

    
    // This will be used to a move a character in a certain direction.
    var moveCharacter : (characterName: String, roomName: String?, directionName: String?)?
    
    // This is for special actions that trigger a segue to a viewcontroller
    var segue : (identifier: String, qualifier: String?)?
    
    var textEntryTitle : String?
    
    
    required init(withDictionary: Dictionary<String, AnyObject>) {
        super.init()
        for (key, value) in withDictionary {
            
            if key == "name" { self.name = value as! String }
            if key == "result" { self.result = value as? String }
            if key == "roomChange" { self.roomChange = value as? String }
            if key == "rules" { self.setRulesForArray(array: value as! [String]) }
            
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
            if key == "triggerEvent" {
                var eventName = ""
                var stageName : String?
                for (k,v) in value as! Dictionary<String, AnyObject> {
                    if k == "eventName" { eventName = v as! String }
                    if k == "stageName" { stageName = v as? String }
                }
                self.triggerEvent = (eventName, stageName)
            }
                
            if key == "replaceAction" { self.replaceAction = Action(withDictionary: value as! Dictionary<String, AnyObject>) }
            
            if key == "moveCharacter" {
                var characterName : String?
                var roomName : String?
                var directionName : String?
                for (k,v) in value as! Dictionary<String, AnyObject> {
                    if k == "characterName" { characterName = v as? String }
                    if k == "roomName" { roomName = v as? String }
                    if k == "directionName" { directionName = v as? String }

                }
                self.moveCharacter = (characterName!, roomName, directionName)
            }
            
            if key == "segue" {
                var identifier = ""
                var qualifier : String?
                for (k,v) in value as! Dictionary<String, AnyObject> {
                    if k == "identifier" { identifier = v as! String }
                    if k == "qualifier" { qualifier = v as? String }
                }
                self.segue = (identifier, qualifier)
            }
            
            
            if key == "textEntryTitle" {
                self.textEntryTitle = value as? String
            }
            
        }
        
        
        // This checks boxData to see if an item revealed by the action might
        // have already been find, and uses a rule to hide itself as a result
        if let boxData = UserDefaults.standard.object(forKey: "boxData") {
            if let _ = NSKeyedUnarchiver.unarchiveObject(with: boxData as! Data) as? Item {
                for itemName in revealItems {
                    let rule = Rule(name: itemName, type: Rule.RuleType.nopeDidStoreItem)
                    self.rules += [rule]
                }
            }
        }
    }

    
    // MARK: RESOLVE ACTIONS
    
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
        triggerEvent: (eventName: String, stageName: String?)?,
        replaceAction: Action?,
        moveCharacter: (characterName: String, roomName: String?, directionName: String?)?,
        segue: (identifier: String, qualifier: String?)?
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
        if let te = triggerEvent { self.triggerEvent = te }
        if let ra = replaceAction { self.replaceAction = ra }
        if let sg = segue { self.segue = sg }
        if let mc = moveCharacter { self.moveCharacter = mc }
    }
    
    // Defaults
    override init() {

    }
    
    // MARK: ENCODING
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: "name")
        
        if let result = self.result {
            coder.encode(result, forKey: "result")
        }
        
        if let roomChange = self.roomChange {
            coder.encode(roomChange, forKey: "roomChange")
        }
        
        coder.encode(self.rules, forKey: "rules")
        coder.encode(self.timesPerformed, forKey: "timesPerformed")
        
        coder.encode(self.onceOnly, forKey: "onceOnly")
        
        coder.encode(self.revealItems, forKey: "revealItems")
        coder.encode(self.liberateItems, forKey: "liberateItems")
        coder.encode(self.addItems, forKey: "addItems")
        coder.encode(self.consumeItems, forKey: "consumeItems")
        
        coder.encode(self.spawnCharacters, forKey: "spawnCharacters")
        coder.encode(self.revealCharacters, forKey: "revealCharacters")
        coder.encode(self.removeCharacters, forKey: "removeCharacters")
        
        if let replaceAction = self.replaceAction {
            coder.encode(replaceAction, forKey: "replaceAction")
        }
        
        if let segue = self.segue {
            coder.encode(segue.identifier, forKey: "identifier")
            if let qualifier = segue.qualifier {
                coder.encode(qualifier, forKey: "qualifier")
            }
        }
        
        if let moveCharacter = self.moveCharacter {
            coder.encode(moveCharacter.characterName, forKey: "characterName")
            coder.encode(moveCharacter.roomName, forKey: "roomName")
            coder.encode(moveCharacter.directionName, forKey: "directionName")
        }
        
        if let triggerEvent = self.triggerEvent {
            coder.encode(triggerEvent.eventName, forKey: "eventName")
            if let stageName = triggerEvent.stageName {
                coder.encode(stageName, forKey: "stageName")
            }
            
        }
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObject(forKey: "name") as! String
        if let result = decoder.decodeObject(forKey: "result") as! String? {
            self.result = result
        }
        if let roomChange = decoder.decodeObject(forKey: "roomChange") as! String? {
            self.roomChange = roomChange
        }
        self.rules = decoder.decodeObject(forKey: "rules") as! [Rule]
        
        self.timesPerformed = decoder.decodeInteger(forKey: "timesPerformed")
        self.onceOnly = decoder.decodeBool(forKey: "onceOnly")
        
        self.revealItems = decoder.decodeObject(forKey: "revealItems") as! [String]
        self.liberateItems = decoder.decodeObject(forKey: "liberateItems") as! [String]
        self.addItems = decoder.decodeObject(forKey: "addItems") as! [Item]
        self.consumeItems = decoder.decodeObject(forKey: "consumeItems") as! [String]
        self.spawnCharacters = decoder.decodeObject(forKey: "spawnCharacters") as! [Character]
        self.revealCharacters = decoder.decodeObject(forKey: "revealCharacters") as! [String]
        self.removeCharacters = decoder.decodeObject(forKey: "removeCharacters") as! [String]
        if let replaceAction = decoder.decodeObject(forKey: "replaceAction") as? Action {
            self.replaceAction = replaceAction
        }
        if let identifier = decoder.decodeObject(forKey: "identifier") as? String {
            if let qualifier = decoder.decodeObject(forKey: "qualifier") as? String {
                self.segue = (identifier, qualifier)
            } else {
                self.segue = (identifier, nil)
            }
        }
        
        if let characterName = decoder.decodeObject(forKey: "characterName") as? String {
            self.moveCharacter?.characterName = characterName
        }
        if let roomName = decoder.decodeObject(forKey: "roomName") as? String {
            self.moveCharacter?.roomName = roomName
        }
        if let directionName = decoder.decodeObject(forKey: "directionName") as? String {
            self.moveCharacter?.directionName = directionName
        }

        
        if let eventName = decoder.decodeObject(forKey: "eventName") as? String {
            if let stageName = decoder.decodeObject(forKey: "stageName") as? String {
                self.triggerEvent = (eventName, stageName)
            } else {
                self.triggerEvent = (eventName, nil)
            }
        }
    }
}
