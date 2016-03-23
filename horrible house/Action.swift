//
//  Action.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Action: NSObject {
    
    // MARK: Properties
    
    // The text displayed to the player
    var name: String
    
    // The new text displayed when the action is performed
    var result: String?
    
    // Changes the room explanation
    // Left blank if there is no substantial change.
    var roomChange: String?

    // The rules that must be followed for the action to be displayed
    // Left empty if the action can be performed any time.
    var rules: [Rule]? = []
    
    // The number of times the player has performed the action
    var timesPerformed = 0
    
    // Applied to irreversible actions, or actions that get you a special item
    var canPerformMoreThanOnce = true
    
    // If this action reveals an item, this is the item that will be presented to the player.
    // When preseneted, the item will be added to the currentRoom.items array, and a new
    // action presenting this item to the player will be added to the currentRoom.actions array.
    // This action will also, likely, be deleted from the currentRoom.actions array.
    var items: [Item]? = []
    
    // If a triggerEvent name is listed, choosing this action will trigger that event.
    // If a triggerEvent name is listed, but it is BLANK, the event will end and go back to the house.
    var triggerEvent : Event?
    
    var replaceAction : Action?
    

    init(name:String) {
        self.name = name
        if self.name.lowercaseString.rangeOfString("\\once") != nil {
            self.canPerformMoreThanOnce = false
            self.name = self.name.stringByReplacingOccurrencesOfString(" \\once", withString: "")
        }
    }
    
    func setRulesForDictionary(dict: AnyObject?) {
        var rules = [Rule]()
        
        if (dict!.objectForKey("rules") != nil) {
            for ruleName in dict!.objectForKey("rules") as! [String] {
                let rule = Rule(name: ruleName)
                print("rule.type \(rule.type)")
                rules += [rule]
            }
        }
        
        self.rules = rules
    }
    
    func setItemsForDictionary(dict: AnyObject?) {
        var items = [Item]()
        if (dict!.objectForKey("items") != nil) {
            for itemName in dict?.objectForKey("items") as! [String] {
                let item = Item(name: itemName)
                items += [item]
            }
        }
        self.items = items
    }
    
    func setReplaceActionForDictionary(dict: AnyObject?) {
        var replaceAction = Action?()
        
        if let name = dict?.objectForKey("name") { replaceAction = Action(name: name as! String) }
        if let result = dict?.objectForKey("result") { replaceAction!.result = result as? String }
        if let roomChange = dict?.objectForKey("roomChange") { replaceAction!.roomChange = roomChange as? String }
        if let _ = dict?.objectForKey("rules") { replaceAction?.setRulesForDictionary(dict) }
        if let _ = dict?.objectForKey("items") { replaceAction?.setItemsForDictionary(dict) }
        if let triggerEvent = dict?.objectForKey("triggerEvent") { replaceAction?.triggerEvent = Event(name: triggerEvent as! String) }
        if let ra = dict?.objectForKey("replaceAction") { replaceAction?.setReplaceActionForDictionary(ra as! NSDictionary) }
        
        self.replaceAction = replaceAction
    }
    
    
    

}
