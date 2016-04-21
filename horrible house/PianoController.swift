//
//  PianoController.swift
//  horrible house
//
//  Created by TerryTorres on 3/27/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AudioToolbox

extension SystemSoundID {
    static func playFileNamed(fileName: String, withExtenstion fileExtension: String? = "aif") {
        var sound: SystemSoundID = 0
        if let soundURL = NSBundle.mainBundle().URLForResource(fileName, withExtension: fileExtension) {
            AudioServicesCreateSystemSoundID(soundURL, &sound)
            AudioServicesPlaySystemSound(sound)
        }
    }
    
}

class PianoController: UIViewController {
    
    var house : House = (UIApplication.sharedApplication().delegate as! AppDelegate).house
    
    var notesPlayed : String = ""
    
    var keyHeight : CGFloat = 0
    
    var isTabBarNeeded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        UIApplication.sharedApplication().statusBarHidden = true
        self.keyHeight = self.view.frame.size.height / 8
        
        // Make it so piano doesn't stick behind Tab Bar
        if self.tabBarController?.tabBar.hidden == false {
            self.isTabBarNeeded = true
            self.tabBarController?.tabBar.hidden = true
        }
        
        
        self.drawPianoKeys()
        //self.loadPianoNotes()
        
        
        
    }
    
    func drawPianoKeys() {
        // White keys
        for var i : CGFloat = 0 ; i < 7; i++ {
            let key = SuperButton(type: UIButtonType.Custom) as SuperButton
            key.frame = CGRectMake(0, (i * (self.keyHeight) + 1 + self.keyHeight), self.view.frame.size.width, (self.keyHeight) - 2)
            key.setBackgroundImage(UIImage(named: "white.png"), forState: UIControlState.Normal)
            key.qualifier = "white\(Int(i+1))" // we don't have any 0 notes
            key.addTarget(self, action: "playNote:", forControlEvents:.TouchDown)
            self.view.addSubview(key)
            
            
        }
        
        // Black keys
        for var i : CGFloat = 0 ; i < 5; i++ {
            let key = SuperButton(type: UIButtonType.Custom) as SuperButton
            var y = ((i * (self.keyHeight)) + 1 + (self.keyHeight * 0.6) + self.keyHeight)
            if i > 1 { y += self.keyHeight }
            key.frame = CGRectMake((self.view.frame.size.width - self.view.frame.size.width * 0.6), y, self.view.frame.size.width * 0.6, (self.keyHeight * 0.8))
            key.setBackgroundImage(UIImage(named: "black.png"), forState: UIControlState.Normal)
            key.qualifier = "black\(Int(i+1))" // we don't have any 0 notes
            key.addTarget(self, action: "playNote:", forControlEvents:.TouchDown)
            self.view.addSubview(key)
        }
    }
    
    
    // MARK: Piano Key Functions
    
    
    
    
    func playNote(sender: SuperButton) {
        let string = "\(sender.qualifier)"
        SystemSoundID.playFileNamed(string, withExtenstion: "mp3")
        self.notesPlayed += noteForSoundFileName(string)
        self.checkNotes()
    }
    
    func noteForSoundFileName(name: String) -> String {
        var string = ""
        
        if name.rangeOfString("white1") != nil { string = "C" }
        if name.rangeOfString("white2") != nil { string = "D" }
        if name.rangeOfString("white3") != nil { string = "E" }
        if name.rangeOfString("white4") != nil { string = "F" }
        if name.rangeOfString("white5") != nil { string = "G" }
        if name.rangeOfString("white6") != nil { string = "A" }
        if name.rangeOfString("white7") != nil { string = "B" }
        
        if name.rangeOfString("black1") != nil { string = "C#" }
        if name.rangeOfString("black2") != nil { string = "D#" }
        if name.rangeOfString("black3") != nil { string = "F#" }
        if name.rangeOfString("black4") != nil { string = "G#" }
        if name.rangeOfString("black5") != nil { string = "A#" }
        
        return string
    }
    
    
    func checkNotes() {
        if self.notesPlayed.characters.count > 12 {
            self.notesPlayed = String(self.notesPlayed.characters.dropFirst())
        }
        print("\(self.notesPlayed)")
        
        if (self.notesPlayed.rangeOfString("DAGDF#DF#G") != nil) {
            print("His theme!")
            self.notesPlayed = ""
        }
        
        if (self.notesPlayed.rangeOfString("CAGE") != nil) {
            print("Bird in a cage!")
            self.notesPlayed = ""
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        if self.isTabBarNeeded == true {
            self.tabBarController?.tabBar.hidden = false
        }
        
    }
    

}
