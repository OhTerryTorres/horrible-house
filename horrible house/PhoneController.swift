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
    
    var house : House = (UIApplication.sharedApplication().delegate as! AppDelegate).house

    var numbersDialed : String = ""
    
    var isTabBarNeeded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        self.view.backgroundColor = UIColor.blackColor()
        UIApplication.sharedApplication().statusBarHidden = true
        
        // Make it so piano doesn't stick behind Tab Bar
        if self.tabBarController?.tabBar.hidden == false {
            self.isTabBarNeeded = true
            self.tabBarController?.tabBar.hidden = true
        }
        
        self.drawPhone()
        
    }
    
    func drawPhone() {
        let keyPadView = UIView()
        self.view.addSubview(keyPadView)
        keyPadView.frame = CGRectMake(self.view.frame.width * 0.1, self.view.frame.height * 0.2, self.view.frame.width * 0.79, self.view.frame.height * 0.6)
        keyPadView.backgroundColor = UIColor.darkGrayColor()
        
        self.view.addSubview(keyPadView)
        
        let keyHeight = keyPadView.frame.size.height / 4
        
        var i = 1
        // 4 rows
        for var y = CGFloat(0); y < 4; y++ {
            // 3 buttons per row
            for var x = CGFloat(0); x < 3; x++ {
                let keyView = UIView()
                keyPadView.addSubview(keyView)
                
                keyView.frame = CGRectMake(x * keyHeight, y * keyHeight, keyHeight, keyHeight)
                keyView.backgroundColor = UIColor.blueColor()
                
                let string = specialKeyStringForIndex(i)
                
                let keyButton = SuperButton(type: UIButtonType.Custom) as SuperButton
                
                // Sets qualifier equal to whatever is supposed to be read on the phone key
                keyButton.qualifier = string
                
                keyView.addSubview(keyButton)
                
                print("adding \(string) button")
                
                keyButton.addTarget(self, action: "dialNumber:", forControlEvents:.TouchDown)
                
                keyButton.setTitle(string, forState: UIControlState.Normal)
                
                keyButton.backgroundColor = UIColor.redColor()
                keyButton.setBackgroundImage(UIImage(named: "white.png"), forState: UIControlState.Highlighted)
                
                keyButton.frame = CGRectMake(
                    keyHeight * 0.125,
                    keyHeight * 0.125,
                    keyHeight * 0.75,
                    keyHeight * 0.75
                )
                
                i++
            }
        }
    }
    
    // This prepares for the last row of keys
    func specialKeyStringForIndex(i: Int) -> String {
        var string = "\(i)"
        switch i {
        case 10:
            string = "*"
        case 11:
            string = "0"
        case 12:
            string = "#"
        default:
            break
        }
        return string
    }
    
    func dialNumber(sender: SuperButton) {
        // let string = "key\(sender.qualifier)"
        print("in dialNumber for \(sender.qualifier)")
        // SystemSoundID.playFileNamed(string, withExtenstion: "mp3")
        self.numbersDialed += sender.qualifier
        self.checkNumber()
        
    }
    
    func checkNumber() {
        if self.numbersDialed.characters.count > 7 {
            self.numbersDialed = String(self.numbersDialed.characters.dropFirst())
        }
        print("\(self.numbersDialed)")
        
        if (self.numbersDialed.rangeOfString("5277859") != nil) {
            print("RING RING")
            self.numbersDialed = ""
        }

    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.isTabBarNeeded == true {
            self.tabBarController?.tabBar.hidden = false
        }
        
    }
}
