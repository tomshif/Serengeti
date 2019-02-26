//
//  ZoneClass.swift
//  AITestBed
//
//  Created by Tom Shiflet on 12/14/18.
//  Copyright © 2018 Liberty Game Dev. All rights reserved.
//

import Foundation
import SpriteKit

struct ZoneType
{
    public static let FOODZONE:Int=0
    public static let WATERZONE:Int=2
    public static let RESTZONE:Int=4
}

class ZoneClass
{
    
    private var scene:SKScene?
    internal var sprite=SKSpriteNode(imageNamed: "zoneFood01")
    
    private let waterTexture=SKTexture(imageNamed: "waterzone1")
    private let restTexture=SKTexture(imageNamed: "restZone1")
    private let foodTexture=SKTexture(imageNamed: "zoneFood01")
    
    internal var type:Int=0
    

    
    init()
    {
        
    }
    
    init(zoneType: Int, pos:CGPoint, theScene:SKScene)
    {
        scene=theScene
        sprite.position=pos
        sprite.zPosition = 10
        sprite.name="FoodZone"
        sprite.lightingBitMask=1
        sprite.shadowedBitMask=0
        sprite.shadowCastBitMask=0
        scene?.addChild(sprite)
        
        
        type=zoneType
        
        switch zoneType
        {
        case ZoneType.WATERZONE:
            sprite.texture=waterTexture
            sprite.name="WaterZone"
            sprite.setScale(random(min: 1.5, max: 6.5))
            sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
            
        case ZoneType.RESTZONE:
            sprite.texture=restTexture
            sprite.name="RestZone"
            sprite.setScale(random(min: 1.5, max: 4.5))
            sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
            
        case ZoneType.FOODZONE:
            sprite.texture=foodTexture
            sprite.name="FoodZone"
            sprite.setScale(random(min: 1.5, max: 2.5))
            sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
            
        default:
            break
            
        } // switch zone type
        
    }
    
} // zoneClass
