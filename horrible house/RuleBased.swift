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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let house = appDelegate.house
        
        for rule in rules {
            switch ( rule.type) {
                
            case Rule.RuleType.hasItem:
                rulesFollowed = false
                if let _ = house.player.items.index(where: {$0.name == rule.name}) {
                    print("RULEBASED – player DOES have \(rule.name). Rule followed!")
                    rulesFollowed = true
                }
                
            case Rule.RuleType.nopeHasItem:
                rulesFollowed = true
                if let _ = house.player.items.index(where: {$0.name == rule.name}) {
                    print("RULEBASED – player DOES have \(rule.name). Rule broken!")
                    rulesFollowed = false
                }
                
            case Rule.RuleType.metCharacter:
                break
            case Rule.RuleType.nopeMetCharacter:
                break
            case Rule.RuleType.enteredRoom:
                if let room = house.roomForName(name: rule.name) {
                    if room.timesEntered == 0 { rulesFollowed = false }
                }
            case Rule.RuleType.nopeEnteredRoom:
                if let room = house.roomForName(name: rule.name) {
                    if room.timesEntered > 0 { rulesFollowed = false }
                }
            case Rule.RuleType.completedEvent:
                if let index = house.events.index(where: {$0.name == rule.name}) {
                    if house.events[index].completed == false {
                        rulesFollowed = false
                    }
                }
                break
            case Rule.RuleType.nopeCompletedEvent:
                if let index = house.events.index(where: {$0.name == rule.name}) {
                    if house.events[index].completed == true {
                        rulesFollowed = false
                    }
                }
                break
            case Rule.RuleType.inRoomWithCharacter:
                print("RULEBASED – RuleType:  inRoomWithCharacter")
                if let index = house.currentRoom.characters.index(where: {$0.name == rule.name}) {
                    let character = house.currentRoom.characters[index]
                    if character.hidden == true {
                        rulesFollowed = false
                    }
                } else {
                    print("RULEBASED – player is NOT in room with \(rule.name)")
                    rulesFollowed = false
                }
                break
            case Rule.RuleType.nopeInRoomWithCharacter:
                print("RULEBASED – RuleType:  nopeInRoomWithCharacter")
                if let _ = house.currentRoom.characters.index(where: {$0.name == rule.name}) {
                    print("RULEBASED – player IS in room with \(rule.name)")
                    rulesFollowed = false
                }
                break
            case Rule.RuleType.timePassed:
                let hRange = rule.name.index(rule.name.startIndex, offsetBy: 2)..<rule.name.endIndex
                let h = Int(rule.name.replacingCharacters(in: hRange, with: ""))
                let mRange = rule.name.startIndex..<rule.name.index(rule.name.startIndex, offsetBy: 3)
                let m = Int(rule.name.replacingCharacters(in: mRange, with: ""))
                let time = GameTime(hours: h!, minutes: m!, seconds: 0)
                if house.gameClock.currentTime.totalTimeInSeconds() < time.totalTimeInSeconds() {
                    rulesFollowed = false
                }
                break
            case Rule.RuleType.nopeTimePassed:
                let hRange = rule.name.index(rule.name.startIndex, offsetBy: 2)..<rule.name.endIndex
                let h = Int(rule.name.replacingCharacters(in: hRange, with: ""))
                let mRange = rule.name.startIndex..<rule.name.index(rule.name.startIndex, offsetBy: 3)
                let m = Int(rule.name.replacingCharacters(in: mRange, with: ""))
                let time = GameTime(hours: h!, minutes: m!, seconds: 0)
                if house.gameClock.currentTime.totalTimeInSeconds() >= time.totalTimeInSeconds() {
                    rulesFollowed = false
                }
                break
                
            case Rule.RuleType.turnsPassed:
                let turns = Int(rule.name)
                if house.gameClock.turnsPassed < turns!  {
                    rulesFollowed = false
                }
                break
            case Rule.RuleType.nopeTurnsPassed:
                let turns = Int(rule.name)
                if house.gameClock.turnsPassed >= turns! {
                    rulesFollowed = false
                }
                break
                
            case Rule.RuleType.occupyingRoom:
                if rule.name != house.currentRoom.name {
                    rulesFollowed = false
                }
                
            case Rule.RuleType.roomInDirection:
                if rule.name.lowercased().range(of: "north") != nil {
                    if house.doesRoomExistAtPosition(position: (x: house.player.position.x, y: house.player.position.y + 1, z: house.player.position.z)) == false {
                        rulesFollowed = false
                    }
                }
                if rule.name.lowercased().range(of: "south") != nil {
                    if house.doesRoomExistAtPosition(position: (x: house.player.position.x, y: house.player.position.y - 1, z: house.player.position.z)) == false {
                        rulesFollowed = false
                    }
                }
                if rule.name.lowercased().range(of: "west") != nil {
                    if house.doesRoomExistAtPosition(position: (x: house.player.position.x - 1, y: house.player.position.y, z: house.player.position.z)) == false {
                        rulesFollowed = false
                    }
                }
                if rule.name.lowercased().range(of: "east") != nil {
                    if house.doesRoomExistAtPosition(position: (x: house.player.position.x + 1, y: house.player.position.y, z: house.player.position.z)) == false {
                        rulesFollowed = false
                    }
                }
                if rule.name.lowercased().range(of: "upstairs") != nil {
                    if house.canCharacterGoUpstairs(character: house.player) == false {
                        rulesFollowed = false
                    }
                }
                if rule.name.lowercased().range(of: "downstairs") != nil {
                    if house.canCharacterGoDownstairs(character: house.player) == false {
                        rulesFollowed = false
                    }
                }
                
            case Rule.RuleType.didStoreItem:
                if let boxData = UserDefaults.standard.object(forKey: "boxData") {
                    if let box = NSKeyedUnarchiver.unarchiveObject(with: (boxData as! NSData) as Data) as? Item {
                        if let _ = box.items.index(where: {$0.name == rule.name}) {
                        } else { rulesFollowed = false }
                    }
                }
            case Rule.RuleType.nopeDidStoreItem:
                if let boxData = UserDefaults.standard.object(forKey:"boxData") {
                    if let box = NSKeyedUnarchiver.unarchiveObject(with: (boxData as! NSData) as Data) as? Item {
                        if let _ = box.items.index(where: {$0.name == rule.name}) {
                            rulesFollowed = false
                        }
                    }
                }
            default:
                break;
            }
        }
        
        return rulesFollowed
    }
    
}
