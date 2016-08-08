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

class Idea: NSObject, NSCoding {
    var detail = Detail()
    var isHighPriority = false
    
    init(withDictionary: Dictionary<String, AnyObject>) {
        for (key, value) in withDictionary {
            if key == "detail" { self.detail = Detail(withDictionary: value as! Dictionary<String, AnyObject>) }
            if key == "isHighPriority" { self.isHighPriority = true }
        }
    }
    
    override init() {
        
    }
    
    init(detail: Detail, isHighPriority: Bool){
        self.detail = detail
        self.isHighPriority = isHighPriority
    }
    
    // MARK: ENCODING
    
    func encodeWithCoder(coder: NSCoder) {
        
        coder.encodeObject(self.detail, forKey: "detail")
        coder.encodeBool(self.isHighPriority, forKey: "isHighPriority")
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        self.detail = decoder.decodeObjectForKey("detail") as! Detail
        self.isHighPriority = decoder.decodeBoolForKey("isHighPriority")
    }
    
}

class SkullController: UIViewController {
    
    var house : House = (UIApplication.sharedApplication().delegate as! AppDelegate).house
    var skull : Skull = (UIApplication.sharedApplication().delegate as! AppDelegate).house.skull
    @IBOutlet var ideaLabel: UILabel!
    
    override func viewDidLoad() {
        self.view.setStyleInverse()
        
        for idea in self.skull.ideasToSayAloud {
            if idea.detail.isFollowingTheRules() == false {
                print("SKULLCONTROLLER – It turns out \(idea.detail.explanation) is not following the rules")
                if let index = self.skull.ideasToSayAloud.indexOf({$0.detail.explanation == idea.detail.explanation}) {
                    self.skull.ideas += [idea]
                    self.skull.ideasToSayAloud.removeAtIndex(index)
                }
            }
        }
        
    }
    
    func addTestItems() {
        // let itemA = Item()
        // itemA.name = "Bandage"
        // self.house.player.items += [itemA]
    }
    
    
    @IBAction func displayIdea(sender: AnyObject) {
        if self.skull.ideasToSayAloud.count > 0 {
            let index = self.skull.ideasToSayAloud.count - 1
            
            let string = "\(self.skull.ideasToSayAloud[index].detail.explanation)"
            self.ideaLabel.setTextWithTypeAnimation(string)
            self.ideaLabel.font = Font.basicFont
            
            print("removing from ideasToSayAloud: \(self.skull.ideasToSayAloud[index].detail.explanation)")
            
            self.skull.ideasToSayAloud.removeAtIndex(index)
        } else {
            self.ideaLabel.text = ""
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.house = (UIApplication.sharedApplication().delegate as! AppDelegate).house
        self.skull = (UIApplication.sharedApplication().delegate as! AppDelegate).house.skull
        

    }
    
    override func viewWillDisappear(animated: Bool) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).house = self.house
        (UIApplication.sharedApplication().delegate as! AppDelegate).house.skull = self.skull
    }

}
