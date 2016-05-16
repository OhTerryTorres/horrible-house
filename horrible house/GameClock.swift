//
//  GameClock.swift
//  horrible house
//
//  Created by TerryTorres on 4/26/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class GameClock {
    
    var startTime : GameTime = GameTime(hours: 11, minutes: 30, seconds: 0)
    var endTime : GameTime = GameTime(hours: 12, minutes: 0, seconds: 0)
    var currentTime : GameTime
    var secondsPerTurn = 30
    var isBroken = false
    
    init() {
        self.currentTime = self.startTime
    }
    
    init(withCurrentTime currentTime: GameTime) {
        self.currentTime = currentTime
    }
    
    
    func passTime(bySeconds seconds:Int) {
        if isBroken == false {
            let newTime = GameTime(
                hours: self.currentTime.hours,
                minutes: self.currentTime.minutes,
                seconds: self.currentTime.seconds + seconds)
            self.currentTime = newTime
            self.timeSensitiveActions()
            
        }
        
    }
    
    func passTimeByTurn() {
        self.passTime(bySeconds: self.secondsPerTurn)
    }
    
    func passTimeByTurns(turns: Int) {
        self.passTime(bySeconds: self.secondsPerTurn * turns)
    }
    
    
    
    func timeSensitiveActions() {
        
    }
}
