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
    var sudden = false

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
                self.currentStage = getStageThatFollowsRulesFromStagesArray(self.stages)
            }
            
            if key == "sudden" { // Sudden events can be called during the player turn. Otherwise, they trigger on an action
                self.sudden = true
            }
            
            if key == "rules" { self.setRulesForArray(value as! [String]) }
        }
    }
    
    init(name: String, stages: [Stage], currentStage: Stage?, rules: [Rule], completed: Bool, sudden: Bool) {
        self.name = name
        self.stages = stages
        self.currentStage = currentStage
        self.rules = rules
        self.completed = completed
        self.sudden = sudden
    }
    
    override init() {
        
    }
    
    // This will make the first stage in self.stages that follows the rules
    // into the default stage. This can be changed if a better method appears.
    func getStageThatFollowsRulesFromStagesArray(stages: [Stage]) -> Stage {
        print("EVENT – begin setCurrentStage")
        var s = Stage()
        for stage in stages {
            if stage.isFollowingTheRules() { s = stage ; break }
        }
        return s
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
        
        coder.encodeBool(self.sudden, forKey: "sudden")
        
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
        self.sudden = decoder.decodeBoolForKey("sudden")

    }
    
}
