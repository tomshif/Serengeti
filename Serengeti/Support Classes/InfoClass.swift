//
//  InfoClass.swift
//  Serengeti
//
//  Created by Tom Shiflet on 1/16/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import Foundation



class InfoClass
{
    var numCheetah:Int=0
    var numSpringbok:Int=0
    var numWarthog:Int=0
    var numZebra:Int=0
    
    var numCheetahBirths:Int=0
    var numCheetahDeaths:Int=0
    var numSpringbokBirths:Int=0
    var numSpringbokDeaths:Int=0
    var numWarthogBirths:Int=0
    var numWarthogDeaths:Int=0
    var numZebraBirths:Int=0
    var numZebraDeaths:Int=0
    
    var archive=[ArchiveClass]()
    
    var map:MapClass?
    
    init()
    {
        
    }
    
    
    init(theMap: MapClass)
    {
        map=theMap
        
    }
    
    public func archiveCounts(year: Int)
    {
        let temp=ArchiveClass(info: self, yea: year)
        archive.append(temp)
        
        
    }
    
    public func updateCounts()
    {
        numZebra=0
        numSpringbok=0
        numWarthog=0
        numCheetah=0
        
        for crit in map!.entList
        {
            if crit.name.contains("Zebra")
            {
                numZebra+=1
            }
            else if crit.name.contains("Springbok")
            {
                numSpringbok+=1
            }
            else if crit.name.contains("Warthog")
            {
                numWarthog+=1
            }
            else if crit.name.contains("Cheetah")
            {
                numCheetah += 1
            }
        } // for each critter in the list
    } // func updateCounts
    
    public func getCheetahCount() -> Int
    {
        return numCheetah
    }
    
    public func getSpringbokCount() -> Int
    {
        return numSpringbok
    }
    
    public func getWarthogCount() -> Int
    {
        return numWarthog
    }
    
    public func getZebraCount () -> Int
    {
        return numZebra
    }
    
    public func getCheetahChange() -> Int
    {
        if archive.count > 0
        {
            return numCheetah-archive.last!.getCheetahCount()
        }
        else
        {
            return 0
        }
    }
    
    public func getSpringbokChange() -> Int
    {
        if archive.count > 0
        {
            
            return numSpringbok - archive.last!.getSpringbokCount()
        }
        else
        {
            return 0
        }
        
    }
    
    public func getWarthogChange() -> Int
    {
        if archive.count > 0
        {
            
            return numWarthog - archive.last!.getWarthogCount()
        }
        else
        {
            return 0
        }
        
    }
    
    public func getZebraChange() -> Int
    {

        if archive.count > 0
        {
            return numZebra-archive.last!.getZebraCount()
        }
        else
        {
            return 0
        }

    }
    
    public func getSpringbokChangeTotal() -> Int
    {
        if archive.count > 0
        {
            return numSpringbok-archive[0].getSpringbokCount()
        }
        else
        {
            return 0
        }
    }
    
    public func getZebraChangeTotal() -> Int
    {
        if archive.count > 0
        {
            return numZebra-archive[0].getZebraCount()
        }
        else
        {
            return 0
        }
    }
    
    public func getCheetahChangeTotal() -> Int
    {
        if archive.count > 0
        {
            return numCheetah-archive[0].getCheetahCount()
        }
        else
        {
            return 0
        }
    }
    
    public func getWarthogChangeTotal() -> Int
    {
        if archive.count > 0
        {
            return numWarthog-archive[0].getWarthogCount()
        }
        else
        {
            return 0
        }
    }
    
    public func getAnimalCount() -> Int
    {
        return numZebra+numCheetah+numWarthog+numSpringbok
    } // getAnimalCount
    
    
}
