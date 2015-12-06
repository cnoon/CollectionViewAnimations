//
//  InvalidationContext.swift
//  Sticky Headers
//
//  Created by Christian Noon on 11/3/15.
//  Copyright © 2015 Noondev. All rights reserved.
//

import UIKit

class InvalidationContext: UICollectionViewLayoutInvalidationContext {
    var invalidateSectionHeaders = false
    var shouldInvalidateEverything = true

    override var invalidateEverything: Bool {
        return shouldInvalidateEverything
    }
}
