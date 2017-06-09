//
//  Number.swift
//  CollectionViewAnimations
//
//  Created by Christian Noon on 11/2/15.
//  Copyright © 2015 Noondev. All rights reserved.
//

import Foundation

struct Number {
    static func random(from: Int, to: Int) -> Int {
        guard from < to else { fatalError("`from` MUST be less than `to`") }
        let delta = UInt32(to + 1 - from)

        return from + Int(arc4random_uniform(delta))
    }
}
