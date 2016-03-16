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
    var itemToPresent: Item?
    

    init(name:String) {
        self.name = name
        if self.name.lowercaseString.rangeOfString("\\once") != nil {
            self.canPerformMoreThanOnce = false
            self.name = self.name.stringByReplacingOccurrencesOfString(" \\once", withString: "")
        }
    }

}
