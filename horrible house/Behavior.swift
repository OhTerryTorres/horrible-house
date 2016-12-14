//
//  Behavior.swift
//  horrible house
//
//  Created by TerryTorres on 8/8/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

enum BehaviorType: String {
    case Default, // Just stay in place
    Random, // Go randomly from room to room
    PursuePlayer // Find the shortest route to the room the player is in.
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
                if value as! String == "PursuePlayer" {
                    self.type = BehaviorType.PursuePlayer
                }
            }
            if key == "rules" { self.setRulesForArray(array: value as! [String]) }
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
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.qualifier, forKey: "qualifier")
        coder.encode(self.type.rawValue, forKey: "type")
        coder.encode(self.rules, forKey: "rules")
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.qualifier = decoder.decodeObject(forKey: "qualifier") as! String
        self.type = BehaviorType(rawValue: decoder.decodeObject(forKey: "type") as! String)!
        self.rules = decoder.decodeObject(forKey: "rules") as! [Rule]
        
    }

}
