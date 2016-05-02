//
//  SkullController.swift
//  horrible house
//
//  Created by TerryTorres on 5/2/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation
import UIKit


// The skull has Ideas, which are basically Details but with more sass.

class Idea {
    let detail : Detail
    var isHighPriority = false
    
    init(withDictionary: Dictionary<String, AnyObject>) {
        for (key, value) in withDictionary {
            if key == "detail" { self.detail = Detail(withDictionary: value as! Dictionary<String, AnyObject>)
            if key == "isHighPriority" { self.isHighPriority = true }
        }
    }
}

class SkullController: UIViewController {
    
    var ideas : [Idea] = []
    var ideasToSayAloud : [Idea] = []
    
    override func viewDidLoad() {
        let path = NSBundle.mainBundle().pathForResource("Skull", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!) as! Dictionary<String,AnyObject>
        
        // add a caveat for when reloading from a saved game
        
        for (_, value) in dict {
            let idea = Idea(withDictionary: value as! Dictionary<String,AnyObject>)
            self.ideas += [idea]
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        for idea in self.ideas {
            if idea.detail.isFollowingTheRules() {
                if idea.isHighPriority {
                    self.ideasToSayAloud += [idea]
                }
            }
        }
    }
    
    

}
