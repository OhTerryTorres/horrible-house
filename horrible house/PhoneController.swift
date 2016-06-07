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
    
    var timer: NSTimer!
    
    
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
                
                keyButton.addTarget(self, action: "touchDown:", forControlEvents:.TouchDown)
                keyButton.addTarget(self, action: "touchUp:", forControlEvents:[.TouchUpInside, .TouchUpOutside])
                
                keyButton.titleLabel!.font = Font.phoneFont
                keyButton.setTitle(string, forState: UIControlState.Normal)
                if string.rangeOfString("Star") != nil { keyButton.setTitle("*", forState: UIControlState.Normal) }
                
                keyButton.backgroundColor = UIColor.redColor()
                keyButton.setBackgroundImage(UIImage(named: "white.png"), forState: UIControlState.Highlighted)
                
                keyButton.frame = CGRectMake(
                    keyHeight * 0.125,
                    keyHeight * 0.125,
                    keyHeight * 0.75,
                    keyHeight * 0.75
                )
                
                i += 1
            }
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
    
    
    
    func dialNumber(sender: NSTimer) {
        let string = "key\(sender.userInfo!)"
        //SystemSoundID.playFileNamed(string, withExtenstion: "mp3")
        print("WOW \(string)")
        
    }
    
    func touchDown(sender: SuperButton) {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "dialNumber:", userInfo: sender.qualifier, repeats: true)
        dialNumber(timer)
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
