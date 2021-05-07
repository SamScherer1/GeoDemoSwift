//
//  FlyZoneColorProvider.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/6/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import DJISDK

extension UIColor {
    convenience init(r: CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
}
//
////0x979797
//#define DJI_FS_HEIGHT_LIMIT_GRAY_01 [UIColor colorWithR:151 G:151 B:151 A:0.1]
//#define DJI_FS_HEIGHT_LIMIT_GRAY_1 [UIColor colorWithR:151 G:151 B:151 A:1]
let kDJI_FS_HEIGHT_LIMIT_GRAY_01 = UIColor(r: 151, g: 151, b: 151, a: 0.1)
let kDJI_FS_HEIGHT_LIMIT_GRAY_1 = UIColor(r: 151, g: 151, b: 151, a: 1)

////0xDE4329
//#define DJI_FS_LIMIT_RED_01 [UIColor colorWithR:222 G:67 B:41 A:0.1]
//#define DJI_FS_LIMIT_RED_1 [UIColor colorWithR:222 G:67 B:41 A:1]
let kDJI_FS_HEIGHT_LIMIT_RED_01 = UIColor(r: 222, g: 67, b: 41, a: 0.1)
let kDJI_FS_HEIGHT_LIMIT_RED_1 = UIColor(r: 222, g: 67, b: 41, a: 1)

////0x1088F2
//#define DJI_FS_AUTH_BLUE_01 [UIColor colorWithR:16 G:136 B:242 A:0.1]
//#define DJI_FS_AUTH_BLUE_1 [UIColor colorWithR:16 G:136 B:242 A:1]
let kDJI_FS_HEIGHT_LIMIT_BLUE_01 = UIColor(r: 16, g: 136, b: 242, a: 0.1)
let kDJI_FS_HEIGHT_LIMIT_BLUE_1 = UIColor(r: 16, g: 136, b: 242, a: 1)

////0xFFCC00
//#define DJI_FS_WARNING_YELLOW_01 [UIColor colorWithR:255 G:204 B:0 A:0.1]
//#define DJI_FS_WARNING_YELLOW_1 [UIColor colorWithR:255 G:204 B:0 A:1]
let kDJI_FS_WARNING_YELLOW_01 = UIColor(r: 255, g: 204, b: 0, a: 0.1)
let kDJI_FS_WARNING_YELLOW_1 = UIColor(r: 255, g: 204, b: 0, a: 1)

////0xEE8815
//#define DJI_FS_SPECIAL_WARNING_ORANGE_01 [UIColor colorWithR:238 G:136 B:21 A:0.1]
//#define DJI_FS_SPECIAL_WARNING_ORANGE_1 [UIColor colorWithR:238 G:136 B:21 A:1]
let kDJI_FS_SPECIAL_WARNING_ORANGE_01 = UIColor(r: 238, g: 238, b: 136, a: 0.1)
let kDJI_FS_SPECIAL_WARNING_ORANGE_1 = UIColor(r: 238, g: 238, b: 136, a: 1)


class FlyZoneColorProvider : NSObject { //TODO: how to avoid subclassing nsobject
    
    func getFlyZoneOverlayColorFor(category: DJIFlyZoneCategory, isHeightLimit: Bool, isFill:Bool) -> UIColor {
        if isHeightLimit {
            return isFill ? kDJI_FS_HEIGHT_LIMIT_GRAY_01 : kDJI_FS_HEIGHT_LIMIT_GRAY_1
        }
        
        switch category {
        case .authorization:
            return isFill ? kDJI_FS_HEIGHT_LIMIT_BLUE_01 : kDJI_FS_HEIGHT_LIMIT_BLUE_1
        case .restricted:
            return isFill ? kDJI_FS_HEIGHT_LIMIT_RED_01 : kDJI_FS_HEIGHT_LIMIT_RED_1
        case .warning:
            return isFill ? kDJI_FS_WARNING_YELLOW_01 : kDJI_FS_WARNING_YELLOW_1
        case .enhancedWarning:
            return isFill ? kDJI_FS_SPECIAL_WARNING_ORANGE_01 : kDJI_FS_SPECIAL_WARNING_ORANGE_1
        case .unknown:
            return UIColor(r: 0, g: 0, b: 0, a: 0)
        @unknown default:
            fatalError()
        }
    }
    
}
