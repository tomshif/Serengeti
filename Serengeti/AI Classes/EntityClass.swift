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
    public var map:MapClass?
    
    public var speed:CGFloat=0
    public var age:CGFloat=1.0
    internal var hunger:CGFloat=1.0
    internal var thirst:CGFloat=1.0
    public var stamina:CGFloat=1.0
    

    
    internal var turnToAngle:CGFloat=0.0
    
    public var MAXAGE:CGFloat=25920.0   // In game time minutes -- One year = 8640
    public var MAXSPEED:CGFloat=0.8
    public var TURNRATE:CGFloat=0.02
    public var TURNFREQ:Double = 0.5
    public var MINSCALE:CGFloat = 0.5
    public var MAXSCALE:CGFloat = 1.0
    internal var WANDERANGLE:CGFloat=CGFloat.pi/4
    
    public var currentState:Int=0
    public var AICycle:Int=0
    internal var gotoLastState:Int = 0
    
    public var predTarget:EntityClass?
    public var isFleeing:Bool=false
    public var ACCELERATION:CGFloat=0.5
    public var TURNSPEEDLOST:CGFloat=0.1
    
    public var isDiseased:Bool=false
    
    public var isTurning:Bool=false
    public var alive:Bool=true
    internal var isHerdLeader:Bool=false
    internal var isMale:Bool=false
    internal var isEating:Bool=false
    internal var isDrinking:Bool=false
    internal var isResting:Bool=false
    
    public var herdLeader:EntityClass?
    
    var hash:String
    var name:String=""
    
    public var lastWanderTurn=NSDate()
    public var lastPredCheck=NSDate()
    public var lastFleeTurn=NSDate()
    
    internal var gotoPoint=CGPoint(x: 0, y: 0)
    
    // Constants
    let WANDERSTATE:Int=0
    let GOTOSTATE:Int=2
    let EATSTATE:Int=4
    let DRINKSTATE:Int=6
    let RESTSTATE:Int=8
    let HUNTSTATE:Int=10
    
    init()
    {
        sprite.name="Entity"
        hash=UUID().uuidString
        sprite.position=CGPoint(x: 0, y: 0)
        sprite.setScale(0.1)
        scene?.addChild(sprite)
    } // init()
    
    init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int)
    {

        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4)
        age=random(min: 1.0, max: MAXAGE*0.7)
        scene=theScene
        map=theMap
        sprite.name=String(format:"entEntity%04d", number)
        name=String(format:"entEntity%04d", number)
        hash=UUID().uuidString
        sprite.position=pos
        sprite.setScale(0.1)
        sprite.zPosition=160
        
        scene?.addChild(sprite)
    
        
        let ageRatio=age/(MAXAGE*0.4)
        var scale:CGFloat=ageRatio
        if scale < MINSCALE
        {
            scale=MINSCALE
        }
        sprite.setScale(scale)
        
        
 
        
        
        
    } // init
    
    public func catchDisease()
    {
        
    }
    
    public func updateGraphics()
    {
        let dx=cos(sprite.zRotation)*speed*map!.getTimeScale()
        let dy=sin(sprite.zRotation)*speed*map!.getTimeScale()
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
        else if ageRatio > 0.2
        {
            return "Mature"
        }
        else if ageRatio > 0.10
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
            
        case 8:
            return "Rest"
        default:
            return "Other (error)"
        } // switch
        
    } // getCurrentStateString
    
    public func ageEntity() -> Bool
    {
        age += map!.getTimeInterval()*map!.getTimeScale()
        if age > MAXAGE
        {
            map!.msg.sendMessage(type: 8, from: name)
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
    
    public func getAngleToEntity(ent: EntityClass) -> CGFloat
    {
        let dx=ent.sprite.position.x-sprite.position.x
        let dy=ent.sprite.position.y-sprite.position.y
        let angle=atan2(dy, dx)
        return angle
    }
    
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

            } // if speed drops below zero
            
            if isTurning && speed < 0.1
            {
                speed = 0.1
            }
        } // if we slow down
        
        if !isTurning
        {
            if speed < 0.1
            {
                speed = 0.1
            }
            
            //check to see if it's time to turn
            let turnDelta = -lastWanderTurn.timeIntervalSinceNow
            if turnDelta > TURNFREQ/Double(map!.getTimeScale())
            {
                //print("Starting turn")
                turnToAngle=sprite.zRotation + random(min: -WANDERANGLE, max: WANDERANGLE)
                
                // Adjust turn to angle to be 0-pi*2
                if turnToAngle >= CGFloat.pi*2
                {
                    turnToAngle -= CGFloat.pi*2
                }
                if turnToAngle < 0
                {
                    turnToAngle += CGFloat.pi*2
                }
                isTurning=true
            } // if it's time to turn
        } // if we're not turning but moving
    } // func wander
    
    public func checkTurning() -> Bool
    {
        return isTurning
    }
    
    internal func doTurn()
    {
        if isTurning
        {
            if (isFleeing || currentState==HUNTSTATE) && speed > MAXSPEED*0.5
            {
                speed-=TURNSPEEDLOST
                if speed < 0
                {
                    speed=0
                }
            }
            
            if abs(turnToAngle-sprite.zRotation) < TURNRATE*2*speed
            {
                sprite.zRotation=turnToAngle
                isTurning=false
                lastWanderTurn=NSDate()
                
                //print("Finished turn")
            } // if we can stop turning
        }
        
        if isTurning
        {
            if turnToAngle > CGFloat.pi*2
            {
                turnToAngle -= CGFloat.pi*2
            }
            if turnToAngle < 0
            {
                turnToAngle += CGFloat.pi*2
            }
            
            
            var angleDiff = turnToAngle-sprite.zRotation
            
            if angleDiff > CGFloat.pi*2
            {
                angleDiff -= CGFloat.pi*2
            }
            if angleDiff < 0
            {
                angleDiff += CGFloat.pi*2
            }

            if angleDiff < CGFloat.pi || angleDiff < -CGFloat.pi
            {
                // turning left
                sprite.zRotation += TURNRATE*speed

            } // if turn left
            else if angleDiff > -CGFloat.pi || angleDiff > CGFloat.pi
            {
                // we need to turn right
                sprite.zRotation -= TURNRATE*speed
                
            } // else if turn right

            
        }// if we're turning
        
    } // func doTurn
    
    internal func goTo()
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

    internal func update(cycle: Int) -> Int
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
                    wander()
            }
            
            if currentState==GOTOSTATE
            {
                goTo()
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
    
    
    
} // class EntityClass
