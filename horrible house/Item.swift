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
    
    // MARK: For Containers
    
    var items : [Item] = []
    var maxCapacity : Int?
    var isContainer : Bool?
    

    required init(withDictionary: Dictionary<String, AnyObject>) {
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "explanation" { self.explanation = value as! String }
            if key == "inventoryDescription" { self.inventoryDescription = value as! String }
            if key == "details" { self.setDetailsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            
            if key == "actions" { self.setActionsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            
            if key == "canCarry" { self.canCarry = true }
            if key == "hidden" { self.hidden = true }
            
            // Container properties
            
            if key == "items" { self.setItemsForDictionary(value as! [Dictionary<String, AnyObject>]) }
            if key == "maxCapacity" { self.maxCapacity = value as? Int }
            if self.items.count > 0 || self.maxCapacity > 0 { self.isContainer = true }
        }
        
        // Adds a default TAKE action to every item.
        // It is only revealed to the player if the item can actually be carried.
        let takeDict : Dictionary<String, AnyObject> = [ "name" : "Take {[item]\(self.name)}", "result" : "Got {[item]\(self.name)}.", "onceOnly" : true]
        let takeAction = Action(withDictionary: takeDict)
        actions += [takeAction]
        
        // Add a LOOK IN action for any containers
        if self.isContainer == true {
            let lookDict : Dictionary<String, AnyObject> = [ "name" : "Look in {[item]\(self.name)}", "segue" : "container"]
            let lookAction = Action(withDictionary: lookDict)
            actions += [lookAction]
        }
        
    }
    
    init() {
        
    }
    
}

class Oven : Item {
    
    var isOn = false
    var timeTurnedOn : GameTime?
    var secondsUntilHeated = 900 // 15 minutes
    var timeHeated : GameTime?
    var isHeated = false
    var secondsUntilCooked = 900
    var timeCooked : GameTime?
    var itemsCooking : [Item] = []
    
    func turnOn() {
        self.timeTurnedOn = (UIApplication.sharedApplication().delegate as! AppDelegate).house.gameClock.currentTime
        self.itemsCooking = self.items
    }
    
    func turnOff() {
        self.timeTurnedOn = GameTime()
        self.timeHeated = GameTime()
        self.isHeated = false
        self.itemsCooking = []
    }
    
    func checkOven() {
        self.timeHeated = GameTime(hours: timeTurnedOn!.hours, minutes: timeTurnedOn!.minutes, seconds: timeTurnedOn!.seconds + secondsUntilHeated)
        if (UIApplication.sharedApplication().delegate as! AppDelegate).house.gameClock.currentTime.totalTimeInSeconds() > timeHeated!.totalTimeInSeconds() {
            self.isHeated = true
        }
        
        if isHeated {
            self.timeCooked = GameTime(hours: timeHeated!.hours, minutes: timeHeated!.minutes, seconds: timeHeated!.seconds + secondsUntilCooked)
            if (UIApplication.sharedApplication().delegate as! AppDelegate).house.gameClock.currentTime.totalTimeInSeconds() > timeCooked!.totalTimeInSeconds() {
                self.cookItems()
            }
        }
        
    }
    
    func cookItems() {
        for item in itemsCooking {
            if let i = items.indexOf({$0.name == item.name}) {
                let newItem = Item()
                newItem.name = "Burnt Clump"
                newItem.inventoryDescription = "An ashy pile"
                
                items[i] = newItem
            }
            
        }
    }
    
}
