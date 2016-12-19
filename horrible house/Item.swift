//
//  Item.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Item: NSObject, DictionaryBased, ActionPacked, Detailed, ItemBased, NSCoding {

    // MARK: Properties
    
    var name = ""
    var explanation = ""
    var inventoryDescription = ""
    var details: [Detail] = []
    var actions: [Action] = []
    var canCarry = false
    var hidden = false
    
    // This lets the Inventory know of the item executes an event when selected
    var inventoryEvent : String?
    
    // MARK: For Containers
    
    var items : [Item] = []
    var maxCapacity = 0
    var isContainer : Bool?
    
    // MARK: For the oven
    var cookingTimeBegan : GameTime?
    
    // This is used to initialize a TAKE action
    var takeDict : Dictionary<String, AnyObject> {
        let dict = [ "name" : "Take {[item]\(self.name)}", "result" : "Got {[item]\(self.name)}.", "onceOnly" : true] as [String : Any]
        return dict as Dictionary<String, AnyObject>
    }
    

    required init(withDictionary: Dictionary<String, AnyObject>) {
        super.init()
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            
            if key == "explanation" { self.explanation = value as! String }
            if key == "inventoryDescription" { self.inventoryDescription = value as! String }
            if key == "details" { self.setDetailsForArrayOfDictionaries(dictArray: value as! [Dictionary<String, AnyObject>]) }
            
            if key == "actions" {
                self.setActionsForArrayOfDictionaries(dictArray: value as! [Dictionary<String, AnyObject>])
            }
            
            if key == "inventoryEvent" { if value as! String == "" {self.inventoryEvent = self.name}
            else { self.inventoryEvent = value as? String } }
            
            if key == "canCarry" { self.canCarry = true }
            if key == "hidden" { self.hidden = true }
            
            // Container properties
            
            if key == "items" {
                self.setItemsForDictionary(dictArray: value as! [Dictionary<String, AnyObject>])
            }
            
            if key == "maxCapacity" {
                let number = value as! NSNumber
                self.maxCapacity = Int(number)
            }
            if self.items.count > 0 || self.maxCapacity > 0 { self.isContainer = true }
        }
        
        // Adds a default TAKE action to every item.
        // It is only revealed to the player if the item can actually be carried.
        // First, check to see if there isn't already a customized TAKE action for the item.
        
        if let _ = self.actions.index(where: {$0.name.range(of: "Take") != nil}) {

        } else if self.canCarry == true {
            self.enableCarrying()
        }
        
        
        // Add a LOOK IN action for any containers
        if self.isContainer == true {
            let segueDict = ["identifier" : "container"]
            let lookDict : Dictionary<String, AnyObject> = [ "name" : "Look in {[item]\(self.name)}" as AnyObject, "segue" : segueDict as AnyObject]
            let lookAction = Action(withDictionary: lookDict)
            actions += [lookAction]
        }
        
        
        restoreBoxContents()

        
    }
    
    func restoreBoxContents() {
        // This helps the Box in the Foyer remember its contents across games.
        if let boxData = UserDefaults.standard.data(forKey: "boxData") {
            if let box = NSKeyedUnarchiver.unarchiveObject(with: boxData) as? Item {
                if self.name == box.name {
                    self.items = box.items
                }
            }
        }
        // There should be a function in the ItemBased protocol to check
        // if any item in their Items arrays match an item in boxData.
        // If so, the item is discarded.
    }
    
    init(
        name: String,
        explanation: String,
        inventoryDescription: String,
        details: [Detail],
        actions: [Action],
        canCarry: Bool,
        hidden: Bool,
        inventoryEvent: String?,
        items: [Item],
        maxCapacity: Int,
        isContainer: Bool?,
        cookingTimeBegan: GameTime?
        ) {
        self.name = name
        self.explanation = explanation
        self.inventoryDescription = inventoryDescription
        self.details = details
        self.actions = actions
        self.canCarry = canCarry
        self.hidden = hidden
        if let ie = inventoryEvent { self.inventoryEvent = ie }
        self.items = items
        self.maxCapacity = maxCapacity
        if let ic = isContainer { self.isContainer = ic }
        if let ctb = cookingTimeBegan { self.cookingTimeBegan = ctb }
    }
    
    override init() {
        
    }
    
    
    
    func enableCarrying() {
        self.canCarry = true
        actions += [Action(withDictionary: takeDict)]
    }
    
    func disableCarrying() {
        self.canCarry = false
        let takeAction = Action(withDictionary: takeDict)
        if let index = self.actions.index(where: {$0.name == takeAction.name}) {
            self.actions.remove(at: index)
        }

    }
    
    // MARK: ENCODING
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: "name")
        coder.encode(self.explanation, forKey: "explanation")
        coder.encode(self.inventoryDescription, forKey: "inventoryDescription")
        
        coder.encode(self.details, forKey: "details")
        coder.encode(self.actions, forKey: "actions")
        
        coder.encode(self.canCarry, forKey: "canCarry")
        coder.encode(self.hidden, forKey: "hidden")
        
        if let inventoryEvent = self.inventoryEvent {
            coder.encode(inventoryEvent, forKey: "inventoryEvent")
        }
        
        coder.encode(self.items, forKey: "items")
        
        coder.encode(maxCapacity, forKey: "maxCapacity")
        
        if let isContainer = self.isContainer {
            coder.encode(isContainer, forKey: "isContainer")
        }
        
        if let cookingTimeBegan = self.cookingTimeBegan {
            coder.encode(cookingTimeBegan, forKey: "cookingTimeBegan")
        }
        
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.explanation = decoder.decodeObject(forKey: "explanation") as! String
        self.inventoryDescription = decoder.decodeObject(forKey: "inventoryDescription") as! String
        self.details = decoder.decodeObject(forKey: "details") as! [Detail]
        self.actions = decoder.decodeObject(forKey: "actions") as! [Action]
        
        self.canCarry = decoder.decodeBool(forKey: "canCarry")
        self.hidden = decoder.decodeBool(forKey: "hidden")
        
        if let inventoryEvent = decoder.decodeObject(forKey: "inventoryEvent") as? String {
            self.inventoryEvent = inventoryEvent
        }
        if let cookingTimeBegan = decoder.decodeObject(forKey: "cookingTimeBegan") as? GameTime {
            self.cookingTimeBegan = cookingTimeBegan
        }
        
        self.items = decoder.decodeObject(forKey: "items") as! [Item]
        self.maxCapacity = decoder.decodeInteger(forKey: "maxCapacity")
        self.isContainer = decoder.decodeBool(forKey: "isContainer")
        
    }
    
}

