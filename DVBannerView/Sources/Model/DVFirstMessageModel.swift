//
//  DVFirstMessageModel.swift
//  DVBannerView
//
//  Created by David on 2017/4/5.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import RealmSwift
class DVFirstMessageModel: Object {
    dynamic var id = 0
    dynamic var sortid = ""
    dynamic var title = ""
    dynamic var titlesub = ""
    dynamic var type = 0
    dynamic var source = ""
    dynamic var date = ""
    dynamic var datefolder = ""
    dynamic var url = ""
    dynamic var pic = ""
    dynamic var piclarge = ""
    dynamic var picmore = ""
    dynamic var iscommend = 0
    dynamic var istop = 0
    dynamic var summary = ""
    dynamic var praise = 0
    dynamic var ispraise = false
    override static func primaryKey() -> String?{
        return "id"
    }
}
