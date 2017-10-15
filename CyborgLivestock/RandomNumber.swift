//
//  RandomNumber.swift
//  CyborgLivestock
//
//  Created by Ryan Poolos on 10/15/17.
//  Copyright © 2017 PopArcade. All rights reserved.
//

import Foundation
import CoreGraphics

extension Float {
    static func random(upperBound: Float = .greatestFiniteMagnitude) -> Float {
        return Float(arc4random_uniform(UInt32(upperBound)))
    }
}

extension CGFloat {
    static func random(upperBound: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(upperBound)))
    }
}
