//
//  RuleBased.swift
//  horrible house
//
//  Created by TerryTorres on 3/22/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation
import UIKit

protocol RuleBased : class {
    var rules : [Rule] { get set }
}

extension RuleBased {
    func setRulesForArray(array:[String]) {
        for ruleName in array {
            let rule = Rule(name: ruleName)
            self.rules += [rule]
        }
    }
    
    
    func isFollowingTheRules() -> Bool {
        var rulesFollowed = true
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let house = appDelegate.house
        
        for rule in rules {
            print("rule.name is \(rule.name)")
            print("rule.type is \(rule.type)")
            switch ( rule.type) {
                
            case Rule.RuleType.hasItem:
                print("hasItem??")
                rulesFollowed = false
                if let _ = house.player.items.indexOf({$0.name == rule.name}) {
                    rulesFollowed = true
                    print("\(rule.name) is present! So the rule is being followed.")
                }
                
            case Rule.RuleType.nopeHasItem:
                print("nopeHasItem??")
                rulesFollowed = true
                if let _ = house.player.items.indexOf({$0.name == rule.name}) {
                    rulesFollowed = false
                    print("\(rule.name) is NOT present! So the rule is being followed.")
                }
                
            case Rule.RuleType.metCharacter:
                break
            case Rule.RuleType.nopeMetCharacter:
                break
            case Rule.RuleType.enteredRoom:
                var i = 0; for room in house.rooms {
                    if room.timesEntered > 0 { i++ }
                }; if i == 0 { rulesFollowed = false }
            case Rule.RuleType.nopeEnteredRoom:
                var i = 0; for room in house.rooms {
                    if room.timesEntered == 0 { i++ }
                }; if i == 0 { rulesFollowed = false }
            case Rule.RuleType.completedEvent:
                break
            case Rule.RuleType.nopeCompletedEvent:
                break
            default:
                break;
            }
        }
        
        return rulesFollowed
    }
    
}