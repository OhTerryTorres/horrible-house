//
//  Skull.swift
//  horrible house
//
//  Created by TerryTorres on 5/5/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Skull: NSObject, NSCoding, DictionaryBased {
    
    var ideas : [Idea] = []
    var ideasToSayAloud : [Idea] = []
    
    
    init(ideas: [Idea], ideasToSayAloud: [Idea]) {
        self.ideas = ideas
        self.ideasToSayAloud = ideasToSayAloud
    }
    
    required init(withDictionary: Dictionary<String, AnyObject>) {
        for (_, value) in withDictionary {
            let idea = Idea(withDictionary: value as! Dictionary<String,AnyObject>)
            self.ideas += [idea]
        }
        
    }
    
    override init() {
        let path = Bundle.main.path(forResource: "Skull", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!) as! Dictionary<String,AnyObject>
        
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
                    self.ideasToSayAloud.insert(idea, at: 0)
                }
                print("SKULL – adding \(idea.detail.explanation)")
                
                if let index = self.ideas.index(where: {$0.detail.explanation == idea.detail.explanation}) {
                    self.ideas.remove(at: index)
                }
                
            }
        }

        }
    
    // MARK: ENCODING
    
    public func encode(with coder: NSCoder) {
        
        coder.encode(self.ideas, forKey: "ideas")
        coder.encode(self.ideasToSayAloud, forKey: "ideasToSayAloud")
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.ideas = decoder.decodeObject(forKey: "ideas") as! [Idea]
        self.ideasToSayAloud = decoder.decodeObject(forKey: "ideasToSayAloud") as! [Idea]

    }

}
