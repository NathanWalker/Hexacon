//
//  ZenlyHexaView.swift
//  Hexacon
//
//  Created by Gautier Gdx on 05/02/16.
//  Copyright © 2016 Gautier. All rights reserved.
//

import UIKit

@objc public protocol HexagonalViewDelegate: class {
    /**
     This method is called when the user has selected a view
     
     - parameter hexagonalView: The HexagonalView we are targeting
     - parameter index:         The current Index
     */
    @objc func hexagonalView(hexagonalView: HexagonalView, didSelectItemAtIndex index: Int)
    
    /**
     This method is called when the HexagonalView will center on an item, it gives you the new value of lastFocusedViewIndex
     
     - parameter hexagonalView: The HexagonalView we are targeting
     - parameter index:         The current Index
     */
    @objc func hexagonalView(hexagonalView: HexagonalView, willCenterOnIndex index: Int)
}

public extension HexagonalViewDelegate {
    func hexagonalView(hexagonalView: HexagonalView, didSelectItemAtIndex index: Int) { }
    func hexagonalView(hexagonalView: HexagonalView, willCenterOnIndex index: Int) { }
}

@objc public class ItemImage: NSObject {
    @objc public var image: UIImage
    @objc public var appearance: HexagonalItemViewAppearance
    
    @objc public init(image: UIImage, appearance: HexagonalItemViewAppearance) {
        self.image = image
        self.appearance = appearance
    }
}

@objc public protocol HexagonalViewDataSource: class {
    /**
     Return the number of items the view will contain
     
     - parameter hexagonalView: The HexagonalView we are targeting
     
     - returns: The number of items
     */
    @objc func numberOfItemInHexagonalView(hexagonalView: HexagonalView) -> Int
    
    /**
     Return a image to be displayed at index
     
     - parameter hexagonalView: The HexagonalView we are targeting
     - parameter index:         The current Index
     
     - returns: The image we want to display
     */
    @objc func hexagonalView(hexagonalView: HexagonalView,itemForIndex index: Int) -> ItemImage?
    
    /**
     Return a view to be displayed at index, the view will be transformed in an image before being displayed
     
     - parameter hexagonalView: The HexagonalView we are targeting
     - parameter index:         The current Index
     
     - returns: The view we want to display
     */
    @objc func hexagonalView(hexagonalView: HexagonalView,viewForIndex index: Int) -> UIView?
}

public extension HexagonalViewDataSource {
    func hexagonalView(hexagonalView: HexagonalView,itemForIndex index: Int) -> ItemImage? { return nil }
    func hexagonalView(hexagonalView: HexagonalView,viewForIndex index: Int) -> UIView? { return nil }
}

@objc public final class HexagonalView: UIScrollView {
    
    // MARK: - subviews
    
    @objc public lazy var contentView = UIView()
    
    // MARK: - data
    
    /**
     An object that supports the HexagonalViewDataSource protocol and can provide views or images to configures the HexagonalView.
     */
    @objc public weak var hexagonalDataSource: HexagonalViewDataSource?
    
    /**
     An object that supports the HexagonalViewDelegate protocol and can respond to HexagonalView events.
     */
    @objc public weak var hexagonalDelegate: HexagonalViewDelegate?
    
    /**
     The index of the view where the HexagonalView is or was centered on.
     */
    @objc public var lastFocusedViewIndex: Int = 0
    
    /**
     the appearance is used to configure the global apperance of the layout and the HexagonalItemView
     */
    @objc public var itemAppearance: HexagonalItemViewAppearance
    
    //we are using a zoom cache setted to 1 to make the snap work even if the user haven't zoomed yet
    private var zoomScaleCache: CGFloat = 1
    
    //ArrayUsed to contain all the view in the Hexagonal grid
    private var viewsArray = [HexagonalItemView]()
    
    //manager to create the hexagonal grid
    private var hexagonalPattern: HexagonalPattern!
    
    //used to snap the view after scroll
    @objc public var centerOnEndScroll = false
    
