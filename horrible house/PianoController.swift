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
        if let soundURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
            AudioServicesPlaySystemSound(sound)
        }
    }
    
}

class PianoController: UIViewController {
    
    var house : House = (UIApplication.shared.delegate as! AppDelegate).house
    
    var notesPlayed : String = ""
    
    var keyHeight : CGFloat = 0
    
    var isTabBarNeeded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        UIApplication.shared.isStatusBarHidden = true
        self.keyHeight = self.view.frame.size.height / 8
        
        // Make it so piano doesn't stick behind Tab Bar
        if self.tabBarController?.tabBar.isHidden == false {
            self.isTabBarNeeded = true
            self.tabBarController?.tabBar.isHidden = true
        }
        
        
        self.drawPianoKeys()
        //self.loadPianoNotes()
        
        
        
    }
    
    func drawPianoKeys() {
        // White keys
        for i : CGFloat in stride(from: 0, to: 7, by: 1) {
            let key = SuperButton(type: UIButtonType.custom) as SuperButton
            key.frame = CGRect(x: 0, y: (i * (self.keyHeight) + 1 + self.keyHeight), width: self.view.frame.size.width, height: (self.keyHeight) - 2)
            key.setBackgroundImage(UIImage(named: "white.png"), for: UIControlState.normal)
            key.qualifier = "white\(Int(i+1))" // we don't have any 0 notes
            key.addTarget(self, action: #selector(playNote), for:.touchDown)
            self.view.addSubview(key)
            
            
        }
        
        // Black keys
        for i : CGFloat in stride(from: 0, to: 4, by: 1) {
            let key = SuperButton(type: UIButtonType.custom) as SuperButton
            var y = ((i * (self.keyHeight)) + 1 + (self.keyHeight * 0.6) + self.keyHeight)
            if i > 1 { y += self.keyHeight }
            key.frame = CGRect(x:(self.view.frame.size.width - self.view.frame.size.width * 0.6), y: y, width: self.view.frame.size.width * 0.6, height: (self.keyHeight * 0.8))
            key.setBackgroundImage(UIImage(named: "black.png"), for: UIControlState.normal)
            key.qualifier = "black\(Int(i+1))" // we don't have any 0 notes
            key.addTarget(self, action: #selector(playNote), for:.touchDown)
            self.view.addSubview(key)
        }
    }
    
    
    // MARK: Piano Key Functions
    
    
    
    
    func playNote(sender: SuperButton) {
        let string = "\(sender.qualifier)"
        SystemSoundID.playFileNamed(fileName: string, withExtenstion: "mp3")
        self.notesPlayed += noteForSoundFileName(name: string)
        self.checkNotes()
    }
    
    func noteForSoundFileName(name: String) -> String {
        var string = ""
        
        if name.range(of: "white1") != nil { string = "C" }
        if name.range(of: "white2") != nil { string = "D" }
        if name.range(of: "white3") != nil { string = "E" }
        if name.range(of: "white4") != nil { string = "F" }
        if name.range(of: "white5") != nil { string = "G" }
        if name.range(of: "white6") != nil { string = "A" }
        if name.range(of: "white7") != nil { string = "B" }
        
        if name.range(of: "black1") != nil { string = "C#" }
        if name.range(of: "black2") != nil { string = "D#" }
        if name.range(of: "black3") != nil { string = "F#" }
        if name.range(of: "black4") != nil { string = "G#" }
        if name.range(of: "black5") != nil { string = "A#" }
        
        return string
    }
    
    
    func checkNotes() {
        if self.notesPlayed.characters.count > 12 {
            self.notesPlayed = String(self.notesPlayed.characters.dropFirst())
        }
        print("\(self.notesPlayed)")
        
        if (self.notesPlayed.range(of: "DAGDF#DF#G") != nil) {
            print("His theme!")
            self.notesPlayed = ""
        }
        
        if (self.notesPlayed.range(of: "CAGE") != nil) {
            print("Bird in a cage!")
            self.notesPlayed = ""
        }
    }
    
    
    func viewWillDisappear(animated: Bool) {
        if self.isTabBarNeeded == true {
            self.tabBarController?.tabBar.isHidden = false
        }
        
    }
    

}
