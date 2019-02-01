//
//  MapClass.swift
//  AITestBed
//
//  Created by Tom Shiflet on 12/14/18.
//  Copyright © 2018 Liberty Game Dev. All rights reserved.
//

import Foundation
import SpriteKit

class MapClass
{
    var zoneList=[ZoneClass]()
    var entList=[EntityClass]()
    var birdList=[BirdClass]()
    var buzzardList=[BuzzardClass]()
    
    
    public var mapBorder:CGFloat=0
    
    public var BOUNDARY:CGFloat=0   // width/height of map from origin
    
    public let TILESIZE:CGFloat=128 // width/height of each ground tile
    public let MAPWIDTH:CGFloat=512 // this needs to match mapDims in GameScene
    public var seed:Int32=0
    public var entityCounter:Int=0
    
    
    
    var msg=MessageClass()
    var info=InfoClass()
    
    private var timeOfDay:CGFloat = 310 // time of day in minutes past midnight -- 300 = 5:00am
    
    private let TIMEINT:CGFloat = 0.033333
    // TIMEINT equals the amount of game seconds advanced PER FRAME
    // So 0.0166 = one minute game time per second of real time (at 60fps)
    // and 0.03333 = two minutes game time per second of real time (at 60fps)
    
    // 0.2 = roughly 5 seconds/hour - 2 minutes/day - 12 minutes/year
    // Time passage will be affected by frame rate, so keeping a framerate near 60fps will be important
    
    private var timeScale:CGFloat=1.0 // for time acceleration
    private var day:Int=1 // days 1-3 of each year are wet season, days 4-6 are dry season
    private var year:Int=1 
    private let MAXTIMESCALE:CGFloat=128
    
    init()
    {
        BOUNDARY=(TILESIZE*MAPWIDTH)/2
    }
    
    public func getTimeAsString() -> String
    {
        let hour = Int(timeOfDay/60)
        let minute = Int(timeOfDay)%60
        let temp=String(format: "Year: %1d Day: %1d %02d:%02d",year, day, hour, minute)
        return temp
    } // func getTimeAsString

    
    public func isRainySeason() -> Bool
    {
        if day <= 3
        {
            return true
        }
        else
        {
            return false
        }
    } // func isRainySeason
    
    public func cleanUpEntities()
    {
        // clean up entList
        for i in 0..<entList.count
        {
            if !entList[i].isAlive()
            {
                entList.remove(at: i)
                break
            }
        } // for each entity
        
        for i in 0..<birdList.count
        {
            if !birdList[i].isAlive
            {
                birdList.remove(at: i)
                break
            }
        } // for each bird
    } // func cleanUpEntities
    
    
    public func getTimeInterval() -> CGFloat
    {
        return TIMEINT
    }
    public func getTimeScale() -> CGFloat
    {
        return timeScale
    } // func getTimeScale
    
    public func convertTimeToMinutes(hours: CGFloat, minutes: CGFloat) -> CGFloat
    {
        let retTime = (hours*60)+(minutes)
        return retTime
    } // func convertTimeToMinutes

    public func increaseTimeScale() -> Bool
    {
        var ret=false
        if (timeScale <= MAXTIMESCALE/2)
        {
            timeScale*=2
            ret = true
        }
        return ret
        
    } // func increaseTimeScale
    
    public func decreaseTimeScale() -> Bool
    {
        var ret=false
        if timeScale > 1
        {
            timeScale /= 2
            ret = true
        }
        return ret
    } // func decreaseTimeScale
    public func getTimeOfDay() -> CGFloat
    {
        return timeOfDay
    } // func getTimeOfDay()
    
    public func getDay() -> Int
    {
        return day
    } // func getDay()
    
    public func getYear() -> Int
    {
        return year
    } // func getYear()
    
    
    public func timePlus()
    {
        timeOfDay+=TIMEINT*timeScale
        if timeOfDay > 1440
        {
            timeOfDay=0
            day += 1
        } // if it's a new day
        
        if day > 6
        {
            day = 1
            info.archiveCounts(year: year)
            year += 1
        } // if it's a new year
    } // func timePlus
    
    func clearAll()
    {

        for zone in zoneList
        {
            zone.sprite.removeFromParent()
        }
        
        for ent in entList
        {
            ent.sprite.removeFromParent()
        }
        
        
        zoneList.removeAll()
        entList.removeAll()


        
    
    } // func removeAll
    
    
} // MapClass
