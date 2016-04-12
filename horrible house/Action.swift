//
//  Action.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Action: DictionaryBased, RuleBased {
    
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
    
    // If a triggerEvent name is listed, choosing this action will trigger that event.
    // If a triggerEvent name is listed, but it is BLANK, the event will end and go back to the house.
    var triggerEventName : String?
    
    var replaceAction : Action?
    
    // 0 goes to basement, 1 goes to first floor, 2 goes to second floor.
    var changeFloor : Int?
    
    // This is for special actions that trigger a segue to a viewcontroller
    var segue : String?

    required init(withDictionary: Dictionary<String, AnyObject>) {
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "result" { self.result = value as? String }
            if key == "roomChange" { self.roomChange = value as? String }
            if key == "rules" { self.setRulesForArray(value as! [String]) }
            if key == "revealItems" { self.revealItems = value as! [String] }
            if key == "liberateItems" { self.liberateItems = value as! [String] }
            if key == "onceOnly" { self.onceOnly = true }
            
            // Rather than storing the triggerEvent itself, we'll store a string we can use to
            // search house.events for the event letter. This, as opposed to storing the event
            // from house.events before house.events even exists!
            if key == "triggerEventName" { self.triggerEventName = value as? String }
                
            if key == "replaceAction" { self.replaceAction = Action(withDictionary: value as! Dictionary<String, AnyObject>) }
            
            if key == "changeFloor" { self.changeFloor = value as? Int }
            
            if key == "segue" { self.segue = value as? String }
            
        }
    }
    
    
    

}
