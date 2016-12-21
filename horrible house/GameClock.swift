//
//  GameClock.swift
//  horrible house
//
//  Created by TerryTorres on 4/26/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class GameClock: NSObject, NSCoding {
    
    var startTime : GameTime = GameTime(hours: 11, minutes: 55, seconds: 50)
    var endTime : GameTime = GameTime(hours: 12, minutes: 0, seconds: 0)
    var currentTime : GameTime = GameTime(hours: 11, minutes: 50, seconds: 0)
    var secondsPerTurn = 30
    var reachedEndTime = false
    var didClockChime = false
    
    var timer : Timer?
    var isPaused = true
    
    var turnsPassed = 0
    
    override init() {
        super.init()
        
        self.currentTime = self.startTime
        
        
        
        
    }
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(GameClock.addSecond), userInfo: nil, repeats: true)
        self.isPaused = false
    }
    
    init(
        startTime : GameTime,
        endTime : GameTime,
        currentTime : GameTime,
        secondsPerTurn : Int,
        reachedEndTime : Bool,
        isPaused : Bool,
        didClockChime : Bool
        ) {
        super.init()
        
        self.startTime = startTime
        self.endTime = endTime
        self.currentTime = currentTime
        self.secondsPerTurn = secondsPerTurn
        self.reachedEndTime = reachedEndTime
        self.timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(GameClock.addSecond), userInfo: nil, repeats: true)
        self.isPaused = isPaused
        self.didClockChime = didClockChime
    }
    
    dynamic func addSecond() {
        if isPaused == false {
            let newTime = GameTime(
                hours: self.currentTime.hours,
                minutes: self.currentTime.minutes,
                seconds: self.currentTime.seconds + 1)
            self.currentTime = newTime
            if self.currentTime.totalTimeInSeconds() >= self.endTime.totalTimeInSeconds() {
                self.endGame()
            }
        }
    }
    
    func endGame() {
        self.reachedEndTime = true
        self.timer?.invalidate()
    }
    
    func pauseResume() {
        if timer != nil {
            if isPaused{
                isPaused = false
            } else {
                isPaused = true
            }
        }
    }
    
    init(withCurrentTime currentTime: GameTime) {
        super.init()
        
        self.currentTime = currentTime
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(GameClock.addSecond), userInfo: nil, repeats: true)
    }
    
    
    func passTime(bySeconds seconds:Int) {
        if reachedEndTime == false {
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
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.startTime, forKey: "startTime")
        coder.encode(self.endTime, forKey: "endTime")
        coder.encode(self.currentTime, forKey: "currentTime")
        
        coder.encode(self.secondsPerTurn, forKey: "secondsPerTurn")
        coder.encode(self.reachedEndTime, forKey: "isBroken")
        coder.encode(self.didClockChime, forKey:  "didClockChime")
        
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.startTime = decoder.decodeObject(forKey: "startTime") as! GameTime
        self.endTime = decoder.decodeObject(forKey: "endTime") as! GameTime
        self.currentTime = decoder.decodeObject(forKey: "currentTime") as! GameTime
        self.secondsPerTurn = decoder.decodeInteger(forKey: "secondsPerTurn")
        self.reachedEndTime = decoder.decodeBool(forKey: "isBroken")
        self.didClockChime = decoder.decodeBool(forKey: "didClockChime")


    }
    
}
