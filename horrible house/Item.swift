//
//  Item.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Item: DictionaryBased, ActionPacked, Detailed, ItemBased {

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
    var maxCapacity : Int?
    var isContainer : Bool?
    
    // MARK: For the oven
    var cookingTimeBegan : GameTime?
    
    // This is used to initialize a TAKE action
    var takeDict : Dictionary<String, AnyObject> {
        let dict = [ "name" : "Take {[item]\(self.name)}", "result" : "Got {[item]\(self.name)}.", "onceOnly" : true]
        return dict as! Dictionary<String, AnyObject>
    }
    

    required init(withDictionary: Dictionary<String, AnyObject>) {
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "explanation" { self.explanation = value as! String }
            if key == "inventoryDescription" { self.inventoryDescription = value as! String }
            if key == "details" { self.setDetailsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            
            if key == "actions" { self.setActionsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            
            if key == "inventoryEvent" { if value as! String == "" {self.inventoryEvent = self.name}
            else { self.inventoryEvent = value as? String } }
            
            if key == "canCarry" { self.canCarry = true }
            if key == "hidden" { self.hidden = true }
            
            // Container properties
            
            if key == "items" { print("ITEM – name is \(name)"); self.setItemsForDictionary(value as! [Dictionary<String, AnyObject>]) }
            if key == "maxCapacity" { self.maxCapacity = value as? Int }
            if self.items.count > 0 || self.maxCapacity > 0 { self.isContainer = true }
        }
        
        // Adds a default TAKE action to every item.
        // It is only revealed to the player if the item can actually be carried.
        // First, check to see if there isn't already a customized TAKE action for the item.
        
        if let _ = self.actions.indexOf({$0.name.rangeOfString("Take") != nil}) {
            print("ITEM – \(self.name) already has a Take action")
        } else if self.canCarry == true {
            print("ITEM – \(self.name) needs a Take action")
            self.enableCarrying()
        }
        
        // Add a LOOK IN action for any containers
        if self.isContainer == true {
            let lookDict : Dictionary<String, AnyObject> = [ "name" : "Look in {[item]\(self.name)}", "segue" : "container"]
            let lookAction = Action(withDictionary: lookDict)
            actions += [lookAction]
        }
        
    }
    
    init() {
        
    }
    
    func enableCarrying() {
        self.canCarry = true
        actions += [Action(withDictionary: takeDict)]
    }
    
    func disableCarrying() {
        self.canCarry = false
        let takeAction = Action(withDictionary: takeDict)
        if let index = self.actions.indexOf({$0.name == takeAction.name}) {
            self.actions.removeAtIndex(index)
        }

    }
    
}

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
        
        if let index = self.actions.indexOf({ $0.name.rangeOfString("on") != nil }) {
            let dict : Dictionary<String, AnyObject> = [ "name" : "Turn the oven off", "result" : "The oven is off."]
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
        
        if let index = self.actions.indexOf({ $0.name.rangeOfString("off") != nil }) {
            let dict : Dictionary<String, AnyObject> = [ "name" : "Turn the oven on", "result" : "The oven is on."]
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
                    if let i = items.indexOf({$0.name == item.name}) {
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
