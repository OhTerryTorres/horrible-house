//
//  PhoneController.swift
//  horrible house
//
//  Created by TerryTorres on 4/16/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AudioToolbox


class PhoneController: UIViewController {
    
    var house : House = (UIApplication.shared.delegate as! AppDelegate).house

    var numbersDialed : String = ""
    
    var isTabBarNeeded = false
    
    var timer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        self.view.backgroundColor = UIColor.red
        UIApplication.shared.isStatusBarHidden = true
        
        // Make it so phone doesn't stick behind Tab Bar
        if self.tabBarController?.tabBar.isHidden == false {
            self.isTabBarNeeded = true
            self.tabBarController?.tabBar.isHidden = true
        }
        
        
        self.drawPhone()
        
    }
    
    func drawPhone() {
        let keyPadView = UIView()
        self.view.addSubview(keyPadView)
        keyPadView.frame = CGRect(x: self.view.frame.width * 0.1, y: self.view.frame.height * 0.2, width: self.view.frame.width * 0.79, height: self.view.frame.height * 0.6)
        
        self.view.addSubview(keyPadView)
        
        let keyHeight = keyPadView.frame.size.height / 4
        
        var i = 1
        // 4 rows
        var y = CGFloat(0)
        var x = CGFloat(0)
        while y < 4 {
            // 3 buttons per row
            
            while x < 3 {
                let keyView = UIView()
                keyPadView.addSubview(keyView)
                
                keyView.frame = CGRect(x: x * keyHeight, y: y * keyHeight, width: keyHeight, height: keyHeight)
                keyView.backgroundColor = UIColor.black
                
                let string = specialKeyStringForIndex(i: i)
                
                print("PHONE string is \(string)")
                
                let keyButton = SuperButton(type: UIButtonType.custom) as SuperButton
                
                // Sets qualifier equal to whatever is supposed to be read on the phone key
                keyButton.qualifier = string
                
                keyView.addSubview(keyButton)
                
                print("adding \(string) button")
                
                keyButton.addTarget(self, action: #selector(touchDown), for:.touchDown)
                keyButton.addTarget(self, action: #selector(touchUp), for:[.touchUpInside, .touchUpOutside])
                
                keyButton.titleLabel!.font = Font.phoneFont
                keyButton.titleLabel!.textColor = UIColor.black
                keyButton.setTitle(string, for: UIControlState.normal)
                if string.range(of: "Star") != nil { keyButton.setTitle("*", for: UIControlState.normal) }
                
                keyButton.backgroundColor = Color.backgroundColor
                keyButton.setBackgroundImage(UIImage(named: "white.png"), for: UIControlState.highlighted)
                
                keyButton.frame = CGRect(
                    x: keyHeight * 0.125,
                    y: keyHeight * 0.125,
                    width: keyHeight * 0.75,
                    height: keyHeight * 0.75
                )
                
                i += 1
                x += 1
            }
            y += 1
            x = 0
        }
    }
    
    // This prepares for the last row of keys
    func specialKeyStringForIndex(i: Int) -> String {
        var string = "\(i)"
        switch i {
        case 10:
            string = "Star"
        case 11:
            string = "0"
        case 12:
            string = "#"
        default:
            break
        }
        return string
    }
    
    
    
    func dialNumber(sender: Timer) {
        let string = "key\(sender.userInfo!)"
        //SystemSoundID.playFileNamed(string, withExtenstion: "mp3")
        print("WOW \(string)")
        
    }
    
    func touchDown(sender: SuperButton) {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(dialNumber), userInfo: sender.qualifier, repeats: true)
        dialNumber(sender: timer)
    }
    
    func touchUp(sender: SuperButton) {
        timer.invalidate()
        self.numbersDialed += sender.qualifier
        self.checkNumber()
    }
    
    func checkNumber() {
        if self.numbersDialed.characters.count > 7 {
            self.numbersDialed = String(self.numbersDialed.characters.dropFirst())
        }
        print("\(self.numbersDialed)")
        
        if (self.numbersDialed.range(of: "5277859") != nil) {
            print("RING RING")
            self.numbersDialed = ""
            if let index = self.house.events.index(where: { $0.name == "5277859" }) {
                if self.house.events[index].isFollowingTheRules() {
                    self.house.currentEvent = self.house.events[index]
                    self.house.currentEvent.currentStage = self.house.currentEvent.stages[0]
                    let dict = ["eventName" : self.house.currentEvent.name]
                    performSegue(withIdentifier: "event", sender: dict as AnyObject)
                }
            }
        }
        
        if (self.numbersDialed.range(of: "911") != nil) {
            print("RING RING")
            self.numbersDialed = ""
            if let index = self.house.events.index(where: { $0.name == "911" }) {
                if self.house.events[index].isFollowingTheRules() {
                    self.house.currentEvent = self.house.events[index]
                    self.house.currentEvent.currentStage = self.house.currentEvent.stages[0]
                    let dict = ["eventName" : self.house.currentEvent.name]
                    performSegue(withIdentifier: "event", sender: dict as AnyObject)
                }
            }
        }
        if (self.numbersDialed.range(of: "Star69") != nil) {
            print("RING RING")
            self.numbersDialed = ""
            if let index = self.house.events.index(where: { $0.name == "Star69" }) {
                if self.house.events[index].isFollowingTheRules() {
                    self.house.currentEvent = self.house.events[index]
                    self.house.currentEvent.currentStage = self.house.currentEvent.stages[0]
                    let dict = ["eventName" : self.house.currentEvent.name]
                    performSegue(withIdentifier: "event", sender: dict as AnyObject)
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        (UIApplication.shared.delegate as! AppDelegate).house = self.house
        
        if segue.identifier == "event" {
            if let triggerEventDict = sender as? Dictionary<String, String> {
                self.house.currentEvent = self.house.eventForName(name: triggerEventDict["eventName"]!)!
                self.house.currentEvent.currentStage = self.house.currentEvent.getStageThatFollowsRulesFromStagesArray(stages: self.house.currentEvent.stages)
                if let stageName = triggerEventDict["stageName"] {
                    if let index = self.house.currentEvent.stages.index(where: {$0.name == stageName}) {
                        self.house.currentEvent.currentStage = self.house.currentEvent.stages[index]
                    }
                }
                
                let ec = segue.destination as! EventController
                ec.house = self.house
                
            }
            
        }
    }
    
    func viewWillDisappear(animated: Bool) {
        if self.isTabBarNeeded == true {
            self.tabBarController?.tabBar.isHidden = false
        }
        
    }
}
