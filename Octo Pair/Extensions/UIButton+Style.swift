//
//  UIButton+Style.swift
//  Octo Pair
//
//  Created by Chuck Ng on 21/07/2018.
//  Copyright © 2018 Chuck Ng. All rights reserved.
//

import UIKit
import Foundation

extension UIButton {

    func roundColor(pct: CGFloat) {
        layer.cornerRadius = frame.size.height * pct
        clipsToBounds = true
    }
    
}
