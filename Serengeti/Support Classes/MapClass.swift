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
    var elephantList=[ElephantClass]()
    
    private var timeOfDay:CGFloat=200
    private let TIMESCALE:CGFloat = 0.02
    
    private var day:Int=1
    private var year:Int=1
    
    
    public func getTimeAsString() -> String
    {
        let hour = Int(timeOfDay/60)
        let minute = Int(timeOfDay)%60
        let temp=String(format: "Year: %1d Day: %1d %02d:%02d",year, day, hour, minute)
        return temp
    } // func getTimeAsString
    
    public func getTimeOfDay() -> CGFloat
    {
        return timeOfDay
    } // func getTimeOfDay()
    
    
    public func timePlus()
    {
        timeOfDay+=TIMESCALE
        if timeOfDay > 1440
        {
            timeOfDay=0
            day += 1
        } // if it's a new day
        
        if day > 365
        {
            day = 1
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
        
        for ele in elephantList
        {
            ele.sprite.removeFromParent()
        }
        
        zoneList.removeAll()
        entList.removeAll()
        elephantList.removeAll()

        
    
    } // func removeAll
    
    
} // MapClass
