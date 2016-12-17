//
//  ActionPacked.swift
//  horrible house
//
//  Created by TerryTorres on 3/23/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation

protocol ActionPacked : class {
    var actions : [Action] { get set }
    
}

extension ActionPacked {
    
    func setActionsForArrayOfDictionaries(dictArray:[Dictionary<String, AnyObject>]) {
        for dict in dictArray {
            let action = Action(withDictionary: dict)
            self.actions += [action]
        }
    }
    
    func getActionsForArrayOfDictionaries(dictArray:[Dictionary<String, AnyObject>]) -> [Action] {
        var actions : [Action] = []
        for dict in dictArray {
            let action = Action(withDictionary: dict)
            actions += [action]
        }
        return actions
    }
    
    func numberOfActionsThatFollowTheRules() -> Int {
        var i = 0
        for action in actions {
            if action.isFollowingTheRules() {
                i += 1
            }
        }
        return i
    }
    
    func resolveChangesToActionsForAction(action: Action) {
        if let index = self.actions.index(where: {$0.name == action.name}) {
            self.actions[index].timesPerformed += 1
            if let replaceAction = action.replaceAction {
                self.actions[index] = replaceAction
            }
            if action.onceOnly == true {
                self.actions.remove(at: index)
            }
        }
    }
    
}
