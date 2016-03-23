//
//  Stage.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Stage: NSObject {

    // MARK: Properties
    
    var name = ""
    var explanation = ""
    var actions : [Action]? = []
    var actionsToDisplay: [Action]? = []
    var rules: [Rule]? = []
    var items: [Item]? = []
    
    var completed = false
    
    
    override init() {
        super.init()
        
    }
    
    func setStageValuesForDictionary(dict: AnyObject) {
        // Strip dictionary components into seperate values
        self.name = dict.objectForKey("name") as! String
        self.explanation = dict.objectForKey("explanation") as! String
        self.setActionsForDictionary(dict)
        self.setRulesForDictionary(dict)
        self.setItemsForDictionary(dict)
        self.actionsToDisplay = self.actions
    }
    
    func setActionsForDictionary(dict: AnyObject?) {
        var actions = [Action]()
        
        let rawActions = dict!.objectForKey("actions") as! [NSDictionary]
        
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
            
            if (actionDictionary.objectForKey("replaceAction") != nil) {
                action.setReplaceActionForDictionary(actionDictionary.objectForKey("replaceAction"))
            }
            
            if let res = result { action.result = res }
            if let rc = roomChange { action.roomChange = rc }
            if let te = triggerEvent { action.triggerEvent = Event(name: te) }
            
            actions += [action]
        }
        
        self.actions = actions
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

    
}
