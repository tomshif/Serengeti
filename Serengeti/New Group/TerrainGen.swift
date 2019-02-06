//
//  TerrainGen.swift
//  Serengeti
//
//  Created by Tom Shiflet on 1/6/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//
// Functions for generation of random map


import Foundation
import SpriteKit
import GameplayKit


func generateTerrainMap() -> Int32
{
    print("Generating Map")
    print("width: \(mapDims)")
    print("height: \(mapDims)")
    
    // Map generation variables

    var seed = Int32(random(min:0, max: 50000))
    
    let noise = GKNoise(GKBillowNoiseSource(frequency: 0.015, octaveCount: 2, persistence: 0.2, lacunarity: 0.005, seed: seed))

    //let noise = GKNoise(GKPerlinNoiseSource(frequency: 0.01, octaveCount: 1, persistence: 0.01, lacunarity: 0.1, seed: seed))
    
    var mapSize=vector_double2()
    mapSize.x=mapDims
    mapSize.y=mapDims
    var mapCenter=vector_double2()
    mapCenter.x=0
    mapCenter.y=0
    var mapSamples=vector_int2()
    mapSamples.x=sampleDims
    mapSamples.y=sampleDims
    noiseMap = GKNoiseMap(noise, size: mapSize, origin: mapCenter, sampleCount: mapSamples, seamless: false)
    let texture = SKTexture(noiseMap: noiseMap)
    mapTexture=texture
    // map.texture=texture
    //map.yScale *= -1
    
    seed = Int32(random(min:0, max: 50000))
    
    let biomeNoise = GKNoise(GKBillowNoiseSource(frequency: 0.01, octaveCount: 1, persistence: 0.1, lacunarity: 0.1, seed: seed))
    
    biomeMap=GKNoiseMap(biomeNoise, size: mapSize, origin: mapCenter, sampleCount: mapSamples, seamless: false)
    biomeTexture=SKTexture(noiseMap: biomeMap)
    
    //waterDepth=random(min: -0.425, max: -0.2)
    
    return seed
} // func generateTerrainMap

func genTileMap()
{
    
    let tMap=SKNode()
    tMap.zPosition=0
    center.addChild(tMap)
    var topLayer=SKTileMapNode()
    let tileSet = SKTileSet(named: "Sample Grid Tile Set")!
    let tileSize = CGSize(width: 128, height: 128)
    let columns = Int(mapDims)
    let rows = Int(mapDims)
    let waterTiles = tileSet.tileGroups.first { $0.name == "Water" }
    let grassTiles = tileSet.tileGroups.first { $0.name == "Grass"}
    let deadGrass = tileSet.tileGroups.first { $0.name == "Cobblestone"}
    let grass01Tiles = tileSet.tileGroups.first { $0.name == "Sand"}
    
    let bottomLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
    bottomLayer.fill(with: grass01Tiles)
    bottomLayer.zPosition=0
    tMap.name="tMap"
    tMap.addChild(bottomLayer)
    bottomLayer.name="Bottom Layer"
    // create the noise map
    noiseMap=makeNoiseMap(columns: columns, rows: rows)
    let mapT=SKTexture(noiseMap: noiseMap)
    map.yScale*=1
    map.zRotation=CGFloat.pi/2
    map.texture=mapT
    
    
    

    // create our grass/water layer
    topLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
    topLayer.zPosition=0
    
    // make SpriteKit do the work of placing specific tiles
    topLayer.enableAutomapping = true
    topLayer.name="Top Layer"
    // add the grass/water layer to our main map node
    tMap.addChild(topLayer)
    
    for column in 0 ..< columns {
        for row in 0 ..< rows {
            let location = vector2(Int32(row), Int32(column))
            let terrainHeight = noiseMap.value(at: location)
            
            if terrainHeight < -0.55 {
                topLayer.setTileGroup(deadGrass, forColumn: column, row: row)
            } else {
                topLayer.setTileGroup(grassTiles, forColumn: column, row: row)
            }

        }
    }
    // return animated tiles in a single layer
    var mapSize=vector_double2()
    mapSize.x=mapDims-1
    mapSize.y=mapDims-1
    
    var mapCenter=vector_double2()
    mapCenter.x=0
    mapCenter.y=0
    var mapSamples=vector_int2()
    mapSamples.x=sampleDims-1
    mapSamples.y=sampleDims-1
    
    let seed = Int32(random(min:0, max: 50000))
    
    // generate biome map
    let biomeNoise = GKNoise(GKBillowNoiseSource(frequency: 0.01, octaveCount: 1, persistence: 0.1, lacunarity: 0.1, seed: seed))
    
    biomeMap=GKNoiseMap(biomeNoise, size: mapSize, origin: mapCenter, sampleCount: mapSamples, seamless: false)
    biomeTexture=SKTexture(noiseMap: biomeMap)
    
} // func genTileMap

