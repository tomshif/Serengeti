//
//  Springbok.swift
//  AITestBed
//
//  Created by Game Design Shared on 1/9/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import Foundation
import SpriteKit

class SpringbokClass:EntityClass
{
    private var isPregnant:Bool=false
    private var isFleeing:Bool=false
    private var isCloseToCheetah:Bool=false  // is close to what?
   
    public var MAXHERD:Int=50
    public var MINHERD:Int=15
    private var MAXCHILD:Int=2
    
    internal var followDist:CGFloat=150
    
    
    
    
    
    
    
    override init()
    {
        super.init()
        sprite=SKSpriteNode(imageNamed: "springbokAdultSprite")
    } // init
    
    
    
    override init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int)
    {
        super.init()
        
        // set the passed references
        map=theMap
        scene=theScene
        
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "springbokAdultSprite")
        sprite.position=pos
        sprite.name="springbokArrow"
        sprite.name=String(format:"entSpringbok%04d", number)
        name=String(format:"entSpringbok%04d", number)
        sprite.zPosition=140
        
        scene!.addChild(sprite)
        
        // Variable updates
        MAXSPEED=2.2
        TURNRATE=0.15
        TURNFREQ=1.0
        WANDERANGLE=CGFloat.pi/2
        AICycle=0
        MAXAGE=7*8640
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual
        age=random(min: 1.0, max: MAXAGE*0.95)
        
    } // full init()
    
    init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int, leader: EntityClass?)
    {
        super.init()
        
        if leader==nil
        {
            isHerdLeader = true
        }
        
        else
        {
            herdLeader=leader
        }
        
        // set the passed references
        map=theMap
        scene=theScene
        
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "springbokAdultSprite")
        sprite.position=pos
        sprite.name="Springbok"
        sprite.name=String(format:"entSpringbok%04d", number)
        name=String(format:"entSpringbok%04d", number)
        sprite.zPosition=140
        
        scene!.addChild(sprite)
        
        // Variable updates
        MAXSPEED=2.2
        TURNRATE=0.15
        TURNFREQ=1
        WANDERANGLE=CGFloat.pi/8
        AICycle=0
        MAXAGE=7*8640
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual
        age=random(min: 1.0, max: MAXAGE*0.95)
        
    } // full init()
    
    func catchUp()
    {
        var angle = getAngleToEntity(ent: herdLeader!)
        if angle < 0
        {
            angle += CGFloat.pi*2
        }
        turnToAngle=angle
        isTurning=true
        speed = herdLeader!.speed * 1.05
    }
    
    override func update(cycle: Int) -> Int
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
                if herdLeader != nil && !isHerdLeader
                {
                    if getDistToEntity(ent: herdLeader!) > followDist
                    {
                        catchUp()
                    }
                    else
                    {
                        wander()
                    }
                }
                else
                {
                    wander()
                }
            }
            
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

} // class SpringbokClass





