//
//  HoldIndexPathAndIMage.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/09/08.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit
struct HoldIndexPathAndImage {
    var indexPath: IndexPath
    var image: UIImage?
    init(indexPath: IndexPath, _ image: UIImage? = nil) {
        self.indexPath = indexPath
        self.image = image
    }
}
extension HoldIndexPathAndImage: Equatable {
    public static func ==(lhs: HoldIndexPathAndImage, rhs: HoldIndexPathAndImage) -> Bool {
        return lhs.indexPath == rhs.indexPath
    }
}
extension HoldIndexPathAndImage: Comparable{
    public static func <(lhs: HoldIndexPathAndImage, rhs: HoldIndexPathAndImage) -> Bool {
        return lhs.indexPath.item <  rhs.indexPath.item
    }
    public static func <=(lhs: HoldIndexPathAndImage, rhs: HoldIndexPathAndImage) -> Bool {
        return lhs.indexPath.item <=  rhs.indexPath.item
    }
    
    public static func >=(lhs: HoldIndexPathAndImage, rhs: HoldIndexPathAndImage) -> Bool {
        return lhs.indexPath.item >=  rhs.indexPath.item
    }
    
    public static func >(lhs: HoldIndexPathAndImage, rhs: HoldIndexPathAndImage) -> Bool {
        return  lhs.indexPath.item >  rhs.indexPath.item
    }
}
