//
//  Stage.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Stage: DictionaryBased, ItemBased, RuleBased, ActionPacked {

    // MARK: Properties
    
    var name = ""
    var explanation = ""
    var actions : [Action] = []
    var rules: [Rule] = []
    var items: [Item] = []
    

    required init(withDictionary: Dictionary<String, AnyObject>) {
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "explanation" { self.explanation = value as! String }
            
            if key == "actions" { self.setActionsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            
            if key == "rules" { self.setRulesForArray(value as! [String]) }
            if key == "items" { self.setItemsForArray(value as! [String]) }
        }
    }
    
    init() {
        
    }

    
}
