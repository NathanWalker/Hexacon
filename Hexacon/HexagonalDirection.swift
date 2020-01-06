//
//  HexagonalDirection.swift
//  Hexacon
//
//  Created by Gautier Gdx on 05/03/16.
//  Copyright © 2016 Gautier. All rights reserved.
//

import UIKit

@objc public enum HexagonalDirection: Int {
    
    case right
    case rightUp
    case leftUp
    case left
    case leftDown
    case rightDown
    
}

@objc public class HexagonalDirectionUtils: NSObject {
    /**
    this this all the direction we can found in an hexagonal layout following the axial coordinate
    it's used to move to the next center on the grid
    
    - returns: a point diving the direction of the new center
    */
    @objc public static func direction(type: HexagonalDirection) -> CGPoint {
        
        let horizontalPadding: CGFloat = 1.2
        let verticalPadding: CGFloat = 1
        
        switch type {
            case HexagonalDirection.right:
                return CGPoint(x: horizontalPadding,y: 0)
            case HexagonalDirection.rightUp:
                return CGPoint(x: horizontalPadding/2,y: -verticalPadding)
            case HexagonalDirection.leftUp:
                return CGPoint(x: -horizontalPadding/2,y: -verticalPadding)
            case HexagonalDirection.left:
                return CGPoint(x: -horizontalPadding,y: 0)
            case HexagonalDirection.leftDown:
                return CGPoint(x: -horizontalPadding/2,y: verticalPadding)
            case HexagonalDirection.rightDown:
                return CGPoint(x: horizontalPadding/2,y: verticalPadding)
        }
    }
    
    /**
     increment the enum to the next move, if it reach the end it come back a the beggining
     */
    @objc public static func move(type: HexagonalDirection) -> HexagonalDirection  {
        if type != HexagonalDirection.rightDown {
            return HexagonalDirection(rawValue: type.rawValue + 1)!
        } else {
            return HexagonalDirection.right
        }
    }
}
