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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        UIApplication.sharedApplication().statusBarHidden = true
        self.keyHeight = self.view.frame.size.height / 8
        
        self.drawPianoKeys()
        self.loadPianoNotes()
        
        
        
    }
    
    func drawPianoKeys() {
        // White keys
        for var i : CGFloat = 0 ; i < 7; i++ {
            let key = UIButton(type: UIButtonType.Custom) as UIButton
            key.frame = CGRectMake(0, (i * (self.keyHeight) + 1 + self.keyHeight), self.view.frame.size.width, (self.keyHeight) - 2)
            key.setBackgroundImage(UIImage(named: "white.png"), forState: UIControlState.Normal)
            let selector = "white\(Int(i))"
            key.addTarget(self, action: Selector(selector), forControlEvents:.TouchDown)
            self.view.addSubview(key)
            
            
        }
        
        // Black keys
        for var i : CGFloat = 0 ; i < 5; i++ {
            let key = UIButton(type: UIButtonType.Custom) as UIButton
            var y = ((i * (self.keyHeight)) + 1 + (self.keyHeight * 0.6) + self.keyHeight)
            if i > 1 { y += self.keyHeight }
            key.frame = CGRectMake((self.view.frame.size.width - self.view.frame.size.width * 0.6), y, self.view.frame.size.width * 0.6, (self.keyHeight * 0.8))
            key.setBackgroundImage(UIImage(named: "black.png"), forState: UIControlState.Normal)
            let selector = NSSelectorFromString("black\(Int(i))")
            key.addTarget(self, action: selector, forControlEvents:.TouchDown)
            self.view.addSubview(key)
        }
    }
    
    func loadPianoNotes() {
        for var i = 0 ; i < 12 ; i++ {
            if let soundURL = NSBundle.mainBundle().URLForResource("\(i)", withExtension: "mp3") {
                print("YOINK")
                var mySound: SystemSoundID = SystemSoundID(i)
                AudioServicesCreateSystemSoundID(soundURL, &mySound)
            }
        }
    }
    
    
    // MARK: Piano Key Functions
    
    func white0() {
        SystemSoundID.playFileNamed("1", withExtenstion: "mp3")
        self.notesPlayed += "C"
        self.checkNotes()
        
    }
    func white1() {
        SystemSoundID.playFileNamed("3", withExtenstion: "mp3")
        self.notesPlayed += "D"
        self.checkNotes()
    }
    func white2() {
        SystemSoundID.playFileNamed("5", withExtenstion: "mp3")
        self.notesPlayed += "E"
        self.checkNotes()
    }
    func white3() {
        SystemSoundID.playFileNamed("6", withExtenstion: "mp3")
        self.notesPlayed += "F"
        self.checkNotes()
    }
    func white4() {
        SystemSoundID.playFileNamed("8", withExtenstion: "mp3")
        self.notesPlayed += "G"
        self.checkNotes()
    }
    func white5() {
        SystemSoundID.playFileNamed("10", withExtenstion: "mp3")
        self.notesPlayed += "A"
        self.checkNotes()
    }
    func white6() {
        SystemSoundID.playFileNamed("12", withExtenstion: "mp3")
        self.notesPlayed += "B"
        self.checkNotes()
    }
    
    func black0() {
        SystemSoundID.playFileNamed("2", withExtenstion: "mp3")
        self.notesPlayed += "C#"
        self.checkNotes()
    }
    func black1() {
        SystemSoundID.playFileNamed("4", withExtenstion: "mp3")
        self.notesPlayed += "D#"
        self.checkNotes()
    }
    func black2() {
        SystemSoundID.playFileNamed("7", withExtenstion: "mp3")
        self.notesPlayed += "F#"
        self.checkNotes()
    }
    func black3() {
        SystemSoundID.playFileNamed("9", withExtenstion: "mp3")
        self.notesPlayed += "G#"
        self.checkNotes()
    }
    func black4() {
        SystemSoundID.playFileNamed("11", withExtenstion: "mp3")
        self.notesPlayed += "A#"
        self.checkNotes()
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
    

}