    // MARK: - init
    
    public init(frame: CGRect, itemAppearance: HexagonalItemViewAppearance) {
        self.itemAppearance = itemAppearance
        super.init(frame: frame)
        
        setUpView()
    }
    
    convenience public override init(frame: CGRect) {
        self.init(frame: frame, itemAppearance: HexagonalItemViewAppearance.defaultAppearance())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        itemAppearance = HexagonalItemViewAppearance.defaultAppearance()
        super.init(coder: aDecoder)
        
        setUpView()
    }
    
    func setUpView() {
        //configure scrollView
        delaysContentTouches = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceHorizontal = true
        alwaysBounceVertical = true
        bouncesZoom = false
        decelerationRate = UIScrollView.DecelerationRate.fast
        delegate = self
        minimumZoomScale = 0.2
        maximumZoomScale = 2
        
        //add contentView
        addSubview(contentView)
    }
    
    // MARK: - configuration methods
    
    @objc public func createHexagonalGrid(widthMultiplier: CGFloat = 0, heightMultiplier: CGFloat = 1.5, xCenter: CGFloat = 100, yCenter: CGFloat = 0) {
        //instantiate the hexagonal pattern with the number of views
        hexagonalPattern = HexagonalPattern(size: viewsArray.count, itemSpacing: itemAppearance.itemSpacing, itemSize: itemAppearance.itemSize)
        hexagonalPattern.repositionCenter = { [weak self] (center, ring, index) in
            self?.positionAndAnimateItemView(forCenter: center, ring: ring, index: index)
        }
        
        //set the contentView frame with the theorical size of th hexagonal grid
        let contentViewSize = hexagonalPattern.sizeForGridSize()
        contentView.bounds = CGRect(x: 0, y: 0, width: (widthMultiplier > 0 ? widthMultiplier : 1)*contentViewSize, height: (heightMultiplier > 0 ? heightMultiplier : 1)*contentViewSize)
        contentView.center = CGPoint(x: center.x + xCenter, y: center.y + yCenter)
        
        //start creating the grid
        hexagonalPattern.createGrid(FromCenter: CGPoint(x: contentView.frame.width/2, y: contentView.frame.height/2))
        
    }
    
    @objc public func createHexagonalViewItem(index: Int) -> HexagonalItemView {
        //instantiate the userView with the user
        
        var itemView: HexagonalItemView
        
        if let item = hexagonalDataSource?.hexagonalView(hexagonalView: self, itemForIndex: index) {
            itemView = HexagonalItemView(image: item.image, appearance: item.appearance)
        } else {
            let view = (hexagonalDataSource?.hexagonalView(hexagonalView: self, viewForIndex: index))!
            itemView = HexagonalItemView(view: view)
        }
        
        itemView.frame = CGRect(x: 0, y: 0, width: itemAppearance.itemSize, height: itemAppearance.itemSize)
        itemView.isUserInteractionEnabled = true
        //setting the delegate
        itemView.delegate = self
        
        //adding index in order to retrive the view later
        itemView.index = index
        
        if itemAppearance.animationType != .None {
            //setting the scale to 0 to perform lauching animation
            itemView.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
        
        //add to content view
//        let itemContainer = UIView(frame: CGRect(x: 0, y: 0, width:itemView.bounds.size.width*2, height: itemView.bounds.size.height*2))
//        itemContainer.addSubview(itemView)
        
        
        self.contentView.addSubview(itemView)
//        self.contentView.addSubview(itemContainer)
        
        if (itemView.isActive) {
            let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:10, position: CGPoint(x: itemView.bounds.size.width/2, y: itemView.bounds.size.height/2), color: itemView.itemGlowColor)
        //            itemView.layer.opacity = 0.2
//            itemView.layer.masksToBounds = true
//            itemView.clipsToBounds = true
                                itemView.layer.insertSublayer(pulseEffect, below: itemView.layer)
        //            itemView.layer.insertSublayer(pulseEffect, at: 0)
        //            itemContainer.layer.insertSublayer(pulseEffect, at: 0)
//            self.contentView.layer.insertSublayer(pulseEffect, above: self.contentView.layer)
                
                }
        return itemView
    }
    
