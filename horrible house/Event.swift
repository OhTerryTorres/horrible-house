//
//  Event.swift
//  horrible house
//
//  Created by TerryTorres on 3/19/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Event: NSObject, NSCoding, DictionaryBased, RuleBased {
    
    var name = ""
    var stages : [Stage] = []
    var currentStage : Stage?
    var rules: [Rule] = []
    var completed = false

    required init(withDictionary: Dictionary<String, AnyObject>) {
        super.init()
        
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
    
    init(name: String, stages: [Stage], currentStage: Stage?, rules: [Rule], completed: Bool) {
        self.name = name
        self.stages = stages
        self.currentStage = currentStage
        self.rules = rules
        self.completed = completed
    }
    
    override init() {
        
    }
    
    // This will make the first stage in self.stages that follows the rules
    // into the default stage. This can be changed if a better method appears.
    func setCurrentStage() {
        print("EVENT – begin setCurrentStage")
        for stage in self.stages {
            if stage.isFollowingTheRules() { self.currentStage = stage ; break }
        }
        print("EVENT – end setCurrentStage")
    }
    
    // MARK: ENCODING
    
    func encodeWithCoder(coder: NSCoder) {
        
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.stages, forKey: "stages")
        
        
        if let currentStage = self.currentStage {
            coder.encodeObject(currentStage, forKey: "currentStage")
        }
        
        coder.encodeObject(self.rules, forKey: "rules")
        
        coder.encodeBool(self.completed, forKey: "completed")
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObjectForKey("name") as! String
        self.stages = decoder.decodeObjectForKey("stages") as! [Stage]
        if let currentStage = decoder.decodeObjectForKey("currentStage") as? Stage? {
            self.currentStage = currentStage
        }
        self.rules = decoder.decodeObjectForKey("rules") as! [Rule]
        self.completed = decoder.decodeBoolForKey("completed")

    }
    
}
