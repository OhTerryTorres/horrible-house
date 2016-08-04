//
//  Stage.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Stage: NSObject, NSCoding, DictionaryBased, ItemBased, RuleBased, ActionPacked {

    // MARK: Properties
    
    var name = ""
    var explanation = ""
    var actions : [Action] = []
    var rules: [Rule] = []
    var items: [Item] = []
    

    required init(withDictionary: Dictionary<String, AnyObject>) {
        super.init()
        
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "explanation" { self.explanation = value as! String }
            
            if key == "actions" { self.setActionsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            
            if key == "rules" { self.setRulesForArray(value as! [String]) }
            if key == "items" { self.setItemsForDictionary(value as! [Dictionary<String, AnyObject>]) }
        }
    }
    
    init(name: String, explanation: String, actions: [Action], rules: [Rule], items: [Item]) {
        self.name = name
        self.explanation = explanation
        self.actions = actions
        self.rules = rules
        self.items = items
    }
    
    override init() {
        
    }

    // MARK: ENCODING
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.explanation, forKey: "explanation")
        coder.encodeObject(self.actions, forKey: "actions")
        coder.encodeObject(self.rules, forKey: "rules")
        coder.encodeObject(self.items, forKey: "items")
        
    }
    
    
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObjectForKey("name") as! String
        self.explanation = decoder.decodeObjectForKey("explanation") as! String
        self.actions = decoder.decodeObjectForKey("actions") as! [Action]
        self.rules = decoder.decodeObjectForKey("rules") as! [Rule]
        self.items = decoder.decodeObjectForKey("items") as! [Item]

    }
    
    
}
