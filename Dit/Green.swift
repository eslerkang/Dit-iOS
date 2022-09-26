//
//  Color.swift
//  Dit
//
//  Created by 강태준 on 2022/09/08.
//

import Foundation
import UIKit


protocol CustomColor {
    var color1: UIColor { get }
    var color2: UIColor { get }
    var color3: UIColor { get }
    var color4: UIColor { get }
    var color5: UIColor { get }
}


struct Green: CustomColor {
    let color1 = UIColor(red: 235/255, green: 251/255, blue: 238/255, alpha: 1)
    let color2 = UIColor(red: 178/255, green: 242/255, blue: 187/255, alpha: 1)
    let color3 = UIColor(red: 105/255, green: 219/255, blue: 124/255, alpha: 1)
    let color4 = UIColor(red: 64/255, green: 192/255, blue: 87/255, alpha: 1)
    let color5 = UIColor(red: 47/255, green: 158/255, blue: 68/255, alpha: 1)
}