    @objc public func positionAndAnimateItemView(forCenter center: CGPoint, ring: Int, index: Int) {
//        print("positionAndAnimateItemView")
        guard itemAppearance.animationType != .None else { return }
        
        //set the new view's center
        let view = viewsArray[index]
        view.center = CGPoint(x: center.x,y: center.y)
        
        let animationIndex = Double(itemAppearance.animationType == .Spiral ? index : ring)
        
        //make a pop animation
        UIView.animate(withDuration: 0.3, delay: TimeInterval(animationIndex*itemAppearance.animationDuration), usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            view.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func transformView(view: HexagonalItemView) {
//        print("transformView")
        let spacing = itemAppearance.itemSize + itemAppearance.itemSpacing/2
        
        //convert the ivew rect in the contentView coordinate
        var frame = convert(view.frame, from: view.superview)
        //substract content offset to it
        frame.origin.x -= contentOffset.x
        frame.origin.y -= contentOffset.y
        
        //retrieve the center
        let center = CGPoint(x: frame.midX, y: frame.midY)
        let distanceToBeOffset = spacing * zoomScaleCache
        let distanceToBorder = getDistanceToBorder(center: center,distanceToBeOffset: distanceToBeOffset,insets: contentInset)
        
        //if we are close to a border
        if distanceToBorder < distanceToBeOffset * 2 {
            //if ere are out of bound
            if distanceToBorder < CGFloat(-(Int(spacing*2.5))) {
                //hide the view
                view.transform = CGAffineTransform(scaleX: 0, y: 0)
            } else {
                //find the new scale
                var scale = max(distanceToBorder / (distanceToBeOffset * 2), 0)
                scale = 1-pow(1-scale, 2)
                
                //transform the view
                view.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        } else {
            if (view.isActive) {
                view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            } else {
                view.transform = CGAffineTransform.identity
            }
            
        }
    }
    
    @objc public func centerScrollViewContents() {
//        print("centerScrollViewContents")
        let boundsSize = bounds.size
        var contentsFrame = contentView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        contentView.frame = contentsFrame
    }
    
    private func getDistanceToBorder(center: CGPoint,distanceToBeOffset: CGFloat,insets: UIEdgeInsets) -> CGFloat {
        let size = bounds.size
        var    distanceToBorder: CGFloat = size.width
        
        //check if the view is close to the left
        //changing the distance to border and the offset accordingly
        let leftDistance = center.x - insets.left
        if leftDistance < distanceToBeOffset && leftDistance < distanceToBorder {
            distanceToBorder = leftDistance
        }
        
        //same for top
        let topDistance = center.y - insets.top
        if topDistance < distanceToBeOffset && topDistance < distanceToBorder {
            distanceToBorder = topDistance
        }
        
        //same for right
        let rightDistance = size.width - center.x - insets.right
        if rightDistance < distanceToBeOffset && rightDistance < distanceToBorder {
            distanceToBorder = rightDistance
        }
        
        //same for bottom
        let bottomDistance = size.height - center.y - insets.bottom
        if bottomDistance < distanceToBeOffset && bottomDistance < distanceToBorder {
            distanceToBorder = bottomDistance
        }
        
        return distanceToBorder*2
    }
    
    @objc public func centerOnIndex(index: Int, zoomScale: CGFloat) {
        
        
        guard centerOnEndScroll else { return }
//        print("centerOnIndex centerOnEndScroll", centerOnEndScroll)
        centerOnEndScroll = false
        
        //calling delegate
        hexagonalDelegate?.hexagonalView(hexagonalView: self, willCenterOnIndex: index)
        
//        print("centerOnIndex", index)
        //the view to center
        let view = viewsArray[Int(index)]
        
        //find the rect of the view in the contentView scale
        let rectInSelfSpace = HexagonalView.rectInContentView(point: view.center, zoomScale: zoomScale, size: bounds.size)
//        let rectInSelfSpace = HexagonalView.rectInContentView(point: CGPoint(x: 0, y: 0), zoomScale: zoomScale, size: bounds.size)
//        let rectInSelfSpace = HexagonalView.rectInContentView(point: view.center, zoomScale: zoomScale, size: self.contentSize)
        scrollRectToVisible(rectInSelfSpace, animated: true)
    }
    
    
    // MARK: - public methods
    
    /**
     This function load or reload all the view from the dataSource and refreshes the display
     */
    @objc public func reloadData(widthMultiplier: CGFloat = 0, heightMultiplier: CGFloat = 1.5, xCenter: CGFloat = 100, yCenter: CGFloat = 0) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        viewsArray = [HexagonalItemView]()
        
        guard let datasource = hexagonalDataSource else { return }
        
        let numberOfItems = datasource.numberOfItemInHexagonalView(hexagonalView: self)
        
        guard numberOfItems > 0 else { return }
        
        for index in 0...numberOfItems {
            viewsArray.append(createHexagonalViewItem(index: index))
        }
        
        self.contentSize = CGSize(width: self.bounds.size.width*2, height: self.bounds.size.height*2)
//        self.setContentOffset(CGPoint(x: self.bounds.size.width*2, y: 0), animated: false)
        
        self.createHexagonalGrid(widthMultiplier: widthMultiplier, heightMultiplier: heightMultiplier, xCenter: xCenter, yCenter: yCenter)
        
        
        
    }
    
    /**
     retrieve the HexagonalItemView from the HexagonalView if it's exist
     
     - parameter index: the current index of the HexagonalItemView
     
     - returns: an optionnal HexagonalItemView
     */
    @objc public func viewForIndex(index: Int) -> HexagonalItemView? {
        guard index < viewsArray.count else { return nil }
        
        return viewsArray[index]
    }
    
    
    // MARK: - class methods
    
    @objc public static func rectInContentView(point: CGPoint,zoomScale: CGFloat, size: CGSize) -> CGRect {
        let center = CGPoint(x: point.x * zoomScale, y: point.y * zoomScale)
        
        return CGRect(x: center.x-size.width*0.5, y: center.y-size.height*0.5, width: size.width, height: size.height)
    }
    
    private static func closestIndexToContentViewCenter(contentViewCenter: CGPoint,currentIndex: Int,views: [UIView]) -> Int {
        var hasItem = false
        var distance: CGFloat = 0
        var index = currentIndex
        
        views.enumerated().forEach { (viewIndex: Int, view: UIView) -> () in
            let center = view.center
            let potentialDistance = distanceBetweenPoint(point1: center, point2: contentViewCenter)
            
            if potentialDistance < distance || !hasItem {
                hasItem = true
                distance = potentialDistance
                index = viewIndex
            }
        }
        return index
    }
    
    private static func distanceBetweenPoint(point1: CGPoint, point2: CGPoint) ->  CGFloat {
        let distance = Double((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y))
        let squaredDistance = sqrt(distance)
        return CGFloat(squaredDistance)
    }
}

// MARK: - UIScrollViewDelegate

extension HexagonalView: UIScrollViewDelegate {
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        print("scrollViewDidZoom")
        zoomScaleCache = zoomScale
        
        //center the contentView each time we zoom
        centerScrollViewContents()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        //for each view snap if close to border
        for view in viewsArray {
            transformView(view: view)
        }
        //ensure that the end of scroll is fired.
        self.perform(#selector(scrollViewDidEndScrollingAnimation(_:)), with: scrollView, afterDelay: 0.3)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
        let size = self.bounds.size
        
        //the new contentView offset
        let newOffset: CGPoint = targetContentOffset.pointee
//        print("newOffset", newOffset.x, newOffset.y)
        
        //put proposedTargetCenter in coordinates relative to contentView
        var proposedTargetCenter = CGPoint(x: newOffset.x+size.width/2, y:newOffset.y+size.height/2)
        proposedTargetCenter.x /= zoomScale
        proposedTargetCenter.y /= zoomScale
        
        //find the closest userView relative to contentView center
        lastFocusedViewIndex = HexagonalView.closestIndexToContentViewCenter(contentViewCenter: proposedTargetCenter, currentIndex: lastFocusedViewIndex, views: viewsArray)
//        print("scrollViewWillEndDragging lastFocusedViewIndex", lastFocusedViewIndex)
        
        //tell that we need to center on new index
        centerOnEndScroll = true
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //if we don't need do decelerate
//        guard  !decelerate else { return }
//
//        print("scrollViewDidEndDragging lastFocusedViewIndex", lastFocusedViewIndex)
        //center the userView
        centerOnIndex(index: lastFocusedViewIndex, zoomScale: zoomScale)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print("scrollViewDidEndDecelerating")
        //center the userView
        centerOnIndex(index: lastFocusedViewIndex, zoomScale: zoomScale)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
//        print("scrollViewDidEndScrollingAnimation")
    }
}


extension HexagonalView: HexagonalItemViewDelegate {
    
    public func hexagonalItemViewClikedOnButton(forIndex index: Int) {
        hexagonalDelegate?.hexagonalView(hexagonalView: self, didSelectItemAtIndex: index)
    }
}


@objc public class LFTPulseAnimation: CALayer {
   
    var radius:                 CGFloat = 200.0
    var fromValueForRadius:     Float = 2.0
    var fromValueForAlpha:      Float = 0//0.45
    var keyTimeForHalfOpacity:  Float = 0.2
    var animationDuration:      TimeInterval = 3.0
    var pulseInterval:          TimeInterval = 0.0
    var useTimingFunction:      Bool = true
    var animationGroup:         CAAnimationGroup = CAAnimationGroup()
    var repetitions:            Float = Float.infinity

    // Need to implement that, because otherwise it can't find
    // the constructor init(layer:AnyObject!)
    // Doesn't seem to look in the super class
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    init(repeatCount: Float=Float.infinity, radius: CGFloat, position: CGPoint, color: UIColor?) {
        super.init()
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0.0
        self.backgroundColor = color != nil ? color?.cgColor : UIColor.blue.cgColor
        self.radius = radius;
        self.repetitions = repeatCount;
        self.position = position

        DispatchQueue.global(qos: .background).async {
            self.setupAnimationGroup()
            self.setPulseRadius(radius: self.radius)
            
            if (self.pulseInterval != Double.infinity) {
                DispatchQueue.main.async {
                    self.add(self.animationGroup, forKey: "pulse")
                }
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPulseRadius(radius: CGFloat) {
        self.radius = radius
        let tempPos = self.position
        let diameter = self.radius * 2
        
        self.bounds = CGRect(x: self.position.x, y: self.position.y, width: diameter, height: diameter)
        self.cornerRadius = self.radius
        self.position = tempPos
    }
    
    func setupAnimationGroup() {
        self.animationGroup = CAAnimationGroup()
        self.animationGroup.duration = self.animationDuration + self.pulseInterval
        self.animationGroup.repeatCount = self.repetitions
        self.animationGroup.isRemovedOnCompletion = false
        
        if self.useTimingFunction {
            let defaultCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            self.animationGroup.timingFunction = defaultCurve
        }
        
        self.animationGroup.animations = [createScaleAnimation(), createOpacityAnimation()]
    }
    
    func createScaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = NSNumber(value: self.fromValueForRadius)
        scaleAnimation.toValue = NSNumber(value: 3.8)
        scaleAnimation.duration = self.animationDuration
        
        return scaleAnimation
    }
    
    func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = self.animationDuration
        opacityAnimation.values = [self.fromValueForAlpha, 0.13, 0]
        opacityAnimation.keyTimes = [0, self.keyTimeForHalfOpacity as NSNumber, 1]
        opacityAnimation.isRemovedOnCompletion = false
        
        return opacityAnimation
    }
    
}