func makeNoiseMap(columns: Int, rows: Int) -> GKNoiseMap {
    
    let seed=Int32(random(min: 1, max: 50000))
    let source = GKBillowNoiseSource(frequency: 0.015, octaveCount: 2, persistence: 0.2, lacunarity: 0.005, seed: seed)
    //source.persistence = 0.8
    
    let noise = GKNoise(source)
    let sizeRange=random(min: 3.5, max: 6.0)
    let size = vector2(Double(columns), Double(rows))
    let origin = vector2(0.0, 0.0)
    let sampleCount = vector2(Int32(columns), Int32(rows))
    
    return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
} // func makeNoiseMap

func genMap()
{
    mapList.removeAll()
    for i in 0..<(sampleDims*sampleDims)
    {
        let mapx=i%Int32(mapDims)
        let mapy=Int(i/Int32(mapDims))

        //let ground=Int(random(min:0, max: 2.99999))
        var currentXY=vector_int2()
        currentXY.x=Int32(mapx)
        currentXY.y=Int32(mapy)
        
        let value=noiseMap.value(at: currentXY)
        
        let tempTile=mapTile(x: Int(mapx), y: Int(mapy), alt: CGFloat(value), type: 0, tile: 0)
        
        mapList.append(tempTile)
    } // for i
    
    print(mapList.count)
    
}

func getQuadrant(pos: CGPoint) -> Int
{
    // returns 1-4 for the quadrant that the point is in
    
    // 1|2
    // -+-
    // 3|4
    
    if pos.x < 0
    {
        if pos.y >= 0
        {
            return 1
        }
        else
        {
            return 3
        }
    } // if we're -x axis
    else
    {
        if pos.y >= 0
        {
            return 2
        }
        else
        {
            return 4
        }
    }
}

func drawMap()
{
    
    for i in 0...mapList.count-1
    {
        let mapx=mapList[i].x
        let mapy=Int(mapList[i].y)
        
        var ground=0
        //let ground=Int(random(min:0, max: 2.99999))
        var currentXY=vector_int2()
        currentXY.x=Int32(mapx)
        currentXY.y=Int32(mapy)
        
        let value=mapList[i].alt

        if value > 0
        {
            ground=2
        }
        else if value >= -0.6
        {
            ground=1
        }
        else // mud
        {
            ground=4
        }
    
        
        
        
        let tile=SKSpriteNode(imageNamed: "tile0\(ground)")
        let offset = (tile.size.width*CGFloat(mapDims/2))
        tile.position.x = CGFloat(-CGFloat(offset) + (CGFloat(mapx)*tile.size.width))
        tile.position.y = CGFloat(CGFloat(offset) - (CGFloat(mapy)*tile.size.width))
        tile.isHidden=false

        //tile.colorBlendFactor=0.5
        //tile.color=NSColor(calibratedRed: 1.00, green: 1.0, blue: 1.0, alpha: 0)
        //tile.lightingBitMask=1
        //tile.shadowedBitMask=0
        //tile.shadowCastBitMask=0
        tile.name="tile0\(ground)"
        center.addChild(tile)
        tile.zPosition=1
        
        //print("\(mapx),\(mapy) - \(tile.texture)")

        
    } // for i
    

    
    
} // func drawMap

