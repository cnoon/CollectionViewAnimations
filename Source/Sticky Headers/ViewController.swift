//
//  ViewController.swift
//  Sticky Headers
//
//  Created by Christian Noon on 10/29/15.
//  Copyright © 2015 Noondev. All rights reserved.
//

import SnapKit
import UIKit

class ViewController: UIViewController {

    // MARK: Properties

    let colors: [[UIColor]]
    var collectionView: UICollectionView!
    var layout = Layout()

    // MARK: Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.colors = {
            var colorsBySection: [[UIColor]] = []

            for _ in 0...Number.random(from: 2, to: 4) {
                var colors: [UIColor] = []

                for _ in 0...Number.random(from: 2, to: 10) {
                    colors.append(UIColor.randomColor())
                }
                
                colorsBySection.append(colors)
            }

            return colorsBySection
        }()

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView = {
            let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            collectionView.backgroundColor = UIColor.white

            collectionView.dataSource = self
            collectionView.delegate = self

            collectionView.register(ContentCell.self, forCellWithReuseIdentifier: ContentCell.reuseIdentifier)

            collectionView.register(
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

    // MARK: Status Bar

    override var prefersStatusBarHidden : Bool {
        return true
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int)
        -> CGSize
    {
        return CGSize(width: collectionView.bounds.width, height: 40.0)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ContentCell.reuseIdentifier,
            for: indexPath
        ) as! ContentCell

        UIView.performWithoutAnimation {
            cell.backgroundColor = self.colors[indexPath.section][indexPath.item]
            cell.label.text = "Cell (\(indexPath.section), \(indexPath.item))"
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView
    {
        let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: SectionHeaderCell.kind,
            withReuseIdentifier: SectionHeaderCell.reuseIdentifier,
            for: indexPath
        ) as! SectionHeaderCell

        cell.label.text = "Section \(indexPath.section)"

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        layout.selectedCellIndexPath = layout.selectedCellIndexPath == indexPath ? nil : indexPath

        let bounceEnabled = false

        UIView.animate(
            withDuration: 0.4,
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
