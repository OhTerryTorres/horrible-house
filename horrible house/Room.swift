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
    
    var name = ""
    var explanation = ""
    var details: [Detail]? = []
    var actions: [Action]? = []
    var actionsToDisplay: [Action]? = []
    var position = (x: 0, y: 0)
    var timesEntered = 0
    var charactersPresent = [Character]()
    var items: [Item]? = []
    

    override init() {
        super.init()
    }
    
    func setRoomValuesForRoomDictionary(roomDict: AnyObject) {
        // Strip dictionary components into seperate values
        self.name = roomDict.objectForKey("name") as! String
        self.explanation = roomDict.objectForKey("explanation") as! String
        self.setActionsForRoomDictionary(roomDict)
        self.setItemsForDictionary(roomDict)
        self.actionsToDisplay = self.actions
        self.setDetailsForRoomDictionary(roomDict)
    }
    
    func setActionsForRoomDictionary(roomDict: AnyObject?) {
        var actions = [Action]()
        
        let rawActions = roomDict!.objectForKey("actions") as! [NSDictionary]
        
        for actionDictionary in rawActions {
            var name = String()
            var result = String?()
            var roomChange = String?()
            var triggerEvent = String?()
            
            
            if (actionDictionary.objectForKey("name") != nil) {
                name = actionDictionary.objectForKey("name") as! String
            }
            
            let action = Action(name: name)
            
            if (actionDictionary.objectForKey("rules") != nil) {
                action.setRulesForDictionary(actionDictionary)
            }
            if (actionDictionary.objectForKey("items") != nil) {
                action.setItemsForDictionary(actionDictionary)
            }
            if (actionDictionary.objectForKey("result") != nil) {
                result = actionDictionary.objectForKey("result") as? String
            }
            if (actionDictionary.objectForKey("roomChange") != nil) {
                roomChange = actionDictionary.objectForKey("roomChange") as? String
            }
            
            if (actionDictionary.objectForKey("triggerEvent") != nil) {
                triggerEvent = actionDictionary.objectForKey("triggerEvent") as? String
            }

            
            if let res = result { action.result = res }
            if let rc = roomChange { action.roomChange = rc }
            if let te = triggerEvent { action.triggerEvent = Event(name: te) }
            
            actions += [action]
        }
        
        self.actions = actions
    }
    
    func setDetailsForRoomDictionary(roomDict: AnyObject?) {
        var details = [Detail]()
        
        if (roomDict!.objectForKey("details") != nil) {
            
            let rawDetails = roomDict!.objectForKey("details") as! [NSDictionary]
            
            for detailDictionary in rawDetails {
                var explanation = String()
                
                if (detailDictionary.objectForKey("explanation") != nil) {
                    explanation = detailDictionary.objectForKey("explanation") as! String
                }
                
                let detail = Detail(explanation: explanation)
                
                if (detailDictionary.objectForKey("rules") != nil) {
                    detail.setRulesForDictionary(detailDictionary)
                }
                
                details += [detail]
            }
            
        }
                
        self.details = details
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
}
