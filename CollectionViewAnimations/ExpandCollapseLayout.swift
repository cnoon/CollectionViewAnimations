//
//  ExpandCollapseLayout.swift
//  CollectionViewAnimations
//
//  Created by Christian Noon on 10/29/15.
//  Copyright © 2015 Noondev. All rights reserved.
//

import UIKit

class ExpandCollapseLayout: UICollectionViewLayout {

    // MARK: - Properties

    var previousAttributes: [UICollectionViewLayoutAttributes] = []
    var currentAttributes: [UICollectionViewLayoutAttributes] = []

    var contentSize = CGSizeZero
    var selectedCellIndexPath: NSIndexPath?

    // MARK: - Preparation

    override func prepareLayout() {
        super.prepareLayout()

        previousAttributes = currentAttributes

        contentSize = CGSizeZero
        currentAttributes = []

        if let
            collectionView = collectionView,
            dataSource = collectionView.dataSource
        {
            let itemCount = dataSource.collectionView(collectionView, numberOfItemsInSection: 0)
            let width = collectionView.bounds.size.width
            var y: CGFloat = 0

            for itemIndex in 0..<itemCount {
                let indexPath = NSIndexPath(forItem: itemIndex, inSection: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                let size = CGSize(
                    width: width,
                    height: itemIndex == selectedCellIndexPath?.item ? 300.0 : 100.0
                )

                attributes.frame = CGRectMake(0, y, width, size.height)
                attributes.alpha = 1.0

                currentAttributes.append(attributes)

                y += size.height
            }

            contentSize = CGSizeMake(width, y)
        }
    }

    // MARK: - Layout Attributes

    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return previousAttributes[itemIndexPath.item]
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return currentAttributes[indexPath.item]
    }

    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItemAtIndexPath(itemIndexPath)
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return currentAttributes.filter { CGRectIntersectsRect(rect, $0.frame) }
    }

    // MARK: - Invalidation

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if let oldBounds = collectionView?.bounds where !CGSizeEqualToSize(oldBounds.size, newBounds.size) {
            return true
        }

        return false
    }

    // MARK: - Collection View Info

    override func collectionViewContentSize() -> CGSize {
        return contentSize
    }

    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        guard let selectedCellIndexPath = selectedCellIndexPath else { return proposedContentOffset }

        var finalContentOffset = proposedContentOffset

        if let frame = layoutAttributesForItemAtIndexPath(selectedCellIndexPath)?.frame {
            let collectionViewHeight = collectionView?.bounds.size.height ?? 0

            let collectionViewTop = proposedContentOffset.y
            let collectionViewBottom = collectionViewTop + collectionViewHeight

            let cellTop = frame.origin.y
            let cellBottom = cellTop + frame.size.height

            if cellBottom > collectionViewBottom {
                finalContentOffset = CGPointMake(0.0, collectionViewTop + (cellBottom - collectionViewBottom))
            } else if cellTop < collectionViewTop {
                finalContentOffset = CGPointMake(0.0, collectionViewTop - (collectionViewTop - cellTop))
            }
        }

        return finalContentOffset
    }
}
