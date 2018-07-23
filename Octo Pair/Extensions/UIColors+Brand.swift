//
//  UIColors+Brand.swift
//  Octo Pair
//
//  Created by Chuck Ng on 21/07/2018.
//  Copyright © 2018 Chuck Ng. All rights reserved.
//

import UIKit
import Foundation
import ChameleonFramework

extension UIColor {
    
    static func mainGradient(_ view: UIView) -> UIColor? {
        let colors: [UIColor] = [UIColor.init(hexString: "292179"), UIColor.init(hexString: "C96DD8")]
        let style = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:view.frame, andColors:colors)
        return style
    }
}
