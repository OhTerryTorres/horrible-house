//
//  Room.swift
//  horrible house
//
//  Created by TerryTorres on 2/10/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Room: NSObject {
    
    // MARK: Properties
    
    var name: String
    var explanation: String
    var details: [Detail]? = []
    var actions: [Action]? = []
    var actionsToDisplay: [Action]? = []
    var position = (x: 0, y: 0)
    var timesEntered = 0
    var charactersPresent = [Character]()
    var items: [Item]? = []
    

    init(name:String, explanation:String, actions:[Action]) {
        self.name = name
        self.explanation = explanation
        self.actions = actions
    }
    
    func getActionsForRoomDictionary(roomDict: AnyObject?) -> [Action] {
        var actions = [Action]()
        
        let rawActions = roomDict!.objectForKey("actions") as! [NSDictionary]
        
        for actionDictionary in rawActions {
            var name = String()
            var rules = [Rule]()
            var result = String?()
            var roomChange = String?()
            var itemToPresent = Item?()
            
            
            if (actionDictionary.objectForKey("name") != nil) {
                name = actionDictionary.objectForKey("name") as! String
            }
            if (actionDictionary.objectForKey("rules") != nil) {
                rules = Rule.getRulesForDictionary(actionDictionary)
            }
            if (actionDictionary.objectForKey("result") != nil) {
                result = actionDictionary.objectForKey("result") as? String
            }
            if (actionDictionary.objectForKey("roomChange") != nil) {
                roomChange = actionDictionary.objectForKey("roomChange") as? String
            }
            if (actionDictionary.objectForKey("itemToPresent") != nil) {
                itemToPresent = Item(name: (actionDictionary.objectForKey("itemToPresent") as? String)!)
            }
            
            let action = Action(name: name)
            if rules.count > 0 { action.rules = rules}
            if let res = result { action.result = res }
            if let rc = roomChange { action.roomChange = rc }
            if let item = itemToPresent { action.itemToPresent = item }
            
            actions += [action]
        }
        
        return actions
    }
}
