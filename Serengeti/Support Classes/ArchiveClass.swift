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
