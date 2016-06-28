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
    
    var timer = NSTimer()
    var isPaused = false
    
    init() {
        self.currentTime = self.startTime
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("addSecond"), userInfo: nil, repeats: true)
    }
    
    dynamic func addSecond() {
        let newTime = GameTime(
            hours: self.currentTime.hours,
            minutes: self.currentTime.minutes,
            seconds: self.currentTime.seconds + 1)
        self.currentTime = newTime
    }
    
    func pauseResume() {
        if isPaused{
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("addSecond"), userInfo: nil, repeats: true)
            isPaused = false
        } else {
            timer.invalidate()
            isPaused = true
        }
    }
    
    init(withCurrentTime currentTime: GameTime) {
        self.currentTime = currentTime
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("addSecond"), userInfo: nil, repeats: true)
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
