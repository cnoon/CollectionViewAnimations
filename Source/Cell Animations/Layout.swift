//
//  Layout.swift
//  Cell Animations
//
//  Created by Christian Noon on 10/29/15.
//  Copyright © 2015 Noondev. All rights reserved.
//

import UIKit

class Layout: UICollectionViewLayout {

    // MARK: - Properties

    var previousAttributes: [UICollectionViewLayoutAttributes] = []
    var currentAttributes: [UICollectionViewLayoutAttributes] = []

    var contentSize = CGSize.zero
    var selectedCellIndexPath: IndexPath?

    // MARK: - Preparation

    override func prepare() {
        super.prepare()

        previousAttributes = currentAttributes

        contentSize = CGSize.zero
        currentAttributes = []

        if let collectionView = collectionView {
            let itemCount = collectionView.numberOfItems(inSection: 0)
            let width = collectionView.bounds.size.width
            var y: CGFloat = 0

            for itemIndex in 0..<itemCount {
                let indexPath = IndexPath(item: itemIndex, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let size = CGSize(
                    width: width,
                    height: itemIndex == selectedCellIndexPath?.item ? 300.0 : 100.0
                )

                attributes.frame = CGRect(x: 0, y: y, width: width, height: size.height)

                currentAttributes.append(attributes)

                y += size.height
            }

            contentSize = CGSize(width: width, height: y)
        }
    }

    // MARK: - Layout Attributes

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return previousAttributes[itemIndexPath.item]
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return currentAttributes[indexPath.item]
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return currentAttributes.filter { rect.intersects($0.frame) }
    }

    // MARK: - Invalidation

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldBounds = collectionView?.bounds, !oldBounds.size.equalTo(newBounds.size) {
            return true
        }

        return false
    }

    // MARK: - Collection View Info

    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let selectedCellIndexPath = selectedCellIndexPath else { return proposedContentOffset }

        var finalContentOffset = proposedContentOffset

        if let frame = layoutAttributesForItem(at: selectedCellIndexPath as IndexPath)?.frame {
            let collectionViewHeight = collectionView?.bounds.size.height ?? 0

            let collectionViewTop = proposedContentOffset.y
            let collectionViewBottom = collectionViewTop + collectionViewHeight

            let cellTop = frame.origin.y
            let cellBottom = cellTop + frame.size.height

            if cellBottom > collectionViewBottom {
                finalContentOffset = CGPoint(x: 0.0, y: collectionViewTop + (cellBottom - collectionViewBottom))
            } else if cellTop < collectionViewTop {
                finalContentOffset = CGPoint(x: 0.0, y: collectionViewTop - (collectionViewTop - cellTop))
            }
        }

        return finalContentOffset
    }
}
