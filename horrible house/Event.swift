//
//  Event.swift
//  horrible house
//
//  Created by TerryTorres on 3/19/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Event: DictionaryBased, RuleBased {
    
    var name = ""
    var stages : [Stage] = []
    var currentStage : Stage?
    var rules: [Rule] = []

    required init(withDictionary: Dictionary<String, AnyObject>) {
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "stages" {
                let dictArray = value as! [Dictionary<String, AnyObject>]
                for dict in dictArray {
                    let stage = Stage(withDictionary: dict)
                    self.stages += [stage]
                }
            }
            
            
            
            if key == "rules" { self.setRulesForArray(value as! [String]) }
        }
    }
    
    init(name: String) {
        
    }
    
    // This will make the first stage in self.stages that follows the rules
    // into the default stage. This can be changed if a better method appears.
    func setCurrentStage() {
        for stage in self.stages {
            if stage.isFollowingTheRules() { self.currentStage = stage ; break }
        }
    }
    
    init() {
        
    }
}
