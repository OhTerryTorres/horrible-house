//
//  TitleViewController.swift
//  horrible house
//
//  Created by TerryTorres on 6/28/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var startGameButton: UIButton!
    
    @IBOutlet var restartGameButton: UIButton!
    
    
    
    override func viewDidLoad() {
        if NSUserDefaults.standardUserDefaults().objectForKey("savedHouse") != nil {
            self.startGameButton.titleLabel?.text = "RETURN TO THE HOUSE"
        } else {
            self.restartGameButton.hidden = true
        }
    }

    @IBAction func startGame(sender: AnyObject) {
        
    }

    @IBAction func restartGame(sender: AnyObject) {
        
    }
}
