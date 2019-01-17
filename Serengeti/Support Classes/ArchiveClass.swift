//
//  ArchiveClass.swift
//  Serengeti
//
//  Created by Tom Shiflet on 1/16/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import Foundation

class ArchiveClass
{
    var cheetah:Int=0
    var springbok:Int=0
    var warthog:Int=0
    var zebra:Int=0
    var numCheetahBirths:Int=0
    var numCheetahDeaths:Int=0
    var numSpringbokBirths:Int=0
    var numSpringbokDeaths:Int=0
    var numWarthogBirths:Int=0
    var numWarthogDeaths:Int=0
    var numZebraBirths:Int=0
    var numZebraDeaths:Int=0
    
    var year:Int=0
    
    
    init()
    {
        
    }
    
    init(che: Int, spr: Int, war: Int, zeb: Int, yea: Int)
    {
        cheetah=che
        springbok=spr
        warthog=war
        zebra=zeb
        year=yea
    } // init
    
    init(info: InfoClass, year: Int)
    {
        cheetah=info.numCheetah
        numCheetahBirths=info.numCheetahBirths
        numCheetahDeaths=info.numCheetahDeaths
        
    }
    public func getZebraCount() -> Int
    {
        return zebra
    }
    
    public func getSpringbokCount() -> Int
    {
        return springbok
    }
    
    public func getWarthogCount() -> Int
    {
        return warthog
    }
    
    public func getCheetahCount() -> Int
    {
        return cheetah
    }
    
    
    
    
} // ArchiveClass
