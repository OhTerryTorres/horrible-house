//
//  Skull.swift
//  horrible house
//
//  Created by TerryTorres on 5/5/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Skull: NSObject, NSCoding {
    
    var ideas : [Idea] = []
    var ideasToSayAloud : [Idea] = []
    
    
    init(ideas: [Idea], ideasToSayAloud: [Idea]) {
        self.ideas = ideas
        self.ideasToSayAloud = ideasToSayAloud
    }
    
    override init() {
        let path = NSBundle.mainBundle().pathForResource("Skull", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!) as! Dictionary<String,AnyObject>
        
        // add a caveat for when reloading from a saved game
        
        for (_, value) in dict {
            let idea = Idea(withDictionary: value as! Dictionary<String,AnyObject>)
            self.ideas += [idea]
        }
    }
    
    func updateSkull() {
        
        for idea in self.ideas {
            if idea.detail.isFollowingTheRules() {
                
                
                if idea.isHighPriority {
                    self.ideasToSayAloud += [idea]
                } else {
                    self.ideasToSayAloud.insert(idea, atIndex: 0)
                }
                print("SKULL – adding \(idea.detail.explanation)")
                
                if let index = self.ideas.indexOf({$0.detail.explanation == idea.detail.explanation}) {
                    self.ideas.removeAtIndex(index)
                }
                
            }
        }

    }
    
    // MARK: ENCODING
    
    func encodeWithCoder(coder: NSCoder) {
        
        coder.encodeObject(self.ideas, forKey: "ideas")
        coder.encodeObject(self.ideasToSayAloud, forKey: "ideasToSayAloud")
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let ideas = decoder.decodeObjectForKey("ideas") as? [Idea],
            let ideasToSayAloud = decoder.decodeObjectForKey("ideasToSayAloud") as? [Idea]
            else { return nil }
        
        self.init(
            ideas: ideas,
            ideasToSayAloud: ideasToSayAloud
        )
    }

}