func drawTree(theMap: MapClass, theScene: SKScene)
{
    
    
    
    // first pick a random spot
    for _ in 1...10
    {
    let point=CGPoint(x: random(min: -theMap.BOUNDARY*0.45, max: theMap.BOUNDARY*0.45), y: random(min: -theMap.BOUNDARY*0.45, max: theMap.BOUNDARY*0.45))
        //let point=CGPoint(x: random(min: -6000, max: 6000), y: random(min: -6000, max: 6000))
        print("Tree Point: \(point)")
        print("Quad: \(getQuadrant(pos: point))")
    var loc=vector_int2(Int32(point.x)/Int32(theMap.MAPWIDTH), Int32(point.y)/Int32(theMap.MAPWIDTH))

    
    let location = vector2(Int32(loc.x), Int32(loc.y))
    let terrainHeight = noiseMap.value(at: location)
    
    // check the spot on the biome map to see what kind of tree
    let alt=noiseMap.value(at: loc)
    let mapAlt=noiseMap.value(at: location)
        
    if alt > 0.5
    {
        let nodes=theScene.nodes(at: point)
        if nodes.count > 0
        {
            for thisOne in nodes
            {
                if mapAlt > 0.5
                {

                    
                    let tempTree=SKSpriteNode(imageNamed: "treeVariation1")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    let rV=random(min: 0.7, max: 1)
                    let gV=random(min: 0.7, max: 1)
                    let bV=random(min: 0.7, max: 1)
                    tempTree.colorBlendFactor=1
                    tempTree.color=NSColor(calibratedRed: rV, green: gV, blue: bV, alpha: 1.0)
                    let zPos=(tempTree.xScale/7*10)+300
                    tempTree.zPosition=zPos
                    tempTree.position=point
                    tempTree.name="tempTree"
                    let quad=getQuadrant(pos: point)
                    
                    if quad == 1
                    {
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        treeNode1.addChild(tempTree)
                        
                    }
                    else if quad == 2
                    {
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        treeNode2.addChild(tempTree)
                        print("Node 2")
                    }
                    else if quad == 3
                    {
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        treeNode3.addChild(tempTree)
                        print("Node 3")
                    }
                    else if quad == 4
                    {
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        treeNode4.addChild(tempTree)
                        print("Node 4")
                    }
                } // if we're on tile01
                else if mapAlt > 0.25
                {
                    let tempTree=SKSpriteNode(imageNamed: "treeVariation2")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    let zPos=(tempTree.xScale/7*10)+300
                    tempTree.zPosition=zPos
                    tempTree.position=point
                    let quad=getQuadrant(pos: point)
                    if quad == 1
                    {
                        treeNode1.addChild(tempTree)
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        print("Node 1")
                    }
                    else if quad == 2
                    {
                        treeNode2.addChild(tempTree)
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        print("Node 2")
                    }
                    else if quad == 3
                    {
                        treeNode3.addChild(tempTree)
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        print("Node 3")
                    }
                    else if quad == 4
                    {
                        treeNode4.addChild(tempTree)
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        print("Node 4")
                    }
                    let rV=random(min: 0.7, max: 1)
                    let gV=random(min: 0.7, max: 1)
                    let bV=random(min: 0.7, max: 1)
                    tempTree.name="tempTree"
                    tempTree.colorBlendFactor=1
                    tempTree.color=NSColor(calibratedRed: rV, green: gV, blue: bV, alpha: 1.0)
                } // if we're on tile 02
                else if mapAlt > 0.0
                {
                    let tempTree=SKSpriteNode(imageNamed: "treeVariation3")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    let zPos=(tempTree.xScale/7*10)+300
                    tempTree.zPosition=zPos
                    tempTree.position=point
                    let quad=getQuadrant(pos: point)
                    if quad == 1
                    {
                        treeNode1.addChild(tempTree)
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        print("Node 1")
                    }
                    else if quad==2
                    {
                        treeNode2.addChild(tempTree)
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        print("Node 2")
                    }
                    else if quad==3
                    {
                        treeNode3.addChild(tempTree)
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        print("Node 3")
                    }
                    else if quad==4
                    {
                        treeNode4.addChild(tempTree)
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        print("Node 4")
                    }
                    let rV=random(min: 0.7, max: 1)
                    let gV=random(min: 0.7, max: 1)
                    let bV=random(min: 0.7, max: 1)
                    tempTree.colorBlendFactor=1
                    tempTree.color=NSColor(calibratedRed: rV, green: gV, blue: bV, alpha: 1.0)
                } // if we're tile 04
            } // for each node
        } // if we have nodes
        
    } // if the alt is > 0.5
    else if alt < -0.5
    {
        // should be tree #1 so check terrain
        let nodes=theScene.nodes(at: point)
        if nodes.count > 0
        {
            for thisOne in nodes
            {
                if thisOne.name=="Bottom Layer"
                {
                    let tempTree=SKSpriteNode(imageNamed: "treeVariation5")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    let zPos=(tempTree.xScale/7*10)+300
                    tempTree.zPosition=zPos
                    tempTree.position=point
                    let quad=getQuadrant(pos: point)
                    if quad == 1
                    {
                        treeNode1.addChild(tempTree)
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        print("Node 1")
                    }
                    else if quad==2
                    {
                        treeNode2.addChild(tempTree)
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        print("Node 2")
                    }
                    else if quad==3
                    {
                        treeNode3.addChild(tempTree)
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        print("Node 3")
                    }
                    else if quad==4
                    {
                        treeNode4.addChild(tempTree)
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        print("Node 4")
                    }
                    let rV=random(min: 0.7, max: 1)
                    let gV=random(min: 0.7, max: 1)
                    let bV=random(min: 0.7, max: 1)
                    tempTree.colorBlendFactor=1
                    tempTree.color=NSColor(calibratedRed: rV, green: gV, blue: bV, alpha: 1.0)
                } // if we're on tile01
                else if thisOne.name=="Bottom Layer"
                {
                    let tempTree=SKSpriteNode(imageNamed: "treeVariation6")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    let zPos=(tempTree.xScale/7*10)+300
                    tempTree.zPosition=zPos
                    tempTree.position=point
                    let quad=getQuadrant(pos: point)
                    if quad == 1
                    {
                        treeNode1.addChild(tempTree)
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        print("Node 1")
                    }
                    else if quad==2
                    {
                        treeNode2.addChild(tempTree)
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        print("Node 2")
                    }
                    else if quad==3
                    {
                        treeNode3.addChild(tempTree)
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        print("Node 3")
                    }
                    else if quad==4
                    {
                        treeNode4.addChild(tempTree)
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        print("Node 4")
                    }
                    let rV=random(min: 0.7, max: 1)
                    let gV=random(min: 0.7, max: 1)
                    let bV=random(min: 0.7, max: 1)
                    tempTree.colorBlendFactor=1
                    tempTree.color=NSColor(calibratedRed: rV, green: gV, blue: bV, alpha: 1.0)
                } // if we're on tile 02
                else if thisOne.name=="Bottom Layer"
                {
                    let tempTree=SKSpriteNode(imageNamed: "treeVariation1")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    let zPos=(tempTree.xScale/7*10)+300
                    tempTree.zPosition=zPos
                    tempTree.position=point
                    let quad=getQuadrant(pos: point)
                    if quad == 1
                    {
                        treeNode1.addChild(tempTree)
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        print("Node 1")
                    }
                    else if quad==2
                    {
                        treeNode2.addChild(tempTree)
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y -= theMap.BOUNDARY/2
                        print("Node 2")
                    }
                    else if quad==3
                    {
                        treeNode3.addChild(tempTree)
                        tempTree.position.x += theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        print("Node 3")
                    }
                    else if quad==4
                    {
                        treeNode4.addChild(tempTree)
                        tempTree.position.x -= theMap.BOUNDARY/2
                        tempTree.position.y += theMap.BOUNDARY/2
                        print("Node 4")
                    }
                    let rV=random(min: 0.7, max: 1)
                    let gV=random(min: 0.7, max: 1)
                    let bV=random(min: 0.7, max: 1)
                    tempTree.colorBlendFactor=1
                    tempTree.color=NSColor(calibratedRed: rV, green: gV, blue: bV, alpha: 1.0)
                } // if we're tile 04
            } // for each node
        } // if we have nodes
    } // if the alt is < 0.5
    } // for each of 100 trees
    
    
} // func drawTree


