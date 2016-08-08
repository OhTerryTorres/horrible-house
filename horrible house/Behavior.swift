//
//  Behavior.swift
//  horrible house
//
//  Created by TerryTorres on 8/8/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

enum BehaviorType: String {
    case Default, Random
}

class Behavior: NSObject, NSCoding, RuleBased, DictionaryBased {
    
    
    var type = BehaviorType.Default
    var qualifier = ""
    var rules : [Rule] = []
    
    
    
    required init(withDictionary: Dictionary<String, AnyObject>) {
        super.init()
        for (key, value) in withDictionary {
            if key == "qualifier" { self.qualifier = value as! String }
            if key == "type" {
                if value as! String == "Random" {
                    self.type = BehaviorType.Random
                }
                if value as! String == "Default" {
                    self.type = BehaviorType.Default
                }
            }
            if key == "rules" { self.setRulesForArray(value as! [String]) }
        }
    }
    
    init(qualifier: String, type: BehaviorType, rules: [Rule]) {
        self.qualifier = qualifier
        self.type = type
        self.rules = rules
    }
    
    override init() {
        
    }
    
    // MARK: ENCODING
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.qualifier, forKey: "qualifier")
        coder.encodeObject(self.type.rawValue, forKey: "type")
        coder.encodeObject(self.rules, forKey: "rules")
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.qualifier = decoder.decodeObjectForKey("qualifier") as! String
        self.type = BehaviorType(rawValue: decoder.decodeObjectForKey("type") as! String)!
        self.rules = decoder.decodeObjectForKey("rules") as! [Rule]
        
    }

}
