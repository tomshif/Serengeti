//
//  ZebraClass.swift
//  AITestBed
//
//  Created by Game Design Shared on 1/9/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import Foundation
import SpriteKit

class ZebraClass:EntityClass
{
    
    var alert:Int=0
    var temper:Int=0
    var MAXHERD:Int=30
    var MAXCHILDRENBORN:Int=2
    
    var followDistance:CGFloat=150
    
    
    
    var isSick:Bool=false
    var isFemale:Bool=false

    var isPregnant:Bool=false
    var isTranqued:Bool=false
    

    
    override init()
   
    {
        super.init()
        sprite=SKSpriteNode(imageNamed: "zebraArrow2")
    } // init
   
    override init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int)
    {
        super.init()
        
        // set the passed references
        map=theMap
        scene=theScene
        
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "zebraArrow2")
        sprite.position=pos
        sprite.name=String(format:"entZebra%04d", number)
        name=String(format:"entZebra%04d", number)
        sprite.zPosition=100
        
        scene!.addChild(sprite)
        
        // Variable updates
        MAXSPEED=2.0
        TURNRATE=0.20
        TURNFREQ=2
        AICycle=1
        WANDERANGLE=CGFloat.pi/7
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual
        age=random(min: 1.0, max: MAXAGE*0.7)
        
    } // full init()
    
    init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int, leader:EntityClass?)
    {
        super.init()
        
        if leader==nil
        {
            isHerdLeader=true
        }// if we dont have a herd leader
        else
        {
            herdLeader=leader
        }// if we have a herd leader
        
        // set the passed references
        map=theMap
        scene=theScene
        
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "zebraArrow2")
        sprite.position=pos
        sprite.name=String(format:"entZebra%04d", number)
        name=String(format:"entZebra%04d", number)
        sprite.zPosition=100
        
        scene!.addChild(sprite)
        
        // Variable updates
        MAXSPEED=2.0
        TURNRATE=0.20
        TURNFREQ=2
        AICycle=1
        WANDERANGLE=CGFloat.pi/7
        MAXAGE=8640*10
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual
        age=random(min: 1.0, max: MAXAGE*0.7)
        
    } // full init()
    
    func catchUp()
    {
        var angle=getAngleToEntity(ent: herdLeader!)
        if angle < 0
        {
           angle+=CGFloat.pi*2
        }// if angle is below zero
        // angle=turnToAngle        // removed by Shiflet -- this is inverted
                                    // should be the other way around
        turnToAngle=angle           // added by Shiflet to fix above
        isTurning=true
        speed=herdLeader!.speed*1.05    // added by Shiflet to make sure
                                // that we can catch up
    }//func catch up
    
   override internal func update(cycle: Int) -> Int
    {
        var ret:Int = -1
        
        doTurn()
        updateGraphics()
        
        if alive
        {
            if !ageEntity()
            {
                ret=2
            } // we're able to age, if we die, set return death code
        } // if we're alive
        
        if cycle==AICycle
        {
            if currentState==WANDERSTATE
            {
                // wander() -- removed by Shiflet -- should not wander AND have
                // the opportunity to pursue the herdLeader...should be OR
                if herdLeader != nil && !isHerdLeader
                {
                    if getDistToEntity(ent: herdLeader!) > followDistance
                    {
    
                        catchUp()
                    }//if distance to entity is greater than follow distance
                    else // added by Shiflet -- the OR part
                    {
                        wander()
                    }
                }
                else
                {
                    wander()
                }// else wander
            }//if current state = wander state
            
            // fix it if our rotation is more than pi*2 or less than 0
            if sprite.zRotation > CGFloat.pi*2
            {
                sprite.zRotation -= CGFloat.pi*2
            }
            if sprite.zRotation < 0
            {
                sprite.zRotation += CGFloat.pi*2
            }
            
        } // if it's our update cycle
        
        return ret
        
    } // func update
}// zebra class
