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
    internal var sprite=SKSpriteNode(imageNamed: "foodzone")
    
    private let waterTexture=SKTexture(imageNamed: "waterzone")
    private let restTexture=SKTexture(imageNamed: "restzone")
    
    
    internal var type:Int=0
    

    
    init()
    {
        
    }
    
    init(zoneType: Int, pos:CGPoint, theScene:SKScene)
    {
        scene=theScene
        sprite.position=pos
        sprite.zPosition = -2
        sprite.name="FoodZone"
        scene?.addChild(sprite)
        
        
        type=zoneType
        
        switch zoneType
        {
        case ZoneType.WATERZONE:
            sprite.texture=waterTexture
            sprite.name="WaterZone"
        case ZoneType.RESTZONE:
            sprite.texture=restTexture
            sprite.name="RestZone"
        default:
            break
            
        } // switch zone type
        
    }
    
} // zoneClass