func genRestZone(theMap: MapClass, theScene: SKScene)
{
    let WATERZONEDISTANCE:CGFloat=5000
    
    var foundSpot:Bool=false
    var checkPoint=CGPoint()
    while !foundSpot
    {
        // pick a spot
        checkPoint=CGPoint(x: random(min: -theMap.BOUNDARY*0.8, max: theMap.BOUNDARY*0.8),y: random(min: -theMap.BOUNDARY*0.8, max: theMap.BOUNDARY*0.8))
        
        // check to see if it's the right kind of terrain
        let theNodes = theScene.nodes(at: checkPoint)
        if theNodes.count > 0
        {
            for thisOne in theNodes
            {
                // check the terrain tile for the right terrain
                if thisOne.name != "Map"
                {
                    // Check distances to water zones
                    for ii in 0..<theMap.zoneList.count
                    {
                        if theMap.zoneList[ii].type==ZoneType.WATERZONE
                        {
                            let dx=theMap.zoneList[ii].sprite.position.x - checkPoint.x
                            let dy=theMap.zoneList[ii].sprite.position.y - checkPoint.y
                            let dist = hypot(dy, dx)
                            //print("Distance: \(dist)")
                            
                            if dist < WATERZONEDISTANCE
                            {
                                foundSpot=true
                            } // if we're in range
                        } // if it's a water zone
                    } // for each zone
                    
                } // if we're on the right terrain
                
            } // for each node
        } // if we have nodes
    } // while we haven't found a good spot
    
    let tempZone=ZoneClass(zoneType: ZoneType.RESTZONE, pos: checkPoint, theScene: theScene)
    theMap.zoneList.append(tempZone)
    
} // func genRestZone

