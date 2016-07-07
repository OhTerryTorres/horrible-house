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
    
    var house : House?
    
    override func viewDidLoad() {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("savedHouse") {
            self.startGameButton.titleLabel?.text = "RETURN TO THE HOUSE"
        } else {
            self.restartGameButton.hidden = true
        }
    }

    @IBAction func startGame(sender: AnyObject) {
        if let houseData = NSUserDefaults.standardUserDefaults().objectForKey("houseData") {
            self.house = NSKeyedUnarchiver.unarchiveObjectWithData(houseData as! NSData) as? House
            print("TITLE – self.house.rooms.count is \(self.house!.rooms.count)")
        } else {
            self.restartGame(self)
        }
        performSegueWithIdentifier("segue", sender: self)
    }

    @IBAction func restartGame(sender: AnyObject) {
        self.house = (UIApplication.sharedApplication().delegate as! AppDelegate).house
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tbc = segue.destinationViewController as! TabBarController
        let nvc = tbc.viewControllers![0] as! UINavigationController
        let exc = nvc.viewControllers[0] as! ExplorationController
        exc.house = self.house!
    }
}
