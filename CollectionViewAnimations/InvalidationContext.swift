//
//  InvalidationContext.swift
//  CollectionViewAnimations
//
//  Created by Christian Noon on 11/3/15.
//  Copyright © 2015 Noondev. All rights reserved.
//

import UIKit

class InvalidationContext: UICollectionViewLayoutInvalidationContext {

    // MARK: - Properties

    var invalidateSectionHeaders = false
    var shouldInvalidateEverything = true

    override var invalidateEverything: Bool {
        print("Calling invalidate everything")
        return shouldInvalidateEverything
    }

    override var contentOffsetAdjustment: CGPoint {
        didSet {
            print("DidSet - contentOffsetAdjustment: \(contentOffsetAdjustment)")
        }
    }

    override var contentSizeAdjustment: CGSize {
        didSet {
            print("DidSet - contentSizeAdjustment: \(contentSizeAdjustment)")
        }
    }

    // MARK: - Initialization

    override init() {
        super.init()
        print("Initialized InvalidationContext: \(self.hashValue)")
    }

    // MARK: - Invalidation

    override func invalidateItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        super.invalidateItemsAtIndexPaths(indexPaths)
        print("invalidateItemsAtIndexPaths: \(indexPaths)")
    }

    override func invalidateSupplementaryElementsOfKind(elementKind: String, atIndexPaths indexPaths: [NSIndexPath]) {
        super.invalidateSupplementaryElementsOfKind(elementKind, atIndexPaths: indexPaths)
        print("invalidateSupplementaryElementsOfKind: \(elementKind) atIndexPaths: \(indexPaths)")
    }
}
