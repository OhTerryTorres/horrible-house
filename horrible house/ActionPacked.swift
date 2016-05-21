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
            print("\(action.name)")
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
                i++
            }
        }
        return i
    }
    
}