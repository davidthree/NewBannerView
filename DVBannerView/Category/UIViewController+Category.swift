//
//  UIViewController+Category.swift
//  DVBannerView
//
//  Created by David on 2017/3/31.
//  Copyright © 2017年 David. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift
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
    /// 更新Realm数据库
    /// - Parameters:
    ///     - modelObject:  表名
    ///     - model:  DVMessageModel模型
    func writeToRealmWithMessageModel(_ modelObject: Object.Type, model: DVMessageModel, sortid: Int){
        try! realm.write{
            if model.isBanner {
                
                realm.create(modelObject, value: ["id":model.id,"datefolder":model.datefolder,"praise":model.praise,"title":model.title,"newstitle":model.newstitle,"url":model.url,"pic":model.pic,"summary":model.summary,"isBanner":true], update: true)
            }
            if sortid == 0 {
                realm.create(modelObject, value: ["id":model.id,"sortid":model.sortid,"title":model.title,"titlesub":model.titlesub,"type":model.type,"datefolder":model.datefolder,"url":model.url,"pic":model.pic,"piclarge":model.piclarge,"picmore":model.picmore,"iscommend":model.iscommend,"istop":model.istop,"summary":model.summary,"praise":model.praise,"isHomepage":true], update: true)
            }
            else{
                realm.create(modelObject, value: ["id":model.id,"sortid":model.sortid,"title":model.title,"titlesub":model.titlesub,"type":model.type,"datefolder":model.datefolder,"url":model.url,"pic":model.pic,"piclarge":model.piclarge,"picmore":model.picmore,"iscommend":model.iscommend,"istop":model.istop,"summary":model.summary,"praise":model.praise], update: true)
            }
        }
    }
    
    
}
