//
//  EntityClass.swift
//  EntityClassTest
//
//  Created by Tom Shiflet on 12/13/18.
//  Copyright © 2018 Liberty Game Dev. All rights reserved.
//

import Foundation
import SpriteKit

class EntityClass
{
    public var scene:SKScene?
    var sprite=SKSpriteNode(imageNamed: "entity")
    public var msg:MessageClass?
    
    public var speed:CGFloat=0
    public var age:CGFloat=1.0
    internal var hunger:CGFloat=1.0
    internal var thirst:CGFloat=1.0
    
    
    public var MAXAGE:CGFloat=30.0
    public var MAXSPEED:CGFloat=0.8
    public var TURNRATE:CGFloat=0.15
    public var TURNFREQ:Double = 0.09
    public var MINSCALE:CGFloat = 0.5
    public var MAXSCALE:CGFloat = 1.0
    
    
    public var currentState:Int=0
    public var AICycle:Int=0
    
    
    public var isTurning:Bool=false
    public var alive:Bool=true
    internal var isHerdLeader:Bool=false
    internal var isMale:Bool=false
    internal var isEating:Bool=false
    internal var isDrinking:Bool=false
    internal var isResting:Bool=false
    
    
    var hash:String
    var name:String=""
    
    public var lastWanderTurn=NSDate()
    
    public let AGINGVALUE:CGFloat = 0.0001
    
    // Constants
    let WANDERSTATE:Int=0
    let GOTOSTATE:Int=2
    
    init()
    {
        sprite.name="Entity"
        hash=UUID().uuidString
        sprite.position=CGPoint(x: 0, y: 0)
        sprite.setScale(0.1)
        scene?.addChild(sprite)
    }
    init(theScene:SKScene, pos: CGPoint, message: MessageClass, number: Int)
    {

        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4)
        age=random(min: 1.0, max: MAXAGE*0.7)
        msg=message
        scene=theScene
        sprite.name=String(format:"Entity%04d", number)
        name=String(format:"Entity%04d", number)
        hash=UUID().uuidString
        sprite.position=pos
        sprite.setScale(0.1)
        scene?.addChild(sprite)
        
        let ageRatio=age/(MAXAGE*0.4)
        var scale:CGFloat=ageRatio
        if scale < MINSCALE
        {
            scale=MINSCALE
        }
        sprite.setScale(scale)
        
        
 
        
        
        
    } // init
    
    public func updateGraphics()
    {
        let dx=cos(sprite.zRotation)*speed
        let dy=sin(sprite.zRotation)*speed
        sprite.position.x+=dx
        sprite.position.y+=dy
    } // func updateGraphics
    
    public func isAlive() -> Bool
    {
        return alive
    } // func isAlive
    
    public func removeSprite()
    {
        sprite.removeFromParent()
    }
    
    public func die()
    {
        alive=false
        removeSprite()
        
        // remove all reference pointers
        
        
    }
    
    public func getAgeString() -> String
    {
        let ageRatio = age/MAXAGE
        
        if ageRatio > 0.8
        {
            return "Elderly"
        }
        else if ageRatio > 0.4
        {
            return "Mature"
        }
        else if ageRatio > 0.2
        {
            return "Juvenile"
        }
        else
        {
            return "Baby"
        }
    } // func getAgeString
    
    internal func getAge() -> CGFloat
    {
        return age
    } // getAge
    
    internal func getMaxAge() -> CGFloat
    {
        return MAXAGE
    } // getMaxAge
    
    internal func getCurrentState() -> Int
    {
        return currentState
        
    } // getCurrentState
    
    internal func getCurrentStateString() -> String
    {
        switch currentState
        {
        case 0:
            return "Wander"
            
        case 2:
            return "Go to"
            
        default:
            return "Other (error)"
        } // switch
        
    } // getCurrentStateString
    
    public func ageEntity() -> Bool
    {
        age += AGINGVALUE
        if age > MAXAGE
        {
            msg!.sendMessage(type: 8, from: name)
            sprite.removeFromParent()
            alive=false
            return false
        } // if we die of old age
        else
        {
            let ageRatio=age/(MAXAGE*0.5)
            var scale:CGFloat=ageRatio
            if scale < MINSCALE
            {
                scale=MINSCALE
            }
            if scale > MAXSCALE
            {
                scale = MAXSCALE
            }
            sprite.setScale(scale)
            
            
            
            return true
        } // if we're still alive
    } // func ageEntity
    
    public func getDistToEntity(ent: EntityClass) -> CGFloat
    {
        let dx=ent.sprite.position.x-sprite.position.x
        let dy=ent.sprite.position.y-sprite.position.y
        let dist=hypot(dy, dx)
        return dist
        
        
    } // getDistToEntity
    
    public func wander()
    {
        // check for speed up
        let speedChance=random(min: 0, max: 1.0)
        if speedChance > 0.75
        {
            speed+=0.1
            if isEating || isDrinking
            {
                if speed > MAXSPEED*0.25
                {
                    speed=MAXSPEED*0.25
                }
            } // if we're eating or drinking
            else
            {
                if speed > MAXSPEED*0.5
                {
                    speed=MAXSPEED*0.5
                }
            } // if we're not eating or drinking
        } // if we speed up
        else if speedChance > 0.5
        {
            speed -= 0.1
            if speed < 0
            {
                speed=0
            }
        }
        if !isTurning
        {
            //check to see if it's time to turn
            let turnDelta = -lastWanderTurn.timeIntervalSinceNow
            if turnDelta > TURNFREQ
            {
                let turn=random(min: -TURNRATE, max: TURNRATE)
                sprite.zRotation+=turn
                lastWanderTurn=NSDate()
            }
        } // if we're not turning
    } // func wander
    
    internal func update(cycle: Int) -> Int
    {
        var ret:Int = -1
        
        updateGraphics()
        
        if alive
        {
            if !ageEntity()
            {
                ret=2
            } // we're able to age
        } // if we're alive
        if cycle==AICycle
        {
            if currentState==WANDERSTATE
            {
                    wander()
            }
            
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
    
    
    
} // class EntityClass
