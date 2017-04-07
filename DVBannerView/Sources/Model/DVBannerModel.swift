//
//  DVBannerModel.swift
//  DVBannerView
//
//  Created by David on 2017/4/5.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import RealmSwift
class DVBannerModel: Object {
    dynamic var newsid = ""
    dynamic var datefolder = ""
    dynamic var praise = 0
    dynamic var title = ""
    dynamic var newstitle = ""
    dynamic var url = ""
    dynamic var pic = ""
    dynamic var summary = ""
    dynamic var ispraise = false
    override static func primaryKey() -> String?{
        return "newsid"
    }
}
