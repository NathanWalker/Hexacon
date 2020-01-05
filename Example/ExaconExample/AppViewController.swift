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
    
    let iconArray: [UIImage] = ["call","mail","music","appstore","message","settings","photo","camera","safari","notes",
                                "addressbook","time","calculator","movie","maps","facetime","gamecenter","compass",
                                "passbook","stocks","newsstand","calendar","reminders","weather","itunes"].map { UIImage(named: $0)! }
    
    var dataArray = [UIImage]()
    
    // MARK: - subviews
    
    private lazy var hexagonalView: HexagonalView = { [unowned self] in
        let view = HexagonalView(frame: self.view.bounds)
        view.hexagonalDataSource = self
        view.hexagonalDelegate = self
        
        view.itemAppearance = HexagonalItemViewAppearance(needToConfigureItem: true,
                                                          itemSize: 50,
                                                          itemSpacing: 10,
                                                          itemBorderWidth: 0,
                                                          itemBorderColor: UIColor.gray,
                                                          animationType: .Circle,
                                                          animationDuration: 0.05)
        return view
    }()
    
    //MARK: UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 18/255, green: 52/255, blue: 86/255, alpha: 1)

        for _ in 0...3 {
            dataArray += iconArray
        }
        
        view.addSubview(hexagonalView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hexagonalView.reloadData()
    }
}

extension AppViewController: HexagonalViewDataSource {
    
    func hexagonalView(hexagonalView: HexagonalView, imageForIndex index: Int) -> UIImage? {
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

