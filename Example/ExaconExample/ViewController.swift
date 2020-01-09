//
//  ViewController.swift
//  ExaconExample
//
//  Created by Gautier Gdx on 13/03/16.
//  Copyright © 2016 Gautier-gdx. All rights reserved.
//

import UIKit
import Hexacon

final class ViewController: UIViewController {
    
    // MARK: - data
    
    let iconArray: [ItemImage] = ["Burglar","Businesswoman-1","Hacker","Ninja","Rapper-2","Rasta","Rocker","Surfer","Telemarketer-Woman-2"].map {
        return ItemImage(image: UIImage(named: $0)!, appearance: HexagonalItemViewAppearance(needToConfigureItem: false, itemSize: 50, itemSpacing: 25, itemBorderWidth: 2, itemBorderColor: UIColor.clear, itemGlowColor: nil, itemPulse: true, animationType: HexagonalAnimationType.Circle, animationDuration: 0.3))
    }
    
    var dataArray = [ItemImage]()
    
    // MARK: - subviews
    
    private lazy var hexagonalView: HexagonalView = { [unowned self] in
        let view = HexagonalView(frame: self.view.bounds)
        view.hexagonalDataSource = self
//        view.hexagonalDelegate = self
        return view
    }()
    
    //MARK: UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        for _ in 0...10 {
            dataArray += iconArray
        }
        
        view.addSubview(hexagonalView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hexagonalView.contentSize = CGSize(width: self.view.bounds.size.width*2, height: self.view.bounds.size.height*2)
        hexagonalView.reloadData()
    }
}

extension ViewController: HexagonalViewDataSource {
    func hexagonalView(hexagonalView: HexagonalView, viewForIndex index: Int) -> UIView? {
        return UIView()
    }
    
    
    func hexagonalView(hexagonalView: HexagonalView, itemForIndex index: Int) -> ItemImage? {
        return dataArray[index]
    }
    
    func numberOfItemInHexagonalView(hexagonalView: HexagonalView) -> Int {
        print(dataArray.count)
        return dataArray.count - 1
    }
}

//extension ViewController: HexagonalViewDelegate {
//
//    func hexagonalView(hexagonalView: HexagonalView, didSelectItemAtIndex index: Int) {
//        print("didSelectItemAtIndex: \(index)")
//    }
//}
