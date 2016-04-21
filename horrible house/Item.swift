//
//  Item.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Item: DictionaryBased, ActionPacked, Detailed {

    // MARK: Properties
    
    var name = ""
    var explanation = ""
    var inventoryDescription = ""
    var details: [Detail] = []
    var actions: [Action] = []
    var canCarry = false
    var hidden = false
    
    

    required init(withDictionary: Dictionary<String, AnyObject>) {
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "explanation" { self.explanation = value as! String }
            if key == "inventoryDescription" { self.inventoryDescription = value as! String }
            if key == "details" { self.setDetailsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            
            if key == "actions" { self.setActionsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            
            if key == "canCarry" { self.canCarry = true }
            if key == "hidden" { self.hidden = true }
        }
        
        // Adds a default TAKE action to every item.
        // It is only revealed to the player if the item can actually be carried.
        let dict : Dictionary<String, AnyObject> = [ "name" : "Take {[item]\(self.name)}", "result" : "Got {[item]\(self.name)}.", "onceOnly" : true]
        let takeAction = Action(withDictionary: dict)
        actions += [takeAction]
    }
    
    init() {
        
    }
    
}
