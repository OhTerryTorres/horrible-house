//
//  ExplorationController.swift
//  horrible house
//
//  Created by TerryTorres on 3/9/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class ExplorationController: GameController {
    override var gameMode : GameMode {
        get {
            return GameMode.Exploration
        }
        set {
            
        }
    }
    
    
    

    @IBAction func unwind(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func backToGame(segue: UIStoryboardSegue) {
        self.navigationController?.navigationBar.isHidden = false
        
        
        // This toggles the flashback.
        if self.house.inFlashback == true {
            self.house = House(layout: House.LayoutOptions.b)
            if let npcData = UserDefaults.standard.object(forKey: "npcData") {
                self.house.npcs = (NSKeyedUnarchiver.unarchiveObject(with: npcData as! Data) as? [Character])!
            }
        } else {
            self.house = House(layout: House.LayoutOptions.b)
            self.house.inFlashback = true
        }
        
        
        
        (UIApplication.shared.delegate as! AppDelegate).house = self.house
        self.gameMode = GameMode.Exploration
        self.viewDidLoad()
        
    }

}
