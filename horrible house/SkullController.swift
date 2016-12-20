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
    
    public func encode(with coder: NSCoder) {
        
        coder.encode(self.detail, forKey: "detail")
        coder.encode(self.isHighPriority, forKey: "isHighPriority")
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        self.detail = decoder.decodeObject(forKey: "detail") as! Detail
        self.isHighPriority = decoder.decodeBool(forKey: "isHighPriority")
    }
    
}

class SkullController: UIViewController {
    
    var house : House = (UIApplication.shared.delegate as! AppDelegate).house
    var skull : Skull = (UIApplication.shared.delegate as! AppDelegate).house.skull
    @IBOutlet var ideaLabel: UILabel!
    @IBOutlet var button: UIButton!
    @IBOutlet var skullView: UIImageView!
    
    override func viewDidLoad() {
        self.view.setStyleInverse()
        self.ideaLabel.setStyleInverse()
        self.button.titleLabel!.setStyleInverse()
        self.button.tintColor = Color.specialColor
        
        self.ideaLabel.text = ""
        
        for idea in self.skull.ideasToSayAloud {
            if idea.detail.isFollowingTheRules() == false {
                print("SKULLCONTROLLER – It turns out \(idea.detail.explanation) is not following the rules")
                if let index = self.skull.ideasToSayAloud.index(where: {$0.detail.explanation == idea.detail.explanation}) {
                    self.skull.ideas += [idea]
                    self.skull.ideasToSayAloud.remove(at: index)
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
            let idea = self.skull.ideasToSayAloud[index]
            
            if idea.detail.isFollowingTheRules() {
                self.animateSkull(withIdea: idea)
                
                let string = "\(idea.detail.explanation)"
                self.ideaLabel.setTextWithTypeAnimation(typedText: string)
                
                
                print("removing from ideasToSayAloud: \(idea.detail.explanation)")
                
                self.skull.ideasToSayAloud.remove(at: index)
            } else { self.ideaLabel.text = "" }
        } else { self.ideaLabel.text = "" }
    }
    
    
    func animateSkull(withIdea idea:Idea) {
        //add images to the array
        let skullClose = UIImage(named:"skullClose")!
        let skullOpen = UIImage(named:"skullOpen")!
        let imagesListArray = [skullOpen, skullClose]
        
        self.skullView.animationImages = imagesListArray;
        self.skullView.animationDuration = 0.5
        self.skullView.startAnimating()
        let interval = Double(Double(idea.detail.explanation.characters.count) * 0.04 - (Double(idea.detail.explanation.characters.count) * 0.01))

        _ = Timer.scheduledTimer(timeInterval: interval, target:self, selector: #selector(self.animateSkullStop), userInfo: nil, repeats: false)
        self.button.isUserInteractionEnabled = false
    }
    
    func animateSkullStop() {
        self.skullView.stopAnimating()
        self.button.isUserInteractionEnabled = true
    }
    
    func viewWillAppear(animated: Bool) {
        if let nc = self.navigationController {
            nc.navigationBar.isHidden = true
        }
        self.house = (UIApplication.shared.delegate as! AppDelegate).house
        self.skull = (UIApplication.shared.delegate as! AppDelegate).house.skull
        

    }
    
    func viewWillDisappear(animated: Bool) {
        if let nc = self.navigationController {
            nc.navigationBar.isHidden = false
        }
        (UIApplication.shared.delegate as! AppDelegate).house = self.house
        (UIApplication.shared.delegate as! AppDelegate).house.skull = self.skull
    }

}
