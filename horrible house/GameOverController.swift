//
//  GameOverController.swift
//  horrible house
//
//  Created by TerryTorres on 8/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class GameOverController: UIViewController {
    
    var house : House = (UIApplication.shared.delegate as! AppDelegate).house

    var message : String?
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var restartButton: UIButton!
    
    override func viewDidLoad() {
        self.view.setStyleInverse()
        self.messageLabel.font = Font.mainTitleFont
        self.messageLabel.textColor = Color.backgroundColor
        self.restartButton.titleLabel?.font = Font.basicFont
        self.restartButton.titleLabel?.textColor = Color.backgroundColor
        
        self.navigationItem.setHidesBackButton(true, animated:false);
        
        
        // Change and back up old data
        // *** STATS
        self.house.player.gamesPlayed += 1
        let statsData = NSKeyedArchiver.archivedData(withRootObject: self.house.player.stats)
        UserDefaults.standard.set(statsData, forKey: "statsData")
        
        
        // Nullify the current house data
        UserDefaults.standard.removeObject(forKey: "houseData")
        UserDefaults.standard.synchronize()
        
        // Set message for label
        if let m = message {
            messageLabel.text = m
            
        } else { messageLabel.text = "" }
        
        
        hideBars()
        saveBoxData()
        

    }
    
    func saveBoxData() {
        // This handles if the player is holding the handwritten note at game's end.
        if let i = self.house.player.items.index(where: {$0.name == "Handwritten Note"}) {
            let note = self.house.player.items[i]
            if let index = self.house.necessaryRooms["Foyer"]!.items.index(where: {$0.name == "Box"}) {
                self.house.safeBox = self.house.necessaryRooms["Foyer"]!.items[index]
                self.house.safeBox.items += [note]
            }
        }
        let boxData = NSKeyedArchiver.archivedData(withRootObject: self.house.safeBox)
        UserDefaults.standard.set(boxData, forKey: "boxData")
        UserDefaults.standard.synchronize()
    }
    
    func hideBars() {
        // Disable nav and tab bars
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Change status bar background color
        let statWindow = UIApplication.shared.value(forKey:"statusBarWindow") as! UIView
        let statusBar = statWindow.subviews[0] as UIView
        statusBar.backgroundColor = Color.foregroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Change status bar background color
        let statWindow = UIApplication.shared.value(forKey:"statusBarWindow") as! UIView
        let statusBar = statWindow.subviews[0] as UIView
        statusBar.backgroundColor = Color.backgroundColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
}