func genFoodZone(theMap: MapClass, theScene: SKScene)
{
    let RESTZONEDISTANCE:CGFloat=8000
    
    var foundSpot:Bool=false
    var checkPoint=CGPoint()
    while !foundSpot
    {
        // pick a spot
        checkPoint=CGPoint(x: random(min: -theMap.BOUNDARY*0.8, max: theMap.BOUNDARY*0.8),y: random(min: -theMap.BOUNDARY*0.8, max: theMap.BOUNDARY*0.8))
        
        // check to see if it's the right kind of terrain
        let theNodes = theScene.nodes(at: checkPoint)
        if theNodes.count > 0
        {
            for thisOne in theNodes
            {
                // check the terrain tile for the right terrain
                if thisOne.name != "Bob"
                {
                    // Check distances to water zones
                    for ii in 0..<theMap.zoneList.count
                    {
                        if theMap.zoneList[ii].type==ZoneType.RESTZONE
                        {
                            let dx=theMap.zoneList[ii].sprite.position.x - checkPoint.x
                            let dy=theMap.zoneList[ii].sprite.position.y - checkPoint.y
                            let dist = hypot(dy, dx)
                            //print("Distance: \(dist)")
                            
                            if dist < RESTZONEDISTANCE
                            {
                                foundSpot=true
                            } // if we're in range
                        } // if it's a rest zone
                    } // for each zone
                    
                } // if we're on the right terrain
                
            } // for each node
        } // if we have nodes
    } // while we haven't found a good spot
    
    let tempZone=ZoneClass(zoneType: ZoneType.FOODZONE, pos: checkPoint, theScene: theScene)
    theMap.zoneList.append(tempZone)
    
} // func genFoodZone


func genWaterZone(theMap: MapClass, theScene: SKScene)
{
    var foundSpot:Bool=false
    var checkPoint=CGPoint()
    while !foundSpot
    {
        // pick a spot
        checkPoint=CGPoint(x: random(min: -theMap.BOUNDARY*0.8, max: theMap.BOUNDARY*0.8),y: random(min: -theMap.BOUNDARY*0.8, max: theMap.BOUNDARY*0.8))
        print("Point: \(checkPoint)")
        // check to see if it's the right kind of terrain
        let theNodes = theScene.nodes(at: checkPoint)
        if theNodes.count > 0
        {
            for thisOne in theNodes
            {
                // check to see if w're on the right tile
                if thisOne.name != "Bob"
                {
                    // assume we've found a spot
                    foundSpot=true
                    
                    // check distance to closest water zone
                    for zones in 0..<theMap.zoneList.count
                    {
                        if theMap.zoneList[zones].type==ZoneType.WATERZONE
                        {
                            let dx=theMap.zoneList[zones].sprite.position.x-checkPoint.x
                            let dy=theMap.zoneList[zones].sprite.position.y-checkPoint.y
                            let dist=hypot(dy, dx)
                            if dist < 2000
                            {
                                foundSpot=false
                            } // if we're too close
                        } // if it's a water zone
                    } // for each zone in the list
                    
                } // if we're on the right tile
                
            } // for each node
        } // if we have nodes
    } // while we haven't found a good spot
    
    let tempZone=ZoneClass(zoneType: ZoneType.WATERZONE, pos: checkPoint, theScene: theScene)
    theMap.zoneList.append(tempZone)
    
} // func genWaterZone


