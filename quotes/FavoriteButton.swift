//
//  FavoriteButton.swift
//  quotes
//
//  Created by Rachel Ng on 1/31/18.
//  Copyright © 2018 Rachel Ng. All rights reserved.
//

import UIKit

class FavoriteButton: UIButton {
    
    var isOn = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
        let image = UIImage(named: "heartblank20x20") as UIImage?
        setImage(image, for: .normal)
        addTarget(self, action: #selector(FavoriteButton.buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        activateButton(bool: !isOn)
    }
    
    func activateButton(bool: Bool) {
        isOn = bool
        let image = UIImage(named: "heartBlue20x20") as UIImage?
        setImage(image, for: .normal)
    }
    

}
