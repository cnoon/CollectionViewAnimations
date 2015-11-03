//
//  ViewController.swift
//  CollectionViewAnimations
//
//  Created by Christian Noon on 10/29/15.
//  Copyright © 2015 Noondev. All rights reserved.
//

import SnapKit
import UIKit

class ViewController: UIViewController {

    // MARK: Properties

    let colors2: [[UIColor]]
    let colors: [UIColor]
    var collectionView: UICollectionView!
    var layout = ExpandCollapseLayout()

    // MARK: Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        var colors: [UIColor] = []

        for _ in 1...20 {
            colors.append(UIColor.randomColor())
        }

        self.colors = colors

        var colors2: [[UIColor]] = []

        for _ in 0...3 {
            var colors: [UIColor] = []

            for _ in 1...10 {
                colors.append(UIColor.randomColor())
            }

            colors2.append(colors)
        }

        self.colors2 = colors2

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView = {
            let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
            collectionView.backgroundColor = UIColor.whiteColor()

            collectionView.dataSource = self
            collectionView.delegate = self

            collectionView.registerClass(ContentCell.self, forCellWithReuseIdentifier: ContentCell.reuseIdentifier)

            collectionView.registerClass(
                SectionHeaderCell.self,
                forSupplementaryViewOfKind: SectionHeaderCell.kind,
                withReuseIdentifier: SectionHeaderCell.reuseIdentifier
            )

            return collectionView
        }()

        view.addSubview(collectionView)

        collectionView.snp_makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(
        collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int)
        -> CGSize
    {
        return CGSize(width: collectionView.bounds.width, height: 40.0)
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return colors2.count
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors2[section].count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            ContentCell.reuseIdentifier,
            forIndexPath: indexPath
        ) as! ContentCell

        UIView.performWithoutAnimation {
            cell.backgroundColor = self.colors[indexPath.item]
            cell.label.text = "Cell (\(indexPath.section), \(indexPath.item))"
        }

        return cell
    }

    func collectionView(
        collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(
            SectionHeaderCell.kind,
            withReuseIdentifier: SectionHeaderCell.reuseIdentifier,
            forIndexPath: indexPath
        ) as! SectionHeaderCell

        cell.label.text = "Section \(indexPath.section)"

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        layout.selectedCellIndexPath = layout.selectedCellIndexPath == indexPath ? nil : indexPath

        print("\n============ Selected cell: (\(indexPath.section), \(indexPath.item)) ============\n")

        let bounceEnabled = false

        UIView.animateWithDuration(
            0.4,
            delay: 0.0,
            usingSpringWithDamping: bounceEnabled ? 0.5 : 1.0,
            initialSpringVelocity: bounceEnabled ? 2.0 : 0.0,
            options: UIViewAnimationOptions(),
            animations: {
                print("will invalidate layout")
                self.layout.invalidateLayout()
                print("did invalidate layout")
                print("will layout if needed")
                self.collectionView.layoutIfNeeded()
                print("did layout if needed")
            },
            completion: { _ in
                print("animation complete")
            }
        )
    }
}
