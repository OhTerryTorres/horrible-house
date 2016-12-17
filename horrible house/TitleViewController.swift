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
        
        self.view.setStyle()
        self.titleLabel.font = Font.mainTitleFont
        self.startGameButton.titleLabel!.font = Font.basicFont
        self.restartGameButton.titleLabel!.font = Font.basicFont
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = UserDefaults.standard.object(forKey: "houseData") {
            self.startGameButton.setTitle("RETURN TO THE HOUSE", for: UIControlState.normal)
        } else {
            self.restartGameButton.isHidden = true
        }
    }

    @IBAction func startGame(sender: AnyObject) {
        if let houseData = UserDefaults.standard.data(forKey: "houseData") {
            self.house = NSKeyedUnarchiver.unarchiveObject(with: houseData) as? House
            (UIApplication.shared.delegate as! AppDelegate).house = self.house!
            performSegue(withIdentifier: "segue", sender: self)
        } else {
            self.restartGame(sender: self)
        }
    }

    @IBAction func restartGame(sender: AnyObject) {
        UserDefaults.standard.set(nil, forKey: "houseData")
        self.house = (UIApplication.shared.delegate as! AppDelegate).house
        print("MY ASSSSS")
        performSegue(withIdentifier: "segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("FUUUUCK")
        let tbc = segue.destination as! TabBarController
        let nvc = tbc.viewControllers![0] as! UINavigationController
        let exc = nvc.viewControllers[0] as! ExplorationController
        exc.house = self.house!
        exc.itemCount = self.house!.currentRoom.items.count
        print("exc.house.currentRoom.name is \(exc.house.currentRoom.name)")
    }
    
    /*
    @IBAction func backToTitle(segue: UIStoryboardSegue) {
       (UIApplication.sharedApplication().delegate as! AppDelegate).house = House(layout: House.LayoutOptions.a)
    }
    */
}
