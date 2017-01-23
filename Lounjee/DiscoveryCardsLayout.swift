//
//  DiscoveryCardsFlowLayout.swift
//  Lounjee
//
//  Created by Junior Boaventura on 02.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

enum DiscoveryCardsLayoutDirection {
    case Left
    case Right
    case None
}

protocol DiscoveryCardsLayoutDelegate {
    func discoveryCardsLayout(layout: DiscoveryCardsLayout, didDragCardOverLimitOnDirection direction: DiscoveryCardsLayoutDirection, indexPath: NSIndexPath)
    func discoveryCardsLayoutDidFinishDragging(layout: DiscoveryCardsLayout, onDirection direction: DiscoveryCardsLayoutDirection, indexPath: NSIndexPath)
}

class DiscoveryCardsLayout: UICollectionViewLayout {
    private var draggingDirection: DiscoveryCardsLayoutDirection = .None

    var delegate: DiscoveryCardsLayoutDelegate?
    var itemSize: CGSize!
    var layoutInset: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    var floatingCardCenterPosition: CGPoint = CGPointZero
    var floatingLayoutAttributes: UICollectionViewLayoutAttributes!
    var floatingCardIndexPath: NSIndexPath? {
        didSet {
            if self.floatingCardIndexPath == nil && oldValue != nil {
                self.delegate?.discoveryCardsLayoutDidFinishDragging(self, onDirection: self.draggingDirection, indexPath: oldValue!)
                self.draggingDirection = .None
                self.floatingCardCenterPosition = CGPointZero
            }
        }
    }

    func offsetFloatingCardAtIndexPath(indexPath: NSIndexPath, inDirection direction: DiscoveryCardsLayoutDirection) {
        if direction == .Left {
            self.floatingLayoutAttributes?.center.x = -(CGRectGetMaxX(self.collectionView!.bounds) + self.itemSize.width + self.layoutInset.left)
        }
        else if direction == .Right {
            self.floatingLayoutAttributes?.center.x = CGRectGetMaxX(self.collectionView!.bounds) + self.itemSize.width + self.layoutInset.left
        }
        self.invalidateLayout()
    }
    
    override func prepareLayout() {
        let widthInset = self.layoutInset.left + self.layoutInset.right
        let heightInset = self.layoutInset.top + self.layoutInset.bottom
        self.itemSize = CGSizeMake(self.collectionView!.bounds.width - widthInset, self.collectionView!.bounds.height - heightInset)
        self.collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        return attribute
    }
    
    override func collectionViewContentSize() -> CGSize {
        return self.itemSize
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()

        for section in 0 ..< (self.collectionView?.numberOfSections() ?? 0)  {
            for row in 0 ..< (self.collectionView?.numberOfItemsInSection(section) ?? 0 ) {
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                attributes.append(UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath))
            }
        }
        
        var itemSizeReductionStep: CGFloat = 0
        var yOffset: CGFloat = 0.0
        var zIndex: Int = 0
        
        attributes.forEach({
            let attribute = $0 as UICollectionViewLayoutAttributes
            
            attribute.size = CGSizeMake(self.itemSize.width - itemSizeReductionStep, self.itemSize.height - itemSizeReductionStep)
            if self.floatingCardIndexPath != nil && self.floatingCardIndexPath! == attribute.indexPath {
                self.floatingLayoutAttributes = attribute
                attribute.center.x = self.floatingCardCenterPosition.x + (self.layoutInset.left + attribute.size.width / 2.0)
                attribute.center.y = self.floatingCardCenterPosition.y + (self.layoutInset.top + attribute.size.height / 2.0)

                if attribute.center.x < 0.0 {
                    self.draggingDirection = .Left
                }
                else if attribute.center.x > self.collectionView!.bounds.width {
                    self.draggingDirection = .Right
                }
                else {
                    self.draggingDirection = .None
                }
                self.delegate?.discoveryCardsLayout(self, didDragCardOverLimitOnDirection: self.draggingDirection, indexPath: self.floatingCardIndexPath!)
            }
            
            else if attribute != self.floatingLayoutAttributes {
                attribute.center.x = self.collectionView!.center.x
                attribute.center.y = (self.layoutInset.top + self.itemSize.height / 2.0) + yOffset
            }
            let distanceFromCenter = attribute.center.x - CGRectGetMidX(self.collectionView!.bounds)
            let distanceRatio = distanceFromCenter / self.collectionView!.bounds.width
            attribute.transform = CGAffineTransformMakeRotation(CGFloat(M_2_PI) * distanceRatio)
            attribute.zIndex = zIndex

            itemSizeReductionStep += 0//10.0
            if yOffset < 30 {
                yOffset += 0//10.0
            }
            zIndex -= 1
        })
        return attributes
    }

}
