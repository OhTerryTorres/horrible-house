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
            
            if key == "actions" { self.setActionsForArrayOfDictionaries(dictArray: value as! [Dictionary<String, AnyObject>]) }
            
            if key == "rules" { self.setRulesForArray(array: value as! [String]) }
            if key == "items" { self.setItemsForDictionary(dictArray: value as! [Dictionary<String, AnyObject>]) }
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
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.explanation, forKey: "explanation")
        aCoder.encode(self.actions, forKey: "actions")
        aCoder.encode(self.rules, forKey: "rules")
        aCoder.encode(self.items, forKey: "items")
    }
    
    
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.explanation = decoder.decodeObject(forKey: "explanation") as! String
        self.actions = decoder.decodeObject(forKey: "actions") as! [Action]
        self.rules = decoder.decodeObject(forKey: "rules") as! [Rule]
        self.items = decoder.decodeObject(forKey: "items") as! [Item]

    }
    
    
}
