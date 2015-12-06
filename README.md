# Collection View Animations

Sample project demonstrating how to expand / collapse collection view cells using `UIView` animation closures in addition to sticky headers.

## Features

- [X] Collection View with Custom Layout
- [X] Custom Layout Attributes supporting UIView Cell Content Size Animations
- [X] Content Offset Scroll Behavior while Animating
- [X] Sticky Section Headers in Collection View
- [X] Efficient Sticky Header Performance using Invalidation Context

## Description

Collection views are very powerful, but can be cumbersome as well. When initially trying to figure out how to expand / collapse a cell in a `UICollectionView`, I was very surprised to find so little documentation around using a typical `UIView.animationWithDuration` closure to control the animation. The majority of documentation I found was using either the [setCollectionViewLayout(_:animated:)](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UICollectionView_class/#//apple_ref/occ/instm/UICollectionView/setCollectionViewLayout:animated:) API or the [performBatchUpdates(_:completion:)](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UICollectionView_class/#//apple_ref/occ/instm/UICollectionView/performBatchUpdates:completion:) API. However, neither of these approaches give you full control of the actual animation. I simply wanted to be able to use my own animation closures to control the behavior of the cells using a custom `UICollectionViewLayout`.

After much investigation, I was able to find a solution leveraging all the `UICollectionViewLayout` APIs. You can animate the cells using a typical `UIView.animationWithDuration` closure to control all aspects of the animation in combination with the custom layout. You can even control the `contentOffset` of the `UICollectionView` while animating. Once I could control the animation, I needed to add sticky headers into the collection view as well. That proved to be MUCH more difficult and required a custom [UICollectionViewLayoutInvalidationContext](https://developer.apple.com/library/tvos/documentation/UIKit/Reference/UICollectionViewLayoutInvalidationContext_class/index.html).

This sample project was created to demonstrate how to set up a fully custom [UICollectionViewLayout](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UICollectionViewLayout_class/) to perform custom cell animations as well as demonstrate how to efficiently implement sticky section headers. Hopefully this will help someone else when facing the same challenges.

---

## Apps

The sample project contains two different applications, each demonstrating different functionality alongside a custom layout.

### Cell Animations

The `Cell Animations` app target demonstrates how to implement a custom `UICollectionViewLayout` in a way that can support custom cell expand and collapse animations. Each time a cell is tapped, it is expanded and brought fully on-screen if it is collapsed, and is collapsed if it is expanded.

```swift
func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    layout.selectedCellIndexPath = layout.selectedCellIndexPath == indexPath ? nil : indexPath

    UIView.animateWithDuration(
        0.4,
        delay: 0.0,
        usingSpringWithDamping: 1.0,
        initialSpringVelocity: 0.0,
        options: UIViewAnimationOptions(),
        animations: {
            self.layout.invalidateLayout()
            self.collectionView.layoutIfNeeded()
        },
        completion: nil
    )
}
```

> Try modifying the values to customize the feel of the animation. This gives you the ultimate flexibility to control all aspects of the animation in any way you wish.

#### Preparing the Layout

The first step to implementing a custom `UICollectionViewLayout` is to compute the attributes for all cells that need to be displayed in the collection view. 

```swift
override func prepareLayout() {
    super.prepareLayout()

    previousAttributes = currentAttributes

    contentSize = CGSizeZero
    currentAttributes = []

    if let collectionView = collectionView {
        let itemCount = collectionView.numberOfItemsInSection(0)
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

            currentAttributes.append(attributes)

            y += size.height
        }

        contentSize = CGSizeMake(width, y)
    }
}
```

As you can see in the [prepareLayout](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UICollectionViewLayout_class/#//apple_ref/occ/instm/UICollectionViewLayout/prepareLayout) implementation, new cell attributes are created for each cell. Each cell is placed directly below the previous cell, and the selected cell is 3 times larger than non-selected cells. The total height of all the cells is used to populate the `contentSize`.

> The trick here is that the `previousAttributes` are being stored. You'll see why that's important here in a bit.

#### Invalidating the Layout

For this particular collection view, we only want to invalidate the layout if the new bounds rect has a different size. We can ignore all origin changes in the bounds because this collection view doesn't need to react to them. This is very important from a performance standpoint.

```swift
override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    if let oldBounds = collectionView?.bounds where !CGSizeEqualToSize(oldBounds.size, newBounds.size) {
        return true
    }

    return false
}
```

> You should never invalidate the layout unless you absolutely have to. Invalidating the layout will cause your entire layout to be recalculated which can have serious performance implications.

#### Layout Attributes

The next step to implementing the custom layout is to override both of the following methods:

```swift
override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return currentAttributes.filter { CGRectIntersectsRect(rect, $0.frame) }
}

override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    return currentAttributes[indexPath.item]
}
```

The first method is used by the collection view to query the layout for all attributes within a given rect. This is generally used to query for all the visible cell layout attributes. Therefore, this implementation simply filters the current attributes that intersect the specified rect. Since the attributes were already computed in the `prepareLayout` method, this implementation is very straightforward.

The second method is used by the collection view to get the attributes for a given index path. Again, since this information was computed in the `prepareLayout` method, we only need to return the layout attributes for the specified index path.

##### Initial Layout Attributes

Overriding the initial layout attributes API is where things start to get interesting.

```swift
override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
    return previousAttributes[itemIndexPath.item]
}
```

This is why the `previousAttributes` are stored in the `prepareLayout` method. When the collection view runs an animation, it needs to know the initial attributes and the layout attributes for the end of the animation. By default, Apple provides initial attributes that result in a fade-in animation. If you want to have fine-grained control over the animation, you need to provide the initial layout attributes for each cell to tell the collection view exactly how the animation should occur.

> To see this behavior in action, comment out the `initialLayoutAttributesForAppearingItemAtIndexPath` method in the `Cell Animations` app and watch what happens. It isn't pretty...

##### Final Layout Attributes

Overriding the final layout attributes API is just as important as the initial layout attributes, but is slightly easier.

```swift
override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    return layoutAttributesForItemAtIndexPath(itemIndexPath)
}
```

By default, Apple will fade-out a cell that is disappearing. Since this is not the desired behavior, you need to provide the layout attributes for this case. For the `Cell Animations` app, the cell should animate to the final position without changing the alpha value. To accomplish this, the current layout attributes for the specified index path can be returned.

> Try commenting out this method in the `Cell Animations` app to observe how this affects the animations.

#### Content Offset

Now that the cells are expanding and collapsing, we need to be able to scroll the collection view during the animation to make sure the cell is completely on-screen when expanded. Thankfully, Apple has a way for us to override the default scrolling behavior in these situations.

```swift
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
```

Overriding this method can seem complicated, but it really isn't. Apple provides you a `proposedContentOffset` which is where the collection view will be scrolled to if you don't modify it. Then you just need to modify the offset values if needed. In this implementation, the offset is not overridden if there is not a selected cell. If there is a selected cell, then the content offset is adjusted if the cell is only partially visible on either the top or bottom of the screen. This results in the collection view smoothly scrolling alongside the expansion animation.

> To see what happens without this implementation, comment out this method and give it a try. You'll see that the cells expand as expected, but the collection view will not make the effort to make sure the expanded cell is fully on-screen.

### Sticky Headers

The goal of the second application (Sticky Headers) was to use a custom layout that could control cell animations in addition to sticky section header cells for each section. While this at first seemed like it would be a simple extension to the `Cell Animations` codebase, it required a much more in-depth understanding of the collection view layout invalidation process.

> Sticky Headers refers to the behavior of table view section headers that stick to the top of the table view until bumped off by the next section header.

#### Preparing Content Cell and Section Attributes

Now that both content cells and section header cells need to be displayed in the collection view, the layout attributes need to be computed for both. In this example, content cells will be represented using regular cells while section headers will be displayed using supplementary views.

> For more details on each cell type, please refer to the [Cell.swift](https://github.com/cnoon/CollectionViewAnimations/blob/master/Source/Common/Cell.swift) implementation and the [UICollectionView](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UICollectionView_class/) documentation.

```swift
override func prepareLayout() {
    super.prepareLayout()

    prepareContentCellAttributes()
    prepareSectionHeaderAttributes()
}
```

You'll notice that the `prepareLayout` implementation performs two different steps. The first is to compute the layout attributes for all the content cells. This works exactly as the previous implementation in the `Cell Animations` app with the exception of computing the section limits.

The `prepareSectionHeaderAttributes` implementation works more-or-less the same as the content cell implementation, but is instead generating supplementary view layout attributes with a custom `zIndex`. This is to make sure the section headers are always displayed ontop of the content cells.

> The reason these are split into two different methods will be more apparent in the invalidation section.

#### Layout Attributes

Returning the layout attributes for the section headers works exactly the same as the layout attributes for the content cells, just with slightly different APIs. Apple uses the same fade-in / fade-out behavior for supplementary views as for regular cells. Since that is not the desired behavior, the previous attributes are stored in the `prepareLayout` implementation and the initial and final methods are overridden the same was as the content cells.

```swift
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
```

> Try commenting these methods out to see how this affects the animations.

#### Invalidation

Invalidating the layout efficiently and correctly proved to be the most difficult part of this implementation. By default, I knew the layout needed to be invalidated each time a bounds change occurred to be able to update the sticky header positions. Otherwise they would never appear to be stuck to the top of the collection view.

```swift
override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
}
```

If you comment out all the invalidation methods with the exception of `shouldInvalidateLayoutForBoundsChange(_:)`, you'll see that for the most part, this implementation works. Even though it is extremely inefficient, it does perform the correct animations in most cases. Where it breaks down is when sticky headers are animating on or off the screen. In order to fix this problem, it first required understanding why the section headers were misbehaving. Then required implementing a custom invalidation context.

> Why the section headers misbehave in this situation is actually quite complicated. What is happening is thate invalidation occurs multiple times during the animation causing the `previousSectionAttributes` values to get out-of-sync causing the incorrect animation to be executed.

##### Invalidation Context

Stopping the duplicate invalidation pass from occurring required a MUCH deeper understanding of the overall invalidation process along with implementing a custom [UICollectionViewLayoutInvalidationContext](https://developer.apple.com/library/tvos/documentation/UIKit/Reference/UICollectionViewLayoutInvalidationContext_class/index.html). What is really interesting is that Apple is creating an invalidation context under-the-hood during each layout invalidation without you even knowing it. It initializes a default one where `invalidateEverything` is set to `true` causing a full recalculation of all the layout attributes. Generally, this is what you want during an invalidation. However, when you are scrolling, you only need to invalidate the sticky header layout attributes, not the content cell attributes. Implementing a custom invalidation context let's you do this.

The first step is to create an invalidation context subclass and override the `invalidateEverything` property.

```swift
class InvalidationContext: UICollectionViewLayoutInvalidationContext {
    var invalidateSectionHeaders = false
    var shouldInvalidateEverything = true

    override var invalidateEverything: Bool {
        return shouldInvalidateEverything
    }
}
```

Then you need to override the `invalidationContextClass()` method in your layout.

```swift
override class func invalidationContextClass() -> AnyClass {
	return InvalidationContext.self
}
```

This method tells the collection view what type of invalidation context to instantiate when it needs one. This method is called when the layout is manually invalidated by calling `layout.invalidateLayout()`. Since this manually called when expanding and/or collapsing a cell, the default value of `shouldInvalidateEverything` needs to be `true`.

##### Invalidation Context for Bounds Change

When invalidation occurs due to a bounds change, Apple gives you the opportunity to provide a custom invalidation context before actually invalidating the layout. This allows you to store additional state in the invalidation context to help selectively perform invalidations.

```swift
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
```

The first step is to create an `InvalidationContext`, then perform the same types of `bounds` checks that were used in the `Cell Animations` app.

* **Size Changed** - Invalidate all the layout attributes because the cell is being expanded or collapsed
* **Origin Changed** - Invalidate only the section header layout attributes because the collection view is scrolling

##### Invalidate Layout with Context

The final step in the invalidation process is to actually perform the invalidation. This happens in the `invalidateLayoutWithContext(_:)` method.

```swift
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
```

Now getting this exactly right took some trial and error due to lack of documentation around this particular behavior. What happens here is that by calling the `super` implementation, the layout will invalidate all layout attributes it has been told to invalidate and force the collection view to update the layout attributes for the index paths that were invalidated. For example, if `invalidateEverything` is `true`, the collection view will call `prepareLayout` and query for all the layout attributes for all visible cells and supplementary views. Therefore, in the above implementation, if `invalidateEverything` is `true`, then it simply calls `super` and returns. This is the desired behavior when someone manually invalidates the layout in the event of expanding or collapsing a cell.

The more common case however is that the collection view is being scrolled. In this case, `invalidateEverything` is `false`, and `invalidateSectionHeaders` is `true`. When `invalidateEverything` is `false`, the `invalidationContext` needs to be notified which index paths need to be invalidated. For this example, only the section header layout attributes need to be invalidated. Because of this, the first step is to recompute the section header attributes by calling `prepareSectionHeaderAttributes`.

> This is why the `prepareLayout` method is split into two different methods. This allows the section header attributes to be recomputed without having to recompute ALL the attributes.

After recomputing the section header attributes, the `invalidationContext` is notified of which supplementary elements need to be invalidated for the specified index paths. This doesn't have any affect on the collection view until `super` is called. By calling `super`, the layout attributes are invalidated for the supplementary elements and the collection view updates the layout attributes for the section headers at the specified index paths.

This logic eliminates the problem of the duplicate invalidation pass and also is much more performant. While collection views and custom layouts are quite complex, they are extremely powerful when used correctly.

---

## Author

- [Christian Noon](https://github.com/cnoon) ([@Christian_Noon](https://twitter.com/christian_noon))

## License

CollectionViewAnimations is released under the MIT license. See LICENSE for details.
