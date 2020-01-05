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
    
    let iconArray: [UIImage] = ["Burglar","Businesswoman-1","Hacker","Ninja","Rapper-2","Rasta","Rocker","Surfer","Telemarketer-Woman-2"].map { UIImage(named: $0)! }
    
    var dataArray = [UIImage]()
    
    // MARK: - subviews
    
    private lazy var hexagonalView: HexagonalView = { [unowned self] in
        let view = HexagonalView(frame: self.view.bounds)
        view.hexagonalDataSource = self
        view.hexagonalDelegate = self
        return view
    }()
    
    //MARK: UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 18/255, green: 52/255, blue: 86/255, alpha: 1)
        
        for _ in 0...10 {
            dataArray += iconArray
        }
        
        view.addSubview(hexagonalView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hexagonalView.reloadData()
    }
}

extension ViewController: HexagonalViewDataSource {
    
    func hexagonalView(hexagonalView: HexagonalView, imageForIndex index: Int) -> UIImage? {
        return dataArray[index]
    }
    
    func numberOfItemInHexagonalView(hexagonalView: HexagonalView) -> Int {
        print(dataArray.count)
        return dataArray.count - 1
    }
}

extension ViewController: HexagonalViewDelegate {
    
    func hexagonalView(hexagonalView: HexagonalView, didSelectItemAtIndex index: Int) {
        print("didSelectItemAtIndex: \(index)")
    }
}
