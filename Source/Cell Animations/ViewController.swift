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

    let colors: [UIColor]
    var collectionView: UICollectionView!
    var layout = Layout()

    // MARK: Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        var colors: [UIColor] = []

        for _ in 1...20 {
            colors.append(UIColor.randomColor())
        }

        self.colors = colors

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

            collectionView.registerClass(ContentCell.self, forCellWithReuseIdentifier: ContentCell.kind)

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
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            ContentCell.kind,
            forIndexPath: indexPath
        ) as! ContentCell

        cell.backgroundColor = colors[indexPath.item]
        cell.label.text = "Cell \(indexPath.item)"

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        layout.selectedCellIndexPath = layout.selectedCellIndexPath == indexPath ? nil : indexPath

        let bounceEnabled = false

        UIView.animateWithDuration(
            0.4,
            delay: 0.0,
            usingSpringWithDamping: bounceEnabled ? 0.5 : 1.0,
            initialSpringVelocity: bounceEnabled ? 2.0 : 0.0,
            options: UIViewAnimationOptions(),
            animations: {
                self.layout.invalidateLayout()
                self.collectionView.layoutIfNeeded()
            },
            completion: nil
        )
    }
}
