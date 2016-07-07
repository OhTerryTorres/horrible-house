//
//  GameClock.swift
//  horrible house
//
//  Created by TerryTorres on 4/26/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class GameClock: NSObject, NSCoding {
    
    var startTime : GameTime = GameTime(hours: 11, minutes: 30, seconds: 0)
    var endTime : GameTime = GameTime(hours: 12, minutes: 0, seconds: 0)
    var currentTime : GameTime = GameTime(hours: 11, minutes: 30, seconds: 0)
    var secondsPerTurn = 30
    var isBroken = false
    
    var timer = NSTimer()
    var isPaused = false
    
    override init() {
        super.init()
        
        self.currentTime = self.startTime
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(GameClock.addSecond), userInfo: nil, repeats: true)
        
        
    }
    
    init(
        startTime : GameTime,
        endTime : GameTime,
        currentTime : GameTime,
        secondsPerTurn : Int,
        isBroken : Bool,
        isPaused : Bool
        ) {
        super.init()
        
        self.startTime = startTime
        self.endTime = endTime
        self.currentTime = currentTime
        self.secondsPerTurn = secondsPerTurn
        self.isBroken = isBroken
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(GameClock.addSecond), userInfo: nil, repeats: true)
        self.isPaused = isPaused
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
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameClock.addSecond), userInfo: nil, repeats: true)
            isPaused = false
        } else {
            timer.invalidate()
            isPaused = true
        }
    }
    
    init(withCurrentTime currentTime: GameTime) {
        super.init()
        
        self.currentTime = currentTime
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(GameClock.addSecond), userInfo: nil, repeats: true)
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
    
    
    
    // MARK: ENCODING
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.startTime, forKey: "startTime")
        coder.encodeObject(self.endTime, forKey: "endTime")
        coder.encodeObject(self.currentTime, forKey: "currentTime")
        
        coder.encodeInteger(self.secondsPerTurn, forKey: "secondsPerTurn")
        coder.encodeBool(self.isBroken, forKey: "isBroken")
        
        // coder.encodeObject(self.timer, forKey: "timer")
        coder.encodeBool(self.isPaused, forKey: "isPaused")
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let startTime = decoder.decodeObjectForKey("startTime") as? GameTime,
            let endTime = decoder.decodeObjectForKey("endTime") as? GameTime,
            let currentTime = decoder.decodeObjectForKey("currentTime") as? GameTime
            // let timer = decoder.decodeObjectForKey("timer") as? NSTimer
            else { return nil }
        
        self.init(
            startTime: startTime,
            endTime: endTime,
            currentTime: currentTime,
            secondsPerTurn: decoder.decodeIntegerForKey("secondsPerTurn"),
            isBroken: decoder.decodeBoolForKey("isBroken"),
            isPaused: decoder.decodeBoolForKey("isPaused")
        )
    }
    
}
