//
//  ShowCellsAfterBefore.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/09/08.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit
class ShowCellsAfterBefore: UICollectionViewFlowLayout {
    
    var pageWidth: CGFloat {
        return self.itemSize.width + self.minimumLineSpacing
    }
    var flickVelociy: CGFloat {
        return 0.3
    }
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        let bounds = collectionView.bounds
        let halfWidth = bounds.width * 0.5
        let proposedContentOffsetCenter = proposedContentOffset.x + halfWidth
        if let attributeForCells = self.layoutAttributesForElements(in: bounds) {
            var canidateAttributes: UICollectionViewLayoutAttributes?
            for attributes in attributeForCells {
                if attributes.representedElementCategory != UICollectionElementCategory.cell {
                    continue
                }
                if let cand = canidateAttributes {
                    let a = attributes.center.x  - proposedContentOffsetCenter
                    let b = cand.center.x - proposedContentOffsetCenter
                    if fabs(a) < fabs(b) {
                        canidateAttributes = attributes
                    }
                }
                else {
                    canidateAttributes = attributes
                }
            }
            return CGPoint.init(x: canidateAttributes!.center.x - halfWidth, y: proposedContentOffset.y)
        }
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
}
