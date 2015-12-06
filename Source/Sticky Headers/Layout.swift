//
//  ExpandCollapseLayout.swift
//  Sticky Headers
//
//  Created by Christian Noon on 10/29/15.
//  Copyright © 2015 Noondev. All rights reserved.
//

import UIKit

class Layout: UICollectionViewLayout {

    // MARK: - Helper Types

    struct SectionLimit {
        let top: CGFloat
        let bottom: CGFloat
    }

    // MARK: - Properties

    var previousAttributes: [[UICollectionViewLayoutAttributes]] = []
    var currentAttributes: [[UICollectionViewLayoutAttributes]] = []

    var previousSectionAttributes: [UICollectionViewLayoutAttributes] = []
    var currentSectionAttributes: [UICollectionViewLayoutAttributes] = []

    var currentSectionLimits: [SectionLimit] = []

    let sectionHeaderHeight: CGFloat = 40

    var contentSize = CGSizeZero
    var selectedCellIndexPath: NSIndexPath?

    // MARK: - Preparation

    override func prepareLayout() {
        super.prepareLayout()

        prepareContentCellAttributes()
        prepareSectionHeaderAttributes()
    }

    private func prepareContentCellAttributes() {
        guard let collectionView = collectionView else { return }

        //================== Reset Content Cell Attributes ================

        previousAttributes = currentAttributes

        contentSize = CGSizeZero
        currentAttributes = []
        currentSectionLimits = []

        //================== Calculate New Content Cell Attributes ==================

        let width = collectionView.bounds.size.width
        var y: CGFloat = 0

        for sectionIndex in 0..<collectionView.numberOfSections() {
            let itemCount = collectionView.numberOfItemsInSection(sectionIndex)
            let sectionTop = y

            y += sectionHeaderHeight

            var attributesList: [UICollectionViewLayoutAttributes] = []

            for itemIndex in 0..<itemCount {
                let indexPath = NSIndexPath(forItem: itemIndex, inSection: sectionIndex)
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                let size = CGSize(
                    width: width,
                    height: indexPath == selectedCellIndexPath ? 300.0 : 100.0
                )

                attributes.frame = CGRectMake(0, y, width, size.height)

                attributesList.append(attributes)

                y += size.height
            }

            let sectionBottom = y
            currentSectionLimits.append(SectionLimit(top: sectionTop, bottom: sectionBottom))

            currentAttributes.append(attributesList)
        }

        contentSize = CGSizeMake(width, y)
    }

    private func prepareSectionHeaderAttributes() {
        guard let collectionView = collectionView else { return }

        //================== Reset Section Attributes ====================

        previousSectionAttributes = currentSectionAttributes
        currentSectionAttributes = []

        //==================== Calculate New Section Attributes ===================

        let width = collectionView.bounds.size.width

        let collectionViewTop = collectionView.contentOffset.y
        let aboveCollectionViewTop = collectionViewTop - sectionHeaderHeight

        for sectionIndex in 0..<collectionView.numberOfSections() {
            let sectionLimit = currentSectionLimits[sectionIndex]

            //================= Add Section Header Attributes =================

            let indexPath = NSIndexPath(forItem: 0, inSection: sectionIndex)

            let attributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: SectionHeaderCell.kind,
                withIndexPath: indexPath
            )

            attributes.zIndex = 1
            attributes.frame = CGRectMake(0, sectionLimit.top, width, sectionHeaderHeight)

            //================== Set the y-position ==================

            let sectionTop = sectionLimit.top
            let sectionBottom = sectionLimit.bottom - sectionHeaderHeight

            attributes.frame.origin.y = min(
                max(sectionTop, collectionViewTop),
                max(sectionBottom, aboveCollectionViewTop)
            )

            currentSectionAttributes.append(attributes)
        }
    }

    // MARK: - Layout Attributes - Content Cell

    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return previousAttributes[itemIndexPath.section][itemIndexPath.item]
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return currentAttributes[indexPath.section][indexPath.item]
    }

    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItemAtIndexPath(itemIndexPath)
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []

        for sectionIndex in 0..<(collectionView?.numberOfSections() ?? 0) {
            let sectionAttributes = currentSectionAttributes[sectionIndex]

            if CGRectIntersectsRect(rect, sectionAttributes.frame) {
                attributes.append(sectionAttributes)
            }

            for item in currentAttributes[sectionIndex] where CGRectIntersectsRect(rect, item.frame) {
                attributes.append(item)
            }
        }

        return attributes
    }

    // MARK: - Layout Attributes - Section Header Cell

    override func initialLayoutAttributesForAppearingSupplementaryElementOfKind(
        elementKind: String,
        atIndexPath elementIndexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        return previousSectionAttributes[elementIndexPath.section]
    }

    override func layoutAttributesForSupplementaryViewOfKind(
        elementKind: String,
        atIndexPath indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        return currentSectionAttributes[indexPath.section]
    }

    override func finalLayoutAttributesForDisappearingSupplementaryElementOfKind(
        elementKind: String,
        atIndexPath elementIndexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        return layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: elementIndexPath)
    }

    // MARK: - Invalidation

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    override class func invalidationContextClass() -> AnyClass {
        return InvalidationContext.self
    }

    override func invalidationContextForBoundsChange(newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let invalidationContext = super.invalidationContextForBoundsChange(newBounds) as! InvalidationContext

        guard let oldBounds = collectionView?.bounds else { return invalidationContext }
        guard oldBounds != newBounds else { return invalidationContext }

        let originChanged = !CGPointEqualToPoint(oldBounds.origin, newBounds.origin)
        let sizeChanged = !CGSizeEqualToSize(oldBounds.size, newBounds.size)

        if sizeChanged {
            invalidationContext.shouldInvalidateEverything = true
        } else {
            invalidationContext.shouldInvalidateEverything = false
        }

        if originChanged {
            invalidationContext.invalidateSectionHeaders = true
        }

        return invalidationContext
    }

    override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        let invalidationContext = context as! InvalidationContext

        guard invalidationContext.invalidateEverything || invalidationContext.invalidateSectionHeaders else { return }

        guard !invalidationContext.invalidateEverything else {
            super.invalidateLayoutWithContext(invalidationContext)
            return
        }

        //============== Recompute Section Headers =================

        prepareSectionHeaderAttributes()

        var sectionHeaderIndexPaths: [NSIndexPath] = []

        for sectionIndex in 0..<currentSectionAttributes.count {
            sectionHeaderIndexPaths.append(NSIndexPath(forItem: 0, inSection: sectionIndex))
        }

        invalidationContext.invalidateSupplementaryElementsOfKind(
            SectionHeaderCell.kind,
            atIndexPaths: sectionHeaderIndexPaths
        )

        super.invalidateLayoutWithContext(invalidationContext)
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
            } else if cellTop < collectionViewTop + sectionHeaderHeight {
                finalContentOffset = CGPointMake(0.0, collectionViewTop - (collectionViewTop - cellTop) - sectionHeaderHeight)
            }
        }

        return finalContentOffset
    }
}
