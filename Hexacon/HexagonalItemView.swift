//
//  HexagonalItemView.swift
//  Hexacon
//
//  Created by Gautier Gdx on 13/02/16.
//  Copyright © 2016 Gautier. All rights reserved.
//

import UIKit

@objc public protocol HexagonalItemViewDelegate: class {
    func hexagonalItemViewClikedOnButton(forIndex index: Int)
}

@objc public class HexagonalItemView: UIImageView {
    
    // MARK: - data
    @objc public var isActive: Bool = false
    @objc public var itemGlowColor: UIColor? = UIColor.clear
    
    public init(image: UIImage, appearance: HexagonalItemViewAppearance) {
        if appearance.needToConfigureItem {
            let modifiedImage = image.roundImage(color: appearance.itemBorderColor, borderWidth: appearance.itemBorderWidth)
            super.init(image: modifiedImage)
        } else {
            super.init(image: image)
        }
//        if appearance.itemGlowColor != nil {
//            let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:10, position: CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2), color: appearance.itemGlowColor)
//            self.layer.insertSublayer(pulseEffect, below: self.layer)
//        }
        if appearance.itemPulse {
            self.isActive = true
            if #available(iOS 9.0, *) {
                let pulse1 = CASpringAnimation(keyPath: "transform.scale")
                pulse1.duration = CFTimeInterval(Float.random(in: 0.9 ..< 3))
                pulse1.fromValue = 1.4//1.0
                pulse1.toValue = 1.6//1.09
                pulse1.autoreverses = true
                pulse1.repeatCount = 1
                pulse1.initialVelocity = 0.5
                pulse1.fillMode = CAMediaTimingFillMode.forwards
                pulse1.damping = CGFloat(pulse1.duration + 0.2)//0.8

                let animationGroup = CAAnimationGroup()
                animationGroup.duration = CFTimeInterval(Float.random(in: 2.2 ..< 3.2))//2.7
                animationGroup.repeatCount = 1000
                animationGroup.animations = [pulse1]

                self.layer.add(animationGroup, forKey: "pulse")
                
                
                self.itemGlowColor = appearance.itemGlowColor
                 
//                let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:10, position: CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2), color: appearance.itemGlowColor)
//                let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:10, position: CGPoint(x: self.center.x, y: self.center.y), color: appearance.itemGlowColor)
//                self.layer.insertSublayer(pulseEffect, below: self.layer)
                   
            } else {
                // Fallback on earlier versions
            }

        }
    }
    
    public init(view: UIView) {
        let image = view.roundImage()
        super.init(image: image)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public var index: Int?
    
    weak var delegate: HexagonalItemViewDelegate?
    
    // MARK: - event methods
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let index = index else { return }
        
        delegate?.hexagonalItemViewClikedOnButton(forIndex: index)
    }
    
}

internal extension UIView {
    
    func roundImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!.roundImage()
    }
    
}

internal extension UIImage {
    
    func roundImage(color: UIColor? = nil, borderWidth: CGFloat = 0) -> UIImage {
        guard self.size != .zero else { return self }
        
        let newImage = self.copy() as! UIImage
        let cornerRadius = self.size.height/2
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1.0)
        let bounds = CGRect(origin: CGPoint(), size: self.size)
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2), cornerRadius: cornerRadius)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        context.saveGState()
        // Clip the drawing area to the path
        path.addClip()
        
        // Draw the image into the context
        newImage.draw(in: bounds)
        context.restoreGState()
        
        // Configure the stroke
        color?.setStroke()
        path.lineWidth = borderWidth
        
        // Stroke the border
        path.stroke()
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage ?? UIImage()
    }
    
}

//@objc public class LFTPulseAnimation: CALayer {
//   
//    var radius:                 CGFloat = 200.0
//    var fromValueForRadius:     Float = 2.0
//    var fromValueForAlpha:      Float = 0.45
//    var keyTimeForHalfOpacity:  Float = 0.2
//    var animationDuration:      TimeInterval = 3.0
//    var pulseInterval:          TimeInterval = 0.0
//    var useTimingFunction:      Bool = true
//    var animationGroup:         CAAnimationGroup = CAAnimationGroup()
//    var repetitions:            Float = Float.infinity
//
//    // Need to implement that, because otherwise it can't find
//    // the constructor init(layer:AnyObject!)
//    // Doesn't seem to look in the super class
//    override init(layer: Any) {
//        super.init(layer: layer)
//    }
//    
//    init(repeatCount: Float=Float.infinity, radius: CGFloat, position: CGPoint, color: UIColor?) {
//        super.init()
//        self.contentsScale = UIScreen.main.scale
//        self.opacity = 0.0
//        self.backgroundColor = color != nil ? color?.cgColor : UIColor.blue.cgColor
//        self.radius = radius;
//        self.repetitions = repeatCount;
//        self.position = position
//
//        DispatchQueue.global(qos: .background).async {
//            self.setupAnimationGroup()
//            self.setPulseRadius(radius: self.radius)
//            
//            if (self.pulseInterval != Double.infinity) {
//                DispatchQueue.main.async {
//                    self.add(self.animationGroup, forKey: "pulse")
//                }
//            }
//        }
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func setPulseRadius(radius: CGFloat) {
//        self.radius = radius
//        let tempPos = self.position
//        let diameter = self.radius * 2
//        
//        self.bounds = CGRect(x: self.position.x, y: self.position.y, width: diameter, height: diameter)
//        self.cornerRadius = self.radius
//        self.position = tempPos
//    }
//    
//    func setupAnimationGroup() {
//        self.animationGroup = CAAnimationGroup()
//        self.animationGroup.duration = self.animationDuration + self.pulseInterval
//        self.animationGroup.repeatCount = self.repetitions
//        self.animationGroup.isRemovedOnCompletion = false
//        
//        if self.useTimingFunction {
//            let defaultCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
//            self.animationGroup.timingFunction = defaultCurve
//        }
//        
//        self.animationGroup.animations = [createScaleAnimation(), createOpacityAnimation()]
//    }
//    
//    func createScaleAnimation() -> CABasicAnimation {
//        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
//        scaleAnimation.fromValue = NSNumber(value: self.fromValueForRadius)
//        scaleAnimation.toValue = NSNumber(value: 3.8)
//        scaleAnimation.duration = self.animationDuration
//        
//        return scaleAnimation
//    }
//    
//    func createOpacityAnimation() -> CAKeyframeAnimation {
//        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
//        opacityAnimation.duration = self.animationDuration
//        opacityAnimation.values = [self.fromValueForAlpha, 0.8, 0]
//        opacityAnimation.keyTimes = [0, self.keyTimeForHalfOpacity as NSNumber, 1]
//        opacityAnimation.isRemovedOnCompletion = false
//        
//        return opacityAnimation
//    }
//    
//}
