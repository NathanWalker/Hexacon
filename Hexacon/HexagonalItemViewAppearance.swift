//
//  HexagonalViewItemAppearance.swift
//  Hexacon
//
//  Created by Gautier Gdx on 05/03/16.
//  Copyright © 2016 Gautier. All rights reserved.
//

import UIKit

@objc public enum HexagonalAnimationType: Int { case Spiral, Circle, None }

@objc public class HexagonalItemViewAppearance: NSObject {
    
    //item appearance
    @objc public var needToConfigureItem: Bool
    @objc public var itemSize: CGFloat
    @objc public var itemSpacing: CGFloat
    @objc public var itemBorderWidth: CGFloat
    @objc public var itemBorderColor: UIColor
    
    //animation
    @objc public var animationType: HexagonalAnimationType
    @objc public var animationDuration: TimeInterval
    
    public init(needToConfigureItem: Bool,
                itemSize: CGFloat,
                itemSpacing: CGFloat,
                itemBorderWidth: CGFloat,
                itemBorderColor: UIColor,
                animationType: HexagonalAnimationType,
                animationDuration: TimeInterval) {
        
        self.needToConfigureItem = needToConfigureItem
        self.itemSize = itemSize
        self.itemSpacing = itemSpacing
        self.itemBorderWidth = itemBorderWidth
        self.itemBorderColor = itemBorderColor
        self.animationType = animationType
        self.animationDuration = animationDuration
    }
    
    static func defaultAppearance() -> HexagonalItemViewAppearance {
        return HexagonalItemViewAppearance(needToConfigureItem: false,
                                           itemSize: 50,
                                           itemSpacing: 10,
                                           itemBorderWidth: 5,
                                           itemBorderColor: UIColor.gray,
                                           animationType: .Circle,
                                           animationDuration: 0.2)
    }
}


