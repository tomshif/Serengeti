//
//  TestClass.swift
//  AITestBed
//
//  Created by Tom Shiflet on 1/9/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import Foundation
import SpriteKit


class TestClass:EntityClass
{
    
    private let FOLLOWDIST:CGFloat = 125
    private var followDistVar:CGFloat=0
    
    private var targetZone:ZoneClass?
    
    private var gotoLastState:Int = 0
    
    public static let FOODZONE:Int=0
    public static let WATERZONE:Int=2
    public static let RESTZONE:Int=4
    
    override init()
    {
        super.init()
    } // init
    
    override init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int)
    {
        super.init()
        
        // set the passed references
        map=theMap
        scene=theScene
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "entity")
        sprite.position=pos
        
        sprite.name=String(format:"entTest%04d", number)
        name=String(format:"entTest%04d", number)
        sprite.zPosition=170
        sprite.lightingBitMask=1
        sprite.shadowedBitMask=0
        sprite.shadowCastBitMask=0
        scene!.addChild(sprite)
        
        // Variable updates
        MAXSPEED=1.2
        TURNRATE=0.15
        TURNFREQ=0.8
        AICycle=3
        WANDERANGLE=CGFloat.pi/6
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual
        age=random(min: 1.0, max: MAXAGE*0.7)
        currentState=WANDERSTATE
        followDistVar=random(min: 1, max: FOLLOWDIST)
        isHerdLeader=true
        
    } // leader init()
    
    
    
    init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int, ldr: EntityClass)
    {
        super.init()
        
        // set the passed references
        map=theMap
        scene=theScene
        
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "entity")
        sprite.position=pos
        
        sprite.name=String(format:"entTest%04d", number)
        name=String(format:"entTest%04d", number)
        sprite.zPosition=170
        sprite.lightingBitMask=1
        sprite.shadowedBitMask=0
        sprite.shadowCastBitMask=0
        scene!.addChild(sprite)
        
        // Variable updates
        MAXSPEED=1.2
        TURNRATE=0.15
        TURNFREQ=0.5
        AICycle=3
        WANDERANGLE=CGFloat.pi/6
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual
        age=random(min: 1.0, max: MAXAGE*0.7)
        followDistVar=random(min: 1, max: FOLLOWDIST)
        herdLeader=ldr
        isHerdLeader=false
        
    } // full init()
    

    
    private func goTo()
    {
        let dx=gotoPoint.x-sprite.position.x
        let dy=gotoPoint.y-sprite.position.y
        let dist=hypot(dy, dx)
        
        if dist > 50
        {
            var angleToPoint=atan2(dy, dx)
            if angleToPoint < 0
            {
                angleToPoint+=CGFloat.pi*2
            }
            
            turnToAngle=angleToPoint
            
            isTurning=true
            
            let speedChance=random(min: 0, max: 1.0)
            if speedChance > 0.75
            {
                speed+=0.1
                if speed > MAXSPEED*0.7
                {
                    speed=MAXSPEED*0.7
                }
            } // if we speed up
            else if speedChance > 0.5
            {
                speed -= 0.1
                if speed < MAXSPEED*0.5
                {
                    speed=MAXSPEED*0.5
                    
                } // if speed drops below zero
                

            } // if we slow down
            
        } // if we're still far enough away
        else
        {

                currentState=gotoLastState
            
        } // if we're close enough
        
    } // func goTo()
    
    private func pursue()
    {
        // get angle to leader
        let dx=herdLeader!.sprite.position.x-sprite.position.x
        let dy=herdLeader!.sprite.position.y-sprite.position.y
        var angleToLeader=atan2(dy, dx)
        if angleToLeader < 0
        {
            angleToLeader += CGFloat.pi*2
        }
        
        //print("Angle: \(angleToLeader)")
        turnToAngle=angleToLeader
        isTurning = true
        speed=MAXSPEED*0.6
        
        
        
    } // func pursue
    
    private func decideWhatToDo()
    {
        // The basic idea is to look at the time of day and then make a decision on where entity
        // should go. Once they arrive, they start doing that thing (eating, drinking, resting)
        // We keep checking the time and changing activities each hour(ish).  For some
        // activities, we have a chance to move to another zone of the same type (eating/drinking)
        // but some, we stay put (resting)
        
        if map!.getTimeOfDay() < 300 || map!.getTimeOfDay() > 1200
        {
            currentState=RESTSTATE
            

            
            if (!isResting && targetZone == nil) || (!isResting && targetZone!.type != ZoneType.RESTZONE)
            {
                // Check to see if we're close enough to a rest zone to be resting
                let tempZone=findZone(type: TestClass.RESTZONE)
                if tempZone != nil
                {
                    let dist=getDistanceToZone(zone: tempZone!)
                    targetZone=tempZone
                    gotoPoint=tempZone!.sprite.position
                    
                    if dist < 50
                    {
                        currentState=RESTSTATE
                        isResting=true
                    }
                    else
                    {
                        if isHerdLeader
                        {
                            gotoLastState=RESTSTATE
                            currentState=GOTOSTATE
                        }
                        
                    } // if we're out of range of zone, then go to it
                } // if we find a zone
                
            } // if we're not already resting
            else if getDistanceToZone(zone: targetZone!) < 50
            {
                currentState=RESTSTATE
                isResting=true
            }
            
            if !isHerdLeader && !herdLeader!.isResting
            {
                wander()

            }
            if isResting
            {
                speed=0.0
            }
            

            
        } // 00:00 - 05:00 or 20:00 - 23:59
        else
        {
            currentState=WANDERSTATE
            isResting=false
            isEating=false
            isDrinking=false
        }
        
        
    } // func decideWhatToDo
    
    private func getDistanceToZone(zone: ZoneClass) -> CGFloat
    {
        let dx=zone.sprite.position.x-sprite.position.x
        let dy=zone.sprite.position.y-sprite.position.y
        let dist:CGFloat=hypot(dy, dx)
        
        return dist
    } // func getDistanceToZone()
    
    private func findZone(type: Int) -> ZoneClass?
    {
        
        if map!.zoneList.count>0
        {
            var shortest:CGFloat=999999999
            var shortIndex:Int = -1
            
            // first, find the closest zone
            for i in 0..<map!.zoneList.count
            {
                if map!.zoneList[i].type==type
                {
                    let dx=map!.zoneList[i].sprite.position.x-sprite.position.x
                    let dy=map!.zoneList[i].sprite.position.y-sprite.position.y
                    let dist:CGFloat=hypot(dy, dx)
                    if dist < shortest
                    {
                        shortest=dist
                        shortIndex=i
                    } // if it's the shortest
                    
                } // if it's the right type
                
            } // for each zone
            
            return map!.zoneList[shortIndex]
            
            
        } // if we have zones in our list
        else
        {
            map!.msg.sendCustomMessage(message: "Error -- No zones to search")
        }
        
        
        return nil
    } // findZone
    
    override internal func update(cycle: Int) -> Int
    {
        var ret:Int = -1
        
        doTurn()
        updateGraphics()
        // fix it if our rotation is more than pi*2 or less than 0
        if sprite.zRotation > CGFloat.pi*2
        {
            sprite.zRotation -= CGFloat.pi*2
        }
        if sprite.zRotation < 0
        {
            sprite.zRotation += CGFloat.pi*2
        }
        
        
        if alive
        {
            if !ageEntity()
            {
                ret=2
            } // we're able to age, if we die, set return death code
        } // if we're alive
        
        
        if cycle==AICycle
        {
            // first decide what to do 
            decideWhatToDo()
            
            if currentState==WANDERSTATE
            {
                if herdLeader != nil && !isHerdLeader
                {
                    let ldrDist=getDistToEntity(ent: herdLeader!)

                    if ldrDist > FOLLOWDIST+followDistVar
                    {
                        //print("Distance to leader: \(ldrDist)")
                        pursue()
                        
                    } // if we're out of range
                    else
                    {
                        wander()
                    }
                } // if we're not herd leader and we have an active leader
                else
                {
                    wander()
                }
                
            } // if we're in wander state
            else if currentState==RESTSTATE
            {
                if !isResting && isHerdLeader
                {
                    goTo()
                }
                if isResting
                {
                    speed=0
                }
                if !isHerdLeader && herdLeader != nil
                {
                    let ldrDist=getDistToEntity(ent: herdLeader!)
                    if !isResting && !isHerdLeader && ldrDist>FOLLOWDIST
                    {
                        pursue()
                    }
                    if !isResting && herdLeader!.isResting
                    {
                        isResting=true
                    }
                }
                
            } // if we're in rest state

            if currentState==GOTOSTATE
            {
                goTo()
            }
            
        } // if it's our update cycle
        

        
        
        return ret
        
    } // func update
}