//
//  mapTile.swift
//  TileScrollPOC
//
//  Created by Tom Shiflet on 12/11/17.
//  Copyright © 2017 Tom Shiflet. All rights reserved.
//

import Foundation
import SpriteKit


class mapTile
{
    var x:Int=0
    var y:Int=0
    var alt:CGFloat=0
    
    var type:Int=0  // 0 - grass, 1 - dirt, 2 - water
    var tile:Int=0
    
    
    init()
    {
        
    }
    
    init(x: Int, y:Int, alt: CGFloat, type:Int, tile:Int)
    {
        self.x=x
        self.y=y
        self.alt=alt
        self.type=type
        self.tile=tile
        
    } // init
    
} // class mapTile