//FIXME : Oven may need NSCOding methods

class Oven : Item {
    
    var isOn = false
    var timeTurnedOn : GameTime?
    
    var timeHeated : GameTime?
    var isHeated = false
    
    
    struct CookingTimes {
        static let secondsUntilHeated = 600 // 10 minutes
        static let secondsUntilCooked = 900 // 15 minutes
    }
    
    func turnOn(atTime currentTime : GameTime) {
        self.isOn = true
        self.timeTurnedOn = currentTime
        print("OVEN – Oven on at \(self.timeTurnedOn?.totalTimeInSeconds()) seconds")
        self.timeHeated = GameTime(hours: timeTurnedOn!.hours, minutes: timeTurnedOn!.minutes, seconds: timeTurnedOn!.seconds + CookingTimes.secondsUntilHeated)
        print("OVEN – Oven will be heated at \(timeHeated!.hours):\(timeHeated!.minutes))")
        
        if let index = self.actions.index(where: { $0.name.range(of: "on") != nil }) {
            let dict : Dictionary<String, AnyObject> = [ "name" : "Turn the oven off" as AnyObject, "result" : "The oven is off." as AnyObject]
            let action = Action(withDictionary: dict)
            self.actions[index] = action
        }

    }
    
    func turnOff() {
        self.isOn = false
        self.timeTurnedOn = nil
        self.timeHeated = nil
        self.isHeated = false
        print("OVEN – Oven off")
        for item in items {
            item.cookingTimeBegan = nil
        }
        
        if let index = self.actions.index(where: { $0.name.range(of: "off") != nil }) {
            let dict : Dictionary<String, AnyObject> = [ "name" : "Turn the oven on" as AnyObject, "result" : "The oven is on." as AnyObject]
            let action = Action(withDictionary: dict)
            self.actions[index] = action
        }
    }
    
    func checkOven(atTime currentTime : GameTime) {
        if isOn {
            if self.isHeated == false {
                print("OVEN – Current time is \(currentTime.totalTimeInSeconds())")
                if currentTime.totalTimeInSeconds() > timeHeated!.totalTimeInSeconds() {
                    print("OVEN – Oven heated!!")
                    self.isHeated = true
                }
            }
            
            
            if self.isHeated == true {
                self.setCookTimes(atTime: currentTime)
                self.cookItems(atTime: currentTime)
            }
        }
    }
    
    func setCookTimes(atTime currentTime: GameTime) {
        for item in items {
            if var _ = item.cookingTimeBegan {
                
            } else {
                print("OVEN – initializing cooking time")
                item.cookingTimeBegan = self.timeHeated!
                
                // Delete this when done testing
                let timeItemsWillBeCooked = GameTime(hours: item.cookingTimeBegan!.hours, minutes: item.cookingTimeBegan!.minutes, seconds: item.cookingTimeBegan!.seconds + CookingTimes.secondsUntilCooked)
                print("OVEN – \(item.name) be cooked at \(timeItemsWillBeCooked.hours):\(timeItemsWillBeCooked.minutes)")
            }
        }
        
    }
    
    func cookItems(atTime currentTime : GameTime) {
        for item in items {
            if var _ = item.cookingTimeBegan {
                let timeSpentCooking = currentTime.totalTimeInSeconds() - item.cookingTimeBegan!.totalTimeInSeconds()
                if timeSpentCooking >= CookingTimes.secondsUntilCooked {
                    if let i = items.index(where: {$0.name == item.name}) {
                        let newItem = Item()
                        
                        newItem.name = "Burnt Clump"
                        newItem.inventoryDescription = "An ashy pile"
                        
                        if item.name == "Huge Bat" {
                            newItem.name = "Roasted Bat"
                            newItem.inventoryDescription = "A bat, cooked alive"
                        }
                        
                        
                        items[i] = newItem
                    }
                }
            }
        }
    }
    
}
