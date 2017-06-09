//
//  Cell.swift
//  CollectionViewAnimations
//
//  Created by Christian Noon on 10/29/15.
//  Copyright © 2015 Noondev. All rights reserved.
//

import UIKit

class ContentCell: UICollectionViewCell {
    class var reuseIdentifier: String { return "\(self)" }
    class var kind: String { return "ContentCell" }

    var label: UILabel!

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        label = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = UIColor.white

            return label
        }()

        contentView.addSubview(label)

        label.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        UIView.performWithoutAnimation {
            self.backgroundColor = nil
        }
    }

    // MARK: Layout

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layoutIfNeeded()
    }
}

// MARK: -

class SectionHeaderCell: UICollectionReusableView {
    class var reuseIdentifier: String { return "\(self)" }
    class var kind: String { return "SectionHeaderCell" }

    var label: UILabel!

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(white: 0.2, alpha: 1.0)

        label = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.textColor = UIColor.white

            return label
        }()

        addSubview(label)

        label.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(20)
            make.trailing.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: Layout

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layoutIfNeeded()
    }
}
