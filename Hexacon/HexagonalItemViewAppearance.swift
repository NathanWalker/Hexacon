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
    @objc public var itemGlowColor: UIColor?
    @objc public var itemPulse: Bool
    @objc public var itemPulseZoomFrom: CGFloat
    @objc public var itemPulseZoomTo: CGFloat
    
    //animation
    @objc public var animationType: HexagonalAnimationType
    @objc public var animationDuration: TimeInterval
    
    @objc public init(needToConfigureItem: Bool,
                itemSize: CGFloat,
                itemSpacing: CGFloat,
                itemBorderWidth: CGFloat,
                itemBorderColor: UIColor,
                itemGlowColor: UIColor?,
                itemPulse: Bool,
                itemPulseZoomFrom: CGFloat,
                itemPulseZoomTo: CGFloat,
                animationType: HexagonalAnimationType,
                animationDuration: TimeInterval) {
        
        self.needToConfigureItem = needToConfigureItem
        self.itemSize = itemSize
        self.itemSpacing = itemSpacing
        self.itemBorderWidth = itemBorderWidth
        self.itemBorderColor = itemBorderColor
        self.itemGlowColor = itemGlowColor
        self.itemPulse = itemPulse
        self.itemPulseZoomFrom = itemPulseZoomFrom
        self.itemPulseZoomTo = itemPulseZoomTo
        self.animationType = animationType
        self.animationDuration = animationDuration
    }
    
    @objc public static func defaultAppearance() -> HexagonalItemViewAppearance {
        return HexagonalItemViewAppearance(needToConfigureItem: false,
                                           itemSize: 50,
                                           itemSpacing: 10,
                                           itemBorderWidth: 5,
                                           itemBorderColor: UIColor.gray,
                                           itemGlowColor: nil,
                                           itemPulse: false,
                                           itemPulseZoomFrom: 1.4,
                                           itemPulseZoomTo: 1.6,
                                           animationType: .Circle,
                                           animationDuration: 0.2)
    }
}


