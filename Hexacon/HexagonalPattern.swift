//
//  HegagonalDirection.swift
//  Hexacon
//
//  Created by Gautier Gdx on 06/02/16.
//  Copyright © 2016 Gautier. All rights reserved.
//

import UIKit

@objc public class HexagonalPattern: NSObject {
    
    // MARK: - typeAlias
    
    typealias HexagonalPosition = (center: CGPoint,ring: Int)
    
    // MARK: - data

    internal var repositionCenter: ((CGPoint, Int, Int) -> ())?
    
    fileprivate var position: HexagonalPosition! {
        didSet {
            //while our position is bellow the size we can continue
            guard positionIndex < size else {
                reachedLastPosition = true
                return
            }
            //each time a new center is set we are sending it back to the scrollView
            repositionCenter?(position.center, position.ring, positionIndex)
            positionIndex += 1
        }
    }
    
    fileprivate var directionFromCenter: HexagonalDirection
    
    fileprivate var reachedLastPosition = false
    fileprivate var positionIndex = 0
    
    fileprivate let sideNumber: Int = 6
    
    //properties
    fileprivate let size: Int
    fileprivate let itemSpacing: CGFloat
    fileprivate let maxRadius: Int
    
    // MARK: - init
    
    init(size: Int, itemSpacing: CGFloat, itemSize: CGFloat) {
        self.size = size
        self.itemSpacing = itemSpacing + itemSize - 8
        maxRadius = size/6 + 1
        
        directionFromCenter = .right
    }
    
    // MARK: - instance methods
    
    /**
    calculate the theorical size of the grid
    
    - returns: the size of the grid
    */
    func sizeForGridSize() -> CGFloat {
        return 2*itemSpacing*CGFloat(maxRadius)
    }
    
    /**
     create the grid with a circular pattern beginning from the center
     in each loop we are sending back a center for a new View     
     */
    func createGrid(FromCenter newCenter: CGPoint) {
        //initializing the algorythm
        start(newCenter)
    
        //for each radius
        for radius in 0...maxRadius {
            guard reachedLastPosition == false else { continue }
            
            //we are creating a ring
            createRing(withRadius: radius)
            
            //then jumping to the next one
            jumpToNextRing()
        }
    }
    
    // MARK: - configuration methods
    
    fileprivate func neighbor(origin: CGPoint,direction: HexagonalDirection) -> CGPoint {
        //take the current direction
        let direction = direction.direction()
        
        //then multiply it to find the new center
        return CGPoint(x: origin.x + itemSpacing*direction.x,y: origin.y + itemSpacing*direction.y)
    }
    
    fileprivate func start(_ newCenter: CGPoint) {
        //initializing with the center given
        position = (center: newCenter,ring: 0)
        
        //then jump on the first ring
        position = (center: neighbor(origin: position.center,direction: .leftDown),ring: 1)
    }
    
    
    fileprivate func createRing(withRadius radius: Int) {
        //for each side of the ring
        for _ in 0...(sideNumber - 1) {
            
            //in each posion in the side
            for directionIndex in 0...radius {
                //stop if we are at the end of the ring
                guard !(directionIndex == radius && directionFromCenter == .rightDown) else { continue }
                
                //or add a new point
                position = (center: neighbor(origin: position.center,direction: directionFromCenter),ring: radius + 1)
            }
            //then move to another position
            directionFromCenter.move()
        }
    }
    
    fileprivate func jumpToNextRing() {
        //the next ring is always two position bellow the previous one
        position = (center: CGPoint(x: position.center.x ,y: position.center.y + 2*itemSpacing),ring: position.ring + 1)
    }
}
