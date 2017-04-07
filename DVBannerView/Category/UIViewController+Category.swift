//
//  UIViewController+Category.swift
//  DVBannerView
//
//  Created by David on 2017/3/31.
//  Copyright © 2017年 David. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    class func imageWithColor(color:UIColor,size:CGSize) -> UIImage {
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect);
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image;
    }
}
