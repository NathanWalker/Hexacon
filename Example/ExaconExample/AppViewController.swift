//
//  AppViewController.swift
//  ExaconExample
//
//  Created by Gautier Gdx on 13/03/16.
//  Copyright © 2016 Gautier-gdx. All rights reserved.
//

import UIKit
import Hexacon

class AppViewController: UIViewController {
    
    // MARK: - data
    
    var iconArray = [ItemImage]()
    
    var dataArray = [ItemImage]()
    
    // MARK: - subviews
    
    private lazy var hexagonalView: HexagonalView = { [unowned self] in
        let view = HexagonalView(frame: self.view.bounds)
        view.hexagonalDataSource = self
        view.hexagonalDelegate = self
        
        view.itemAppearance = HexagonalItemViewAppearance(needToConfigureItem: true,
                                                          itemSize: 50,
                                                          itemSpacing: 25,
                                                          itemBorderWidth: 0,
                                                          itemBorderColor: UIColor.gray,
                                                          itemGlowColor: nil,
                                                          itemPulse: true,
                                                          itemPulseZoomFrom: 1.4,
                                                          itemPulseZoomTo: 1.6,
                                                          animationType: .Circle,
                                                          animationDuration: 0.05)
        return view
    }()
    
    //MARK: UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, element) in ["call","mail","music","appstore","message","settings","photo","camera","safari","notes",
        "addressbook","time","calculator","movie","maps","facetime","gamecenter","compass",
        "passbook","stocks","newsstand","calendar","reminders","weather","itunes"].enumerated() {
            iconArray.append(ItemImage(image: UIImage(named: element)!, appearance: HexagonalItemViewAppearance(needToConfigureItem: true, itemSize: index == 6 || index == 10 ? 60 : 50, itemSpacing: 25, itemBorderWidth: index == 6 || index == 10 ? 4 : 0, itemBorderColor: index == 6 || index == 10 ? UIColor.lightGray : UIColor.clear, itemGlowColor: index == 6 || index == 10 ? UIColor.blue : nil, itemPulse: index == 6 || index == 10, itemPulseZoomFrom: 1.4, itemPulseZoomTo: 1.6, animationType: HexagonalAnimationType.Circle, animationDuration: 0.3)))
        }
        
        view.backgroundColor = UIColor.white

        for _ in 0...3 {
            dataArray += iconArray
        }
        
        view.addSubview(hexagonalView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        hexagonalView.contentSize = CGSize(width: self.view.bounds.size.width*2, height: self.view.bounds.size.height*2)
//        hexagonalView.setContentOffset(CGPoint(x: -self.view.bounds.size.width*2, y: -self.view.bounds.size.height*2), animated: false)
        hexagonalView.reloadData()
    }
}

extension AppViewController: HexagonalViewDataSource {
    func hexagonalView(hexagonalView: HexagonalView, viewForIndex index: Int) -> UIView? {
        return UIView()
    }
    
    
    func hexagonalView(hexagonalView: HexagonalView, itemForIndex index: Int) -> ItemImage? {
        return dataArray[index]
    }
    
    func numberOfItemInHexagonalView(hexagonalView: HexagonalView) -> Int {
        return dataArray.count - 1
    }
}

extension AppViewController: HexagonalViewDelegate {
    
    func hexagonalView(hexagonalView: HexagonalView, didSelectItemAtIndex index: Int) {
        print("didSelectItemAtIndex: \(index)")
    }
    
    func hexagonalView(hexagonalView: HexagonalView, willCenterOnIndex index: Int) {
        print("willCenterOnIndex: \(index)")

    }
}

