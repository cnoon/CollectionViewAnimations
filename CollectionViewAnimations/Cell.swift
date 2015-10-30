//
//  Cell.swift
//  CollectionViewAnimations
//
//  Created by Christian Noon on 10/29/15.
//  Copyright © 2015 Noondev. All rights reserved.
//

import UIKit

class Cell: UICollectionViewCell {
    class var kind: String { return "\(self)" }
    var label: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        label = {
            let label = UILabel()
            label.font = UIFont.systemFontOfSize(20)
            label.textColor = UIColor.whiteColor()

            return label
        }()

        contentView.addSubview(label)

        label.snp_makeConstraints { make in
            make.center.equalTo(contentView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        layoutIfNeeded()
    }
}